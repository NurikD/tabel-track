from django.contrib.auth.models import AbstractUser
from django.db import models
from django.conf import settings
from django.utils import timezone
from datetime import date


class Department(models.Model):
    name = models.CharField(max_length=100, unique=True)

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

    department = models.ForeignKey(Department, on_delete=models.SET_NULL, null=True, blank=True)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='worker')
    gender = models.CharField(max_length=10, choices=GENDER_CHOICES, default='male')
    shift_type = models.CharField(max_length=10, choices=SHIFT_CHOICES, default='5_2')
    shift_start_date = models.DateField(null=True, blank=True, default=date(2024, 1, 1))
    position = models.CharField(max_length=100, choices=POSITION_CHOICES, blank=True, verbose_name='Должность')
    # Личная информация
    middle_name = models.CharField("Отчество", max_length=50, blank=True)
    birth_date = models.DateField("Дата рождения", null=True, blank=True)
    marital_status = models.CharField("Семейное положение", max_length=50, blank=True)

    # Рабочая информация
    employee_id = models.CharField("Табельный номер", max_length=20, blank=True, unique=True)
    department = models.CharField("Подразделение", max_length=100, blank=True)
    manager = models.CharField("Руководитель", max_length=100, blank=True)
    hire_date = models.DateField("Дата приема на работу", null=True, blank=True)
    contract_type = models.CharField("Тип трудового договора", max_length=50, blank=True)

    # Контактная информация
    work_email = models.EmailField("Рабочий email", blank=True)
    personal_email = models.EmailField("Личный email", blank=True)
    work_phone = models.CharField("Рабочий телефон", max_length=20, blank=True)
    mobile_phone = models.CharField("Мобильный телефон", max_length=20, blank=True)
    address = models.TextField("Адрес проживания", blank=True)

    # Telegram интеграция
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
        """Подсчет оставшихся дней отпуска (простая заглушка)"""
        if not self.hire_date:
            return 0
        # Логика может быть расширена, например, с учетом использованных отпусков
        total_days = 28  # Базовый отпуск
        return total_days  # Временная реализация

    class Meta:
        verbose_name = "Пользователь"
        verbose_name_plural = "Пользователи"


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

    @property
    def days_duration(self):
        """Возвращает длительность отпуска в днях"""
        if self.start_date and self.end_date:
            return (self.end_date - self.start_date).days + 1
        return 0

    class Meta:
        verbose_name = "Заявка на отпуск"
        verbose_name_plural = "Заявки на отпуск"
        ordering = ['-created_at']


class TelegramLinkCode(models.Model):
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE)
    code = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)
    is_used = models.BooleanField(default=False)  # Флаг использования кода

    def __str__(self):
        return f"Код {self.code} для {self.user.get_full_name()}"

    class Meta:
        verbose_name = "Код привязки Telegram"
        verbose_name_plural = "Коды привязки Telegram"