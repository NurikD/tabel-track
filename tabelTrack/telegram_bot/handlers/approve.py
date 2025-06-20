# handlers/approve.py
from aiogram import Router, types, F
from aiogram.filters import CommandObject, Command
from aiohttp import request
import requests
from app.models import CustomUser, LeaveRequest
from asgiref.sync import sync_to_async
import json
from django.conf import settings
from django.utils import timezone

router = Router()

@router.callback_query(F.data.startswith("approve_"))
async def approve_request(callback: types.CallbackQuery):
    """Одобрение заявки через Telegram"""
    request_id = callback.data.split("_")[1]
    await process_request_action(callback, request_id, "approve")

@router.callback_query(F.data.startswith("reject_"))
async def reject_request(callback: types.CallbackQuery):
    """Отклонение заявки через Telegram"""
    request_id = callback.data.split("_")[1]
    await process_request_action(callback, request_id, "reject")

@router.callback_query(F.data.startswith("details_"))
async def show_request_details(callback: types.CallbackQuery):
    """Показать подробности заявки"""
    request_id = callback.data.split("_")[1]

    try:
        # Проверяем права пользователя
        approver = await sync_to_async(
            lambda: CustomUser.objects.get(telegram_id=callback.from_user.id, role='approver')
        )()

        # Получаем заявку
        leave_request = await sync_to_async(
            lambda: LeaveRequest.objects.select_related('user').get(id=request_id)
        )()

        # Рассчитываем количество дней
        days_count = (leave_request.end_date - leave_request.start_date).days + 1

        # Получаем остаток отпуска сотрудника
        total_used = await sync_to_async(
            lambda: sum(
                (r.end_date - r.start_date).days + 1
                for r in LeaveRequest.objects.filter(
                    user=leave_request.user,
                    leave_type='vacation',
                    status='approved'
                )
            )
        )()

        available_days = 44 - total_used

        details_text = (
            f"📋 Подробности заявки #{request_id}\n"
            f"━━━━━━━━━━━━━━━━━━━━━━━━\n"
            f"👤 Сотрудник: {leave_request.user.get_full_name()}\n"
            f"🏢 Должность: {leave_request.user.get_position_display() if hasattr(leave_request.user, 'get_position_display') else leave_request.user.position}\n"
            f"📅 Тип отпуска: {leave_request.get_leave_type_display()}\n"
            f"🗓 Период: {leave_request.start_date.strftime('%d.%m.%Y')} - {leave_request.end_date.strftime('%d.%m.%Y')}\n"
            f"📊 Количество дней: {days_count}\n"
            f"📝 Статус: {get_status_display(leave_request.status)}\n"
            f"🕐 Дата подачи: {leave_request.created_at.strftime('%d.%m.%Y %H:%M')}\n"
        )

        if leave_request.leave_type == 'vacation':
            details_text += f"🏖 Остаток отпуска: {available_days} дн.\n"

        if leave_request.reason:
            details_text += f"📋 Причина: {leave_request.reason}\n"

        # Если заявка еще не обработана, показываем кнопки
        if leave_request.status == 'pending':
            keyboard = types.InlineKeyboardMarkup(inline_keyboard=[
                [
                    types.InlineKeyboardButton(text="✅ Одобрить", callback_data=f"approve_{request_id}"),
                    types.InlineKeyboardButton(text="❌ Отклонить", callback_data=f"reject_{request_id}")
                ]
            ])
            await callback.message.edit_text(details_text, reply_markup=keyboard)
        else:
            await callback.message.edit_text(details_text)

    except CustomUser.DoesNotExist:
        await callback.answer("🚫 У вас нет прав для просмотра заявок", show_alert=True)
    except LeaveRequest.DoesNotExist:
        await callback.answer("❌ Заявка не найдена", show_alert=True)
    except Exception as e:
        await callback.answer(f"❌ Ошибка: {str(e)}", show_alert=True)

