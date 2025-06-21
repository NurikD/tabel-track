from django.apps import AppConfig


class AppConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'app'


from django.test import TestCase
from django.core.exceptions import ValidationError


class RequestModelTest(TestCase):
    def test_invalid_date_range(self):
        from .models import Request
        with self.assertRaises(ValidationError):
            Request.objects.create(
                user_id=1,
                type='отпуск',
                start_date='2025-06-15',
                end_date='2025-06-10'  # Ошибка: дата окончания раньше начала
            ).full_clean()


# from django.apps import AppConfig
# import threading

# class AppConfig(AppConfig):
#     default_auto_field = 'django.db.models.BigAutoField'
#     name = 'app'

#     def ready(self):
#         from django.conf import settings
#         from app.models import CustomUser
#         from app.tasks import send_telegram_message

#         def send_start_message():
#             try:
#                 # Отправим только администратору (или всем привязанным)
#                 users = CustomUser.objects.filter(telegram_id__isnull=False, is_superuser=True)

#                 for user in users:
#                     send_telegram_message.delay(
#                         chat_id=user.telegram_id,
#                         text="иди нахуй"
#                     )
#             except Exception as e:
#                 print(f"[ready()] Ошибка отправки Telegram: {e}")

#         threading.Thread(target=send_start_message).start()
