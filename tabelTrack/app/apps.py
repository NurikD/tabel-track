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
