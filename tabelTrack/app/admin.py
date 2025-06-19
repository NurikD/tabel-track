from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser, LeaveRequest


@admin.register(CustomUser)
class CustomUserAdmin(UserAdmin):
    fieldsets = UserAdmin.fieldsets + (
        ('Дополнительно', {
            'fields': (
                'role',
                'gender',
                'shift_type',
                'shift_start_date',
                'position',
                'telegram_id',
            )
        }),
    )
    list_display = ['username', 'email', 'first_name', 'last_name', 'position', 'role']
    list_filter = ['role', 'shift_type']
    search_fields = ['username', 'first_name', 'last_name', 'email']


@admin.register(LeaveRequest)
class LeaveRequestAdmin(admin.ModelAdmin):
    list_display = ['user', 'leave_type', 'start_date', 'end_date', 'status', 'created_at']
    list_filter = ['leave_type', 'status', 'created_at']
    search_fields = ['user__username', 'user__first_name', 'user__last_name']

