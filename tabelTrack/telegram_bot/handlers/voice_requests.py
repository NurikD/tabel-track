from aiogram import Router, types
from aiogram.types import InlineKeyboardMarkup, InlineKeyboardButton
from app.models import CustomUser, LeaveRequest
from asgiref.sync import sync_to_async
from django.utils import timezone
from datetime import datetime, date, timedelta
from django.db.models import F, ExpressionWrapper, fields
from app.tasks import notify_approver_telegram

import tempfile, subprocess, os, re
import speech_recognition as sr

router = Router()

# Временное хранилище для заявок
PENDING_REQUESTS = {}

WORDS_TO_NUM = {
    "первого": 1, "второго": 2, "третьего": 3, "четвертого": 4, "пятого": 5,
    "шестого": 6, "седьмого": 7, "восьмого": 8, "девятого": 9, "десятого": 10,
    "одиннадцатого": 11, "двенадцатого": 12, "тринадцатого": 13, "четырнадцатого": 14,
    "пятнадцатого": 15, "шестнадцатого": 16, "семнадцатого": 17, "восемнадцатого": 18,
    "девятнадцатого": 19, "двадцатого": 20, "двадцать первого": 21, "двадцать второго": 22,
    "двадцать третьего": 23, "двадцать четвёртого": 24, "двадцать пятого": 25,
    "двадцать шестого": 26, "двадцать седьмого": 27, "двадцать восьмого": 28,
    "двадцать девятого": 29, "тридцатого": 30, "тридцать первого": 31,
    "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "10": 10,
    "11": 11, "12": 12, "13": 13, "14": 14, "15": 15, "16": 16, "17": 17, "18": 18, "19": 19,
    "20": 20, "21": 21, "22": 22, "23": 23, "24": 24, "25": 25, "26": 26, "27": 27, "28": 28,
    "29": 29, "30": 30, "31": 31,
}

MONTHS = {
    "января": 1, "февраля": 2, "марта": 3, "апреля": 4, "мая": 5, "июня": 6,
    "июля": 7, "августа": 8, "сентября": 9, "октября": 10, "ноября": 11, "декабря": 12,
}

