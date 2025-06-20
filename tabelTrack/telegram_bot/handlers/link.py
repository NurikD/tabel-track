from aiogram import Router, types
from aiogram.filters import CommandObject, Command
from app.models import TelegramLinkCode
from django.utils import timezone
from asgiref.sync import sync_to_async

router = Router()

@router.message(Command("link"))
async def link_account(message: types.Message, command: CommandObject):
    code = command.args
    if not code:
        await message.answer("❗ Использование: /link <код_подтверждения>")
        return

    try:
        link_code = await sync_to_async(
            lambda: TelegramLinkCode.objects.select_related('user').get(code=code, is_used=False)
        )()
    except TelegramLinkCode.DoesNotExist:
        await message.answer("🚫 Код не найден или уже использован.")
        return

    user = link_code.user
    user.telegram_id = message.from_user.id
    # Wrap user.save() in sync_to_async
    await sync_to_async(user.save)()

    link_code.is_used = True
    # Wrap link_code.save() in sync_to_async
    await sync_to_async(link_code.save)()

    await message.answer(f"✅ Привязка прошла успешно, {user.full_name}!")