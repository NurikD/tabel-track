# utils/django_setup.py
import os
import sys
import django
from pathlib import Path

# Получаем путь к корню Django проекта (на 2 уровня выше)
BASE_DIR = Path(__file__).resolve().parent.parent.parent

# Добавляем корневую директорию в sys.path
if str(BASE_DIR) not in sys.path:
    sys.path.insert(0, str(BASE_DIR))

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'tabelTrack.settings')

try:
    django.setup()
    print("✅ Django успешно настроен")
except Exception as e:
    print(f"❌ Ошибка настройки Django: {e}")
    raise