@router.message(lambda msg: msg.voice)
async def handle_voice_request(message: types.Message):
    user = await sync_to_async(CustomUser.objects.filter(telegram_id=message.from_user.id).first)()
    if not user:
        await message.answer("❗ Привяжите Telegram к аккаунту.")
        return

    await message.answer("🎤 Распознаю голосовое сообщение...")

    # Скачивание и конвертация
    file = await message.bot.get_file(message.voice.file_id)
    ogg = tempfile.mktemp(suffix=".ogg")
    wav = ogg.replace(".ogg", ".wav")
    await message.bot.download_file(file.file_path, ogg)
    subprocess.run(["ffmpeg", "-i", ogg, wav], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    recognizer = sr.Recognizer()
    with sr.AudioFile(wav) as source:
        audio = recognizer.record(source)

    try:
        text = recognizer.recognize_google(audio, language="ru-RU")
        print(f"[VOICE TEXT]: {text}")
    except:
        await message.answer("❌ Не удалось распознать речь.")
        os.remove(ogg), os.remove(wav)
        return
    finally:
        os.remove(ogg), os.remove(wav)

    text = text.lower()

    # Тип отпуска
    type_match = re.search(r"(отпуск|больничный|командировка)", text)
    if not type_match:
        await message.answer("❌ Не удалось определить тип отпуска.")
        return

    leave_type_map = {
        "отпуск": "vacation",
        "больничный": "sick",
        "командировка": "business",
    }
    leave_type = leave_type_map[type_match.group(1)]

    # Поиск даты: "с первого по 16 ноября" или "на 19 декабря"
    date_match = re.search(
        r"(?:с\s+(\w+)(?:\s+по\s+(\w+))?|(на)\s+(\w+))\s+(января|февраля|марта|апреля|мая|июня|июля|августа|сентября|октября|ноября|декабря)",
        text
    )

    if not date_match:
        await message.answer(f"🗣 Текст: {text}\n\n⚠ Не удалось распознать даты.")
        return

    try:
        current_year = date.today().year
        # Если есть "с ... по ..." (группы 1 и 2)
        if date_match.group(1):
            start_day = WORDS_TO_NUM[date_match.group(1)]
            end_day = WORDS_TO_NUM.get(date_match.group(2), start_day)  # Если "по" не указано, то один день
            month = MONTHS[date_match.group(5)]
        # Если есть "на ..." (группы 3 и 4)
        else:
            start_day = WORDS_TO_NUM[date_match.group(4)]
            end_day = start_day  # Один день
            month = MONTHS[date_match.group(5)]

        start_date = date(current_year, month, start_day)
        end_date = date(current_year, month, end_day)

        if start_date > end_date:
            start_date, end_date = end_date, start_date
    except:
        await message.answer("❌ Ошибка при обработке дат.")
        return

    # Проверка перекрытия заявок
    overlapping = await sync_to_async(
        lambda: LeaveRequest.objects.filter(
            user=user,
            status__in=['pending', 'approved'],
            start_date__lte=end_date,
            end_date__gte=start_date
        ).exists()
    )()
    if overlapping:
        await message.answer("❌ У вас уже есть заявка, перекрывающая эти даты.")
        return

    # Проверка лимита отпуска
    total_used = await sync_to_async(
        lambda: sum(
            (r.end_date - r.start_date).days + 1
            for r in LeaveRequest.objects.filter(
                user=user,
                leave_type='vacation',
                status='approved'
            )
        )
    )()

    available_days = 44 - total_used
    requested_days = (end_date - start_date).days + 1

    if leave_type == "vacation" and requested_days > available_days:
        await message.answer(
            f"❌ Превышен лимит отпуска: доступно {available_days} дн., запрашиваете {requested_days}."
        )
        return

    # Проверка на обязательный 14-дневный отпуск
    if leave_type == "vacation":
        has_14day = await sync_to_async(
            lambda: LeaveRequest.objects.filter(
                user=user,
                leave_type='vacation',
                status='approved'
            ).annotate(
                days=ExpressionWrapper(
                    F('end_date') - F('start_date') + timedelta(days=1),
                    output_field=fields.DurationField()
                )
            ).filter(days__gte=timedelta(days=14)).exists()
        )()
        if not has_14day and requested_days < 14:
            await message.answer("⚠️ По ТК РФ хотя бы один отпуск в году должен быть не менее 14 дней.")

    # Формирование текста заявки
    leave_type_text = type_match.group(1)
    request_text = (
        f"📝 Новая заявка:\n"
        f"Тип: {leave_type_text}\n"
        f"С {start_date.strftime('%d.%m.%Y')} по {end_date.strftime('%d.%m.%Y')}\n"
        f"Длительность: {requested_days} дн.\n\n"
        f"Подтвердить или отменить?"
    )

    # Создание кнопок
    markup = InlineKeyboardMarkup(inline_keyboard=[
        [
            InlineKeyboardButton(text="✅ Подтвердить", callback_data=f"confirm_{message.message_id}"),
            InlineKeyboardButton(text="❌ Отмена", callback_data=f"cancel_{message.message_id}")
        ]
    ])

    # Сохранение данных заявки во временное хранилище
    PENDING_REQUESTS[message.message_id] = {
        "user": user,
        "leave_type": leave_type,
        "start_date": start_date,
        "end_date": end_date,
        "leave_type_text": leave_type_text,
        "type_match": type_match
    }

    # Отправка сообщения с кнопками
    await message.answer(request_text, reply_markup=markup)

@router.callback_query(lambda c: c.data.startswith(("confirm_", "cancel_")))
async def handle_confirmation(callback: types.CallbackQuery):
    action, message_id = callback.data.split("_")
    message_id = int(message_id)

    # Получение данных заявки
    request_data = PENDING_REQUESTS.get(message_id)
    if not request_data:
        await callback.message.edit_text("⏳ Заявка устарела или уже обработана.")
        await callback.answer()
        return

    user = request_data["user"]
    leave_type = request_data["leave_type"]
    start_date = request_data["start_date"]
    end_date = request_data["end_date"]
    leave_type_text = request_data["leave_type_text"]
    type_match = request_data["type_match"]

    if action == "confirm":
        # Создание заявки
        leave = LeaveRequest(
            user=user,
            leave_type=leave_type,
            start_date=start_date,
            end_date=end_date,
            status='pending',
            created_at=timezone.now()
        )
        await sync_to_async(leave.save)()

        # Уведомление руководителю
        notify_approver_telegram.delay(
            request_id=leave.id,
            employee_full_name=user.full_name,
            leave_type=leave_type,
            start_date=start_date.strftime('%d.%m.%Y'),
            end_date=end_date.strftime('%d.%m.%Y')
        )

        # Обновление сообщения
        await callback.message.edit_text(
            f"✅ Заявка на {leave_type_text} с {start_date.strftime('%d.%m')} по {end_date.strftime('%d.%m')} создана!",
            reply_markup=None
        )
    else:
        # Отмена заявки
        await callback.message.edit_text(
            "❌ Заявка отменена.",
            reply_markup=None
        )

    # Удаление данных из хранилища
    del PENDING_REQUESTS[message_id]
    await callback.answer()