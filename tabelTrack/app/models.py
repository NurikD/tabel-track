from django.contrib.auth.models import AbstractUser
from django.db import models
from django.conf import settings
from django.utils import timezone
from datetime import date

from datetime import date
from django.contrib.auth.models import AbstractUser
from django.db import models


class CustomUser(AbstractUser):
    ROLE_CHOICES = [
        ('worker', 'Сотрудник'),
        ('editor', 'Редактор'),
        ('approver', 'Согласующий'),
        ('admin', 'Администратор'),
    ]
    GENDER_CHOICES = [
        ('male', 'Мужской'),
        ('female', 'Женский'),
    ]
    SHIFT_CHOICES = [
        ('5_2', 'Пятидневка (5/2)'),
        ('2_2', 'Сменный график (2/2)'),
        ('1_3', 'Один через три (1/3)'),
        ('custom', 'Произвольный график'),
    ]
    POSITION_CHOICES = [
        ('master', 'Мастер по обслуживанию абонентов'),
        ('specialist', 'Универсальный специалист связи'),
        ('engineer', 'Инженер'),
        ('service_engineer', 'Сервисный инженер'),
        ('support', 'Специалист по сопровождению'),
        ('lead_engineer', 'Ведущий Инженер'),
        ('chief', 'Начальник участка'),
    ]

    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='worker')
    gender = models.CharField(max_length=10, choices=GENDER_CHOICES, default='male')
    shift_type = models.CharField(max_length=10, choices=SHIFT_CHOICES, default='5_2')
    shift_start_date = models.DateField(null=True, blank=True, default=date(2024, 1, 1))
    position = models.CharField(max_length=100, choices=POSITION_CHOICES, blank=True, verbose_name='Должность')

    # Добавляем поле для Telegram ID
    telegram_id = models.BigIntegerField(
        unique=True,
        null=True,
        blank=True,
        verbose_name="Telegram ID",
        help_text="ID пользователя в Telegram для связи с ботом"
    )

    def __str__(self):
        return self.get_full_name()

    @property
    def full_name(self):
        """Возвращает полное имя пользователя"""
        return f"{self.first_name} {self.last_name}".strip() or self.username

    def get_remaining_vacation_days(self):
        """Заглушка для подсчета оставшихся дней отпуска"""
        # Здесь можете добавить логику подсчета
        return 28  # Временное значение


class LeaveRequest(models.Model):
    TYPE_CHOICES = [
        ('vacation', 'Ежегодный оплачиваемый отпуск'),
        ('sick', 'Больничный лист'),
        ('study', 'Учебный отпуск'),
        ('business', 'Командировка'),
        ('unpaid', 'Отпуск без сохранения заработной платы'),
        ('maternity', 'Декретный отпуск'),
        ('childcare', 'Отпуск по уходу за ребёнком'),
        ('other', 'Прочий отпуск'),
    ]

    STATUS_CHOICES = [
        ('pending', 'На рассмотрении'),
        ('approved', 'Одобрено'),
        ('rejected', 'Отклонено'),
    ]

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    leave_type = models.CharField(max_length=20, choices=TYPE_CHOICES)
    start_date = models.DateField()
    end_date = models.DateField()
    comment = models.TextField(blank=True)

    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    reviewed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='reviewed_requests'
    )
    reviewed_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        readable_type = dict(self.TYPE_CHOICES).get(self.leave_type, self.leave_type)
        return f"{self.user.get_full_name()} — {readable_type} с {self.start_date} по {self.end_date}"


# models.py
class TelegramLinkCode(models.Model):
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE)
    code = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)
    is_used = models.BooleanField(default=False)  # ← добавь это
