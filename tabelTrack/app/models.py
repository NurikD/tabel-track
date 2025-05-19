from django.contrib.auth.models import AbstractUser
from django.db import models
from django.conf import settings
from django.utils import timezone

class CustomUser(AbstractUser):
    ROLE_CHOICES = [
        ('worker', 'Сотрудник'),
        ('editor', 'Редактор'),
        ('approver', 'Согласующий'),
        ('admin', 'Администратор'),
    ]
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='worker')

    def __str__(self):
        return self.get_full_name()

class LeaveRequest(models.Model):
TYPE_CHOICES = [
    ('vacation', 'Ежегодный оплачиваемый отпуск'),
    ('sick', 'Больничный'),
    ('study', 'Учебный отпуск'),
    ('business', 'Командировка'),
    ('unpaid', 'Отпуск без сохранения ЗП'),
    ('maternity', 'Декретный отпуск'),
    ('childcare', 'Отпуск по уходу за ребёнком'),
    ('other', 'Прочее')
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
        return f"{self.user.get_full_name()} - {self.leave_type} {self.start_date} → {self.end_date}"