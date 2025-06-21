# handlers/log_messages.py
from aiogram import Router, types
from app.models import CustomUser
from asgiref.sync import sync_to_async

router = Router()

@router.message()
async def handle_any_message(message: types.Message):
    sender = await sync_to_async(CustomUser.objects.filter(telegram_id=message.from_user.id).first)()

    if not sender:
        print(f"[Сообщение от неизвестного пользователя {message.from_user.id}]: {message.text}")
        return

    # Лог текстовых сообщений
    if message.text:
        print(f"[Сообщение от {sender.full_name}]: {message.text}")

    # Лог стикеров
    if message.sticker:
        print(f"[Стикер от {sender.full_name}]: emoji={message.sticker.emoji}, id={message.sticker.file_id}")

    # Голосовое сообщение → отправим его approver'ам
    if message.voice:
        print(f"[Голосовое сообщение от {sender.full_name}]")
        approvers = await sync_to_async(
            lambda: list(CustomUser.objects.filter(role='approver', telegram_id__isnull=False))
        )()

        for approver in approvers:
            try:
                await message.copy_to(chat_id=approver.telegram_id)
            except Exception as e:
                print(f"Ошибка при пересылке голосового {approver.full_name}: {e}")
