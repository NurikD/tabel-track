# app/tasks.py
from aiohttp import request
import requests
from celery import shared_task
from django.core.mail import send_mail
from django.conf import settings
import asyncio
import json
from .models import CustomUser, LeaveRequest

@shared_task
def notify_approver_email(employee_full_name, leave_type, start_date, end_date, approver_email):
    subject = f"📩 Новая заявка на {leave_type}"
    message = (
        f"Сотрудник {employee_full_name} подал заявку на {leave_type} "
        f"с {start_date} по {end_date}.\n\n"
        f"Пожалуйста, согласуйте заявку в системе."
    )
    send_mail(
        subject,
        message,
        settings.DEFAULT_FROM_EMAIL,
        [approver_email],
        fail_silently=False
    )

@shared_task
def send_result_to_employee(employee_email, leave_type, start_date, end_date, status):
    subject = f"📝 Ваша заявка на {leave_type} {status_display(status)}"
    message = (
        f"Ваша заявка на {leave_type} с {start_date} по {end_date} была {status_display(status)}.\n\n"
        f"Спасибо!"
    )
    send_mail(
        subject,
        message,
        settings.DEFAULT_FROM_EMAIL,
        [employee_email],
        fail_silently=False
    )

@shared_task
def notify_approver_telegram(request_id, employee_full_name, leave_type, start_date, end_date):
    """Отправка уведомления руководителю в Telegram с кнопками согласования"""
    try:
        # Получаем всех approver'ов с telegram_id
        approvers = CustomUser.objects.filter(
            role='approver',
            telegram_id__isnull=False
        )


        if not approvers:
            print("Нет руководителей с привязанным Telegram")
            return

        # Текст уведомления
        message_text = (
            f"📋 Новая заявка на согласование\n\n"
            f"👤 Сотрудник: {employee_full_name}\n"
            f"📅 Тип: {leave_type}\n"
            f"🗓 Период: {start_date} - {end_date}\n\n"
            f"Выберите действие:"
        )

        # Инлайн клавиатура для согласования
        keyboard = {
            "inline_keyboard": [
                [
                    {"text": "✅ Одобрить", "callback_data": f"approve_{request_id}"},
                    {"text": "❌ Отклонить", "callback_data": f"reject_{request_id}"}
                ],
                [
                    {"text": "📋 Подробности", "callback_data": f"details_{request_id}"}
                ]
            ]
        }

        # Отправка каждому руководителю
        for approver in approvers:
            send_telegram_message.delay(
                chat_id=approver.telegram_id,
                text=message_text.replace("{approver_name}", approver.full_name),
                reply_markup=keyboard
            )


    except Exception as e:
        print(f"Ошибка отправки Telegram уведомления: {e}")

@shared_task
def notify_employee_telegram(employee_telegram_id, leave_type, start_date, end_date, status):
    """Уведомление сотрудника о результате рассмотрения заявки"""
    if not employee_telegram_id:
        return

    status_emoji = {
        'approved': '✅',
        'rejected': '❌',
        'pending': '⏳'
    }

    message_text = (
        f"{status_emoji.get(status, '📝')} Статус заявки обновлен\n\n"
        f"📅 Тип: {leave_type}\n"
        f"🗓 Период: {start_date} - {end_date}\n"
        f"📊 Статус: {status_display(status)}"
    )

    send_telegram_message.delay(
        chat_id=employee_telegram_id,
        text=message_text
    )

@shared_task
def send_telegram_message(chat_id, text, reply_markup=None):
    try:
        bot_token = settings.TELEGRAM_BOT_TOKEN
        url = f"https://api.telegram.org/bot{bot_token}/sendMessage"

        data = {
            "chat_id": chat_id,
            "text": text,
            "parse_mode": "HTML"
        }

        if reply_markup:
            data["reply_markup"] = json.dumps(reply_markup)

        print("📤 Отправка в Telegram:", data)

        response = requests.post(url, data=data)

        print("📨 Ответ Telegram:", response.status_code, response.text)

        if response.status_code != 200:
            print("❌ Ошибка отправки:", response.text)

    except Exception as e:
        print(f"❌ Ошибка в send_telegram_message: {e}")

def status_display(status):
    return {
        'approved': 'одобрена ✅',
        'rejected': 'отклонена ❌',
        'pending': 'на рассмотрении ⏳'
    }.get(status, 'обработана')