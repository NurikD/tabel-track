# handlers/menu.py
from aiogram import Router, types, F
from aiogram.types import ReplyKeyboardMarkup, KeyboardButton, InlineKeyboardMarkup, InlineKeyboardButton
from asgiref.sync import sync_to_async
from app.models import CustomUser, LeaveRequest
from django.db.models import Q
from datetime import datetime

router = Router()

def get_main_menu():
    """Создает главное меню с кнопками"""
    keyboard = ReplyKeyboardMarkup(
        keyboard=[
            [KeyboardButton(text="📝 Подать заявку"), KeyboardButton(text="📊 Мои заявки")],
            [KeyboardButton(text="📅 Остаток отпуска"), KeyboardButton(text="🎤 Голосовая заявка")],
            [KeyboardButton(text="ℹ️ Помощь"), KeyboardButton(text="👤 Мой профиль")]
        ],
        resize_keyboard=True,
        one_time_keyboard=False
    )
    return keyboard

def get_request_type_menu():
    """Меню выбора типа заявки"""
    return InlineKeyboardMarkup(inline_keyboard=[
        [InlineKeyboardButton(text="🏖️ Ежегодный отпуск", callback_data="request_vacation")],
        [InlineKeyboardButton(text="🏥 Больничный", callback_data="request_sick")],
        [InlineKeyboardButton(text="✈️ Командировка", callback_data="request_business")],
        [InlineKeyboardButton(text="📞 Отгул", callback_data="request_personal")],
        [InlineKeyboardButton(text="⬅️ Назад", callback_data="back_to_main")]
    ])

@router.message(F.text == "📝 Подать заявку")
async def show_request_types(message: types.Message):
    """Показывает типы заявок"""
    user = await sync_to_async(CustomUser.objects.filter(telegram_id=message.from_user.id).first)()
    if not user:
        await message.answer("❗ Сначала привяжите аккаунт через сайт.")
        return

    await message.answer(
        "🎯 Выберите тип заявки:",
        reply_markup=get_request_type_menu()
    )

@router.message(F.text == "📊 Мои заявки")
async def show_my_requests(message: types.Message):
    """Показывает заявки пользователя"""
    user = await sync_to_async(CustomUser.objects.filter(telegram_id=message.from_user.id).first)()
    if not user:
        await message.answer("❗ Сначала привяжите аккаунт через сайт.")
        return

    # Получаем последние 5 заявок
    requests = await sync_to_async(
        lambda: list(LeaveRequest.objects.filter(user=user).order_by('-created_at')[:5])
    )()

    if not requests:
        await message.answer("📋 У вас пока нет заявок.")
        return

    text = "📊 Ваши последние заявки:\n\n"
    status_emoji = {
        'pending': '⏳',
        'approved': '✅',
        'rejected': '❌'
    }

    for req in requests:
        duration = (req.end_date - req.start_date).days + 1
        text += (
            f"{status_emoji.get(req.status, '❓')} {req.get_leave_type_display()}\n"
            f"📅 {req.start_date.strftime('%d.%m.%Y')} - {req.end_date.strftime('%d.%m.%Y')} ({duration} дн.)\n"
            f"📝 Статус: {req.get_status_display()}\n\n"
        )

    await message.answer(text)

@router.message(F.text == "📅 Остаток отпуска")
async def show_vacation_balance(message: types.Message):
    """Показывает остаток отпуска"""
    user = await sync_to_async(CustomUser.objects.filter(telegram_id=message.from_user.id).first)()
    if not user:
        await message.answer("❗ Сначала привяжите аккаунт через сайт.")
        return

    # Подсчитываем использованные дни отпуска
    used_vacation = await sync_to_async(
        lambda: sum(
            (req.end_date - req.start_date).days + 1
            for req in LeaveRequest.objects.filter(
                user=user,
                leave_type='vacation',
                status='approved'
            )
        )
    )()

    # Подсчитываем заявки на рассмотрении
    pending_vacation = await sync_to_async(
        lambda: sum(
            (req.end_date - req.start_date).days + 1
            for req in LeaveRequest.objects.filter(
                user=user,
                leave_type='vacation',
                status='pending'
            )
        )
    )()

    total_vacation = 44  # Обычно 28 дней + доп. дни
    remaining = total_vacation - used_vacation

    text = (
        f"📊 Отпускная статистика:\n\n"
        f"🏖️ Всего отпуска в году: {total_vacation} дн.\n"
        f"✅ Использовано: {used_vacation} дн.\n"
        f"⏳ На рассмотрении: {pending_vacation} дн.\n"
        f"📅 Остаток: {remaining} дн.\n\n"
    )

    if remaining < 14:
        text += "⚠️ Не забудьте, что один отпуск должен быть не менее 14 дней!"

    await message.answer(text)

@router.message(F.text == "🎤 Голосовая заявка")
async def voice_request_help(message: types.Message):
    """Инструкция по голосовым заявкам"""
    user = await sync_to_async(CustomUser.objects.filter(telegram_id=message.from_user.id).first)()
    if not user:
        await message.answer("❗ Сначала привяжите аккаунт через сайт.")
        return

    text = (
        "🎤 Голосовые заявки\n\n"
        "Отправьте голосовое сообщение в формате:\n\n"
        "📝 Примеры:\n"
        "• \"Отпуск с первого по пятнадцатое декабря\"\n"
        "• \"Больничный на девятнадцатое ноября\"\n"
        "• \"Командировка с десятого по двенадцатое января\"\n\n"
        "🎯 Важно четко произносить:\n"
        "• Тип (отпуск/больничный/командировка)\n"
        "• Даты (с... по... или на...)\n"
        "• Месяц полностью\n\n"
        "После записи голосового сообщения бот распознает речь и покажет заявку для подтверждения."
    )

    await message.answer(text)

@router.message(F.text == "👤 Мой профиль")
async def show_profile(message: types.Message):
    """Показывает профиль пользователя"""
    user = await sync_to_async(CustomUser.objects.filter(telegram_id=message.from_user.id).first)()
    if not user:
        await message.answer("❗ Сначала привяжите аккаунт через сайт.")
        return

    text = (
        f"👤 Ваш профиль:\n\n"
        f"📛 ФИО: {user.full_name}\n"
        f"📧 Email: {user.email}\n"
        f"🏢 Должность: {user.get_position_display()}\n"
        f"📅 Дата регистрации: {user.date_joined.strftime('%d.%m.%Y')}\n"
        f"🆔 Telegram ID: {user.telegram_id}\n"
    )

    await message.answer(text)

@router.message(F.text == "ℹ️ Помощь")
async def show_help(message: types.Message):
    """Показывает справку"""
    text = (
        "🤖 Справка по боту\n\n"
        "📝 Команды:\n"
        "• /start - Информация о профиле\n"
        "• /vacation - Подать заявку на отпуск\n\n"
        "🎯 Кнопки меню:\n"
        "• 📝 Подать заявку - Выбор типа заявки\n"
        "• 📊 Мои заявки - История заявок\n"
        "• 📅 Остаток отпуска - Статистика\n"
        "• 🎤 Голосовая заявка - Инструкция\n"
        "• 👤 Мой профиль - Информация о вас\n\n"
        "❓ Проблемы?\n"
        "Обратитесь к администратору или HR-отделу."
    )

    await message.answer(text)

# Обработчики inline кнопок
@router.callback_query(F.data == "back_to_main")
async def back_to_main(callback: types.CallbackQuery):
    """Возврат в главное меню"""
    await callback.message.edit_text(
        "🏠 Главное меню:",
        reply_markup=get_main_menu()
    )
    await callback.answer()

@router.callback_query(F.data.startswith("request_"))
async def handle_request_type(callback: types.CallbackQuery):
    """Обработка выбора типа заявки"""
    request_type = callback.data.replace("request_", "")

    type_instructions = {
        "vacation": "🏖️ Для подачи заявки на отпуск используйте команду /vacation или отправьте голосовое сообщение.",
        "sick": "🏥 Для больничного отправьте голосовое сообщение в формате: 'Больничный на [дата] [месяц]'",
        "business": "✈️ Для командировки отправьте голосовое сообщение в формате: 'Командировка с [дата] по [дата] [месяц]'",
        "personal": "📞 Для отгула отправьте голосовое сообщение в формате: 'Отгул на [дата] [месяц]'"
    }

    await callback.message.edit_text(
        type_instructions.get(request_type, "❓ Неизвестный тип заявки"),
        reply_markup=InlineKeyboardMarkup(inline_keyboard=[
            [InlineKeyboardButton(text="⬅️ Назад", callback_data="back_to_request_types")]
        ])
    )
    await callback.answer()

@router.callback_query(F.data == "back_to_request_types")
async def back_to_request_types(callback: types.CallbackQuery):
    """Возврат к выбору типа заявки"""
    await callback.message.edit_text(
        "🎯 Выберите тип заявки:",
        reply_markup=get_request_type_menu()
    )
    await callback.answer()