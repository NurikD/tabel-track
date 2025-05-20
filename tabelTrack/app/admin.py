from django.contrib import admin
from .models import CustomUser, LeaveRequest
from django.contrib.auth.admin import UserAdmin

@admin.register(CustomUser)
class CustomUserAdmin(UserAdmin):
    fieldsets = UserAdmin.fieldsets + (
        ('Дополнительно', {
            'fields': ('role', 'gender', 'shift_type', 'shift_start_date')  # добавляем поле в интерфейс
        }),
    )
    list_display = ['username', 'email', 'first_name', 'last_name', 'role', 'shift_type']
    list_filter = ['role', 'shift_type']

@admin.register(LeaveRequest)
class LeaveRequestAdmin(admin.ModelAdmin):
    list_display = ['user', 'leave_type', 'start_date', 'end_date', 'status', 'created_at']
    list_filter = ['leave_type', 'status', 'created_at']
    search_fields = ['user__username', 'user__first_name', 'user__last_name']
