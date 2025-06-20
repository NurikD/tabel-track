# bot.py
from aiogram import Bot, Dispatcher
from config import TELEGRAM_BOT_TOKEN
from utils.django_setup import *
from handlers import start, link, approve

bot = Bot(token=TELEGRAM_BOT_TOKEN)
dp = Dispatcher()

# ✅ Регистрируем ВСЕ роутеры до запуска
dp.include_router(start.router)
dp.include_router(link.router)
dp.include_router(approve.router)


if __name__ == "__main__":
    import asyncio
    asyncio.run(dp.start_polling(bot))
