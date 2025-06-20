from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser, LeaveRequest
from django.utils.translation import gettext_lazy as _

@admin.register(CustomUser)
class CustomUserAdmin(UserAdmin):
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
    list_display = ['username', 'email', 'first_name', 'last_name', 'middle_name', 'position', 'role', 'department', 'hire_date']
    list_filter = ['role', 'shift_type', 'gender', 'department', 'hire_date']
    search_fields = ['username', 'first_name', 'last_name', 'email', 'department', 'middle_name']
    list_editable = ['role', 'position']
    list_per_page = 25
    ordering = ['last_name', 'first_name']

    def get_queryset(self, request):
        queryset = super().get_queryset(request)
        return queryset

@admin.register(LeaveRequest)
class LeaveRequestAdmin(admin.ModelAdmin):
    list_display = ['user', 'leave_type', 'start_date', 'end_date', 'status', 'created_at', 'days_duration']
    list_filter = ['leave_type', 'status', 'start_date', 'end_date', 'created_at']
    search_fields = ['user__username', 'user__first_name', 'user__last_name', 'leave_type', 'status']
    list_per_page = 25
    date_hierarchy = 'start_date'
    ordering = ['-created_at']

    def days_duration(self, obj):
        return (obj.end_date - obj.start_date).days + 1 if obj.start_date and obj.end_date else 0
    days_duration.short_description = 'Дней'

    list_editable = ['status']

    def get_queryset(self, request):
        queryset = super().get_queryset(request)
        return queryset.select_related('user')