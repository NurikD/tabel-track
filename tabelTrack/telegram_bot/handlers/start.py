from aiogram import Router, types
from aiogram.filters import Command
from asgiref.sync import sync_to_async
from app.models import CustomUser

router = Router()

@router.message(Command("start"))
async def start(message: types.Message):
    tg_id = message.from_user.id

    user = await sync_to_async(CustomUser.objects.filter(telegram_id=tg_id).first)()

    if user:
        text = (
            f"👋 Привет, {user.full_name}!\n"
            f"📌 Должность: {user.get_position_display()}\n"
            f"📅 Остаток отпуска: {user.get_remaining_vacation_days()} дн."
        )
    else:
        text = (
            "😐 Ты не авторизован.\n"
            "Зайди в личный кабинет на сайте и привяжи Telegram."
        )

    await message.answer(text)