async def process_request_action(callback: types.CallbackQuery, request_id: str, action: str):
    """Обработка действия с заявкой (одобрение/отклонение)"""
    try:
        # Проверяем права пользователя
        approver = await sync_to_async(
            lambda: CustomUser.objects.get(telegram_id=callback.from_user.id, role='approver')
        )()

        # Получаем заявку
        leave_request = await sync_to_async(
            lambda: LeaveRequest.objects.select_related('user').get(id=request_id, status='pending')
        )()

        # Обновляем статус
        leave_request.status = 'approved' if action == 'approve' else 'rejected'
        leave_request.reviewed_by = approver
        leave_request.reviewed_at = timezone.now()

        await sync_to_async(leave_request.save)()

        # Отправляем уведомление сотруднику в Telegram
        if leave_request.user.telegram_id:
            await notify_employee_telegram(
                leave_request.user.telegram_id,
                leave_request.get_leave_type_display(),
                leave_request.start_date.strftime('%d.%m.%Y'),
                leave_request.end_date.strftime('%d.%m.%Y'),
                leave_request.status
            )

        # Отправляем email (через Celery)
        from app.tasks import send_result_to_employee
        send_result_to_employee.delay(
            leave_request.user.email,
            leave_request.get_leave_type_display(),
            leave_request.start_date.strftime('%d.%m.%Y'),
            leave_request.end_date.strftime('%d.%m.%Y'),
            leave_request.status
        )

        action_text = "одобрена ✅" if action == 'approve' else "отклонена ❌"
        success_message = (
            f"✅ Заявка #{request_id} {action_text}\n"
            f"👤 Сотрудник: {leave_request.user.get_full_name()}\n"
            f"📅 {leave_request.get_leave_type_display()}: {leave_request.start_date.strftime('%d.%m.%Y')} - {leave_request.end_date.strftime('%d.%m.%Y')}"
        )

        # Убираем кнопки и обновляем сообщение
        await callback.message.edit_text(success_message)
        await callback.answer(f"Заявка {action_text}", show_alert=False)

    except CustomUser.DoesNotExist:
        await callback.answer("🚫 У вас нет прав для согласования заявок", show_alert=True)
    except LeaveRequest.DoesNotExist:
        await callback.answer("❌ Заявка не найдена или уже обработана", show_alert=True)
    except Exception as e:
        await callback.answer(f"❌ Ошибка: {str(e)}", show_alert=True)

@router.message(Command("requests"))
async def show_pending_requests(message: types.Message):
    """Показать все ожидающие заявки"""
    try:
        # Проверяем права пользователя
        approver = await sync_to_async(
            lambda: CustomUser.objects.get(telegram_id=message.from_user.id, role='approver')
        )()

        # Получаем ожидающие заявки
        pending_requests = await sync_to_async(
            lambda: list(LeaveRequest.objects.filter(status='pending').select_related('user').order_by('-created_at'))
        )()

        if not pending_requests:
            await message.answer("📭 Нет заявок, ожидающих согласования")
            return

        response_text = f"📋 Заявки на согласование ({len(pending_requests)}):\n\n"

        for req in pending_requests:
            days_count = (req.end_date - req.start_date).days + 1
            response_text += (
                f"#{req.id} {req.user.get_full_name()}\n"
                f"📅 {req.get_leave_type_display()}: {req.start_date.strftime('%d.%m')} - {req.end_date.strftime('%d.%m')} ({days_count} дн.)\n"
                f"🕐 {req.created_at.strftime('%d.%m %H:%M')}\n\n"
            )

        # Кнопки для быстрого доступа к первым заявкам
        keyboard_buttons = []
        for req in pending_requests[:5]:  # Показываем кнопки для первых 5 заявок
            keyboard_buttons.append([
                types.InlineKeyboardButton(
                    text=f"#{req.id} {req.user.get_full_name()[:15]}...",
                    callback_data=f"details_{req.id}"
                )
            ])

        if keyboard_buttons:
            keyboard = types.InlineKeyboardMarkup(inline_keyboard=keyboard_buttons)
            await message.answer(response_text, reply_markup=keyboard)
        else:
            await message.answer(response_text)

    except CustomUser.DoesNotExist:
        await message.answer("🚫 У вас нет прав для просмотра заявок")

async def notify_employee_telegram(telegram_id, leave_type, start_date, end_date, status):
    """Отправка уведомления сотруднику о результате"""
    status_emoji = {
        'approved': '✅',
        'rejected': '❌',
        'pending': '⏳'
    }

    status_text = {
        'approved': 'одобрена ✅',
        'rejected': 'отклонена ❌',
        'pending': 'на рассмотрении ⏳'
    }

    message_text = (
        f"{status_emoji.get(status, '📝')} Статус заявки обновлен\n\n"
        f"📅 Тип: {leave_type}\n"
        f"🗓 Период: {start_date} - {end_date}\n"
        f"📊 Статус: {status_text.get(status, 'обработана')}"
    )

    # Отправляем сообщение через Telegram API
    try:
        bot_token = settings.TELEGRAM_BOT_TOKEN
        url = f"https://api.telegram.org/bot{bot_token}/sendMessage"

        data = {
            "chat_id": telegram_id,
            "text": message_text,
            "parse_mode": "HTML"
        }

        requests.post(url, data=data)
    except Exception as e:
        print(f"Ошибка отправки Telegram уведомления: {e}")

def get_status_display(status):
    """Возвращает человекочитаемый статус"""
    return {
        'pending': 'На рассмотрении ⏳',
        'approved': 'Одобрена ✅',
        'rejected': 'Отклонена ❌'
    }.get(status, 'Неизвестно')