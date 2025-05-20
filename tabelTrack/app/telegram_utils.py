# telegram_utils.py
from aiogram import Bot
import os
from dotenv import load_dotenv
from app.models import CustomUser  # Убедитесь, что путь к модели правильный

# Загрузка переменных окружения
load_dotenv()

BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")

if not BOT_TOKEN:
    raise ValueError("BOT_TOKEN не установлен в .env файле")

# Создаем экземпляр бота
bot = Bot(token=BOT_TOKEN)

async def notify_approvers(text: str):
    """
    Отправка уведомлений согласующим (пользователи с ролью 'approver').
    """
    # Получаем всех согласующих с Telegram ID
    approvers = CustomUser.objects.filter(role='approver', telegram_id__isnull=False)
    
    for approver in approvers:
        try:
            # Отправляем уведомление каждому согласующему
            await bot.send_message(chat_id=approver.telegram_id, text=text)
            print(f"✔️ Уведомление отправлено: {approver.get_full_name()}")
        except Exception as e:
            print(f"❌ Ошибка при отправке сообщения: {e}")
