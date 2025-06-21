from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.utils.translation import gettext_lazy as _
from .models import CustomUser, LeaveRequest, TelegramLinkCode
from django.core.exceptions import ValidationError

# Кастомная валидация для employee_id
def validate_unique_employee_id(value):
    if value and CustomUser.objects.filter(employee_id=value).exists():
        raise ValidationError("Табельный номер должен быть уникальным.")

@admin.register(CustomUser)
class CustomUserAdmin(UserAdmin):
    # Поля для редактирования существующего пользователя
    fieldsets = (
        (None, {'fields': ('username', 'password')}),
        (_('Личная информация'), {
            'fields': ('first_name', 'last_name', 'middle_name', 'birth_date', 'gender', 'marital_status')
        }),
        (_('Права доступа'), {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        (_('Важные даты'), {'fields': ('last_login', 'date_joined')}),
        (_('Дополнительно'), {
            'fields': (
                'role',
                'shift_type',
                'shift_start_date',
                'position',
                'department',
                'manager',
                'hire_date',
                'contract_type',
                'employee_id',
                'work_email',
                'personal_email',
                'work_phone',
                'mobile_phone',
                'address',
                'telegram_id',
            )
        }),
    )

    # Поля для создания нового пользователя
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('username', 'password1', 'password2', 'employee_id', 'first_name', 'last_name', 'middle_name',
                      'personal_email', 'role', 'position', 'department', 'hire_date'),
        }),
    )

    # Отображаемые столбцы в списке
    list_display = ['username', 'full_name', 'personal_email', 'position', 'role', 'department', 'hire_date', 'employee_id']
    list_filter = ['role', 'shift_type', 'gender', 'department', 'hire_date']
    search_fields = ['username', 'first_name', 'last_name', 'middle_name', 'personal_email', 'department', 'employee_id']
    list_editable = ['role', 'position']
    list_per_page = 25
    ordering = ['last_name', 'first_name']

    # Переопределение метода save_model для синхронизации email и personal_email
    def save_model(self, request, obj, form, change):
        if obj.personal_email and obj.email != obj.personal_email:
            obj.email = obj.personal_email  # Синхронизация email с personal_email
        super().save_model(request, obj, form, change)

    # Кастомный метод для отображения полного имени
    def full_name(self, obj):
        return obj.get_full_name()
    full_name.short_description = 'Полное имя'

    # Валидация формы
    def get_form(self, request, obj=None, **kwargs):
        form = super().get_form(request, obj, **kwargs)
        form.base_fields['employee_id'].validators.append(validate_unique_employee_id)
        return form

    def get_queryset(self, request):
        return super().get_queryset(request).prefetch_related('groups')

@admin.register(LeaveRequest)
class LeaveRequestAdmin(admin.ModelAdmin):
    list_display = ['user', 'leave_type', 'start_date', 'end_date', 'status', 'created_at', 'days_duration']
    list_filter = ['leave_type', 'status', 'start_date', 'end_date', 'created_at', 'reviewed_by']
    search_fields = ['user__username', 'user__first_name', 'user__last_name', 'leave_type', 'status', 'comment']
    list_per_page = 25
    date_hierarchy = 'start_date'
    ordering = ['-created_at']

    # Кастомный метод для отображения длительности
    def days_duration(self, obj):
        return (obj.end_date - obj.start_date).days + 1 if obj.start_date and obj.end_date else 0
    days_duration.short_description = 'Дней'

    # Редактируемые поля в списке
    list_editable = ['status']

    # Оптимизация запросов
    def get_queryset(self, request):
        return super().get_queryset(request).select_related('user', 'reviewed_by')

@admin.register(TelegramLinkCode)
class TelegramLinkCodeAdmin(admin.ModelAdmin):
    list_display = ['user', 'code', 'created_at', 'is_used']
    list_filter = ['is_used', 'created_at']
    search_fields = ['user__username', 'user__first_name', 'user__last_name', 'code']
    list_per_page = 25
    ordering = ['-created_at']

    # Оптимизация запросов
    def get_queryset(self, request):
        return super().get_queryset(request).select_related('user')