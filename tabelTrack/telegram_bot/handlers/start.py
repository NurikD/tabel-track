# handlers/start.py
from aiogram import Router, types
from aiogram.filters import Command
from aiogram.types import ReplyKeyboardMarkup, KeyboardButton
from asgiref.sync import sync_to_async
from app.models import CustomUser

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

@router.message(Command("start"))
async def start(message: types.Message):
    tg_id = message.from_user.id

    user = await sync_to_async(CustomUser.objects.filter(telegram_id=tg_id).first)()

    if user:
        text = (
            f"👋 Привет, {user.full_name}!\n\n"
            f"📌 Должность: {user.get_position_display()}\n"
            f"🎯 Используйте кнопки меню для быстрого доступа к функциям:"
        )
        await message.answer(text, reply_markup=get_main_menu())
    else:
        text = (
            "😐 Ты не авторизован.\n\n"
            "🔗 Зайди в личный кабинет на сайте и привяжи Telegram.\n"
            "После привязки используй команду /start снова."
        )
        await message.answer(text)