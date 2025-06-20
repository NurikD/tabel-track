from dotenv import load_dotenv
import os

load_dotenv()  # загружаем .env из корня проекта

TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")

if not TELEGRAM_BOT_TOKEN:
    raise ValueError("❌ TELEGRAM_BOT_TOKEN не найден в .env")
