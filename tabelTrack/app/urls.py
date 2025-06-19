from django.contrib import admin
from django.urls import path, include
from . import views
from django.contrib.auth.decorators import login_required, user_passes_test

# Проверки ролей (уже определены в views.py)
def is_worker(user): return user.role == 'worker'
def is_editor(user): return user.role == 'editor'
def is_approver(user): return user.role == 'approver'

urlpatterns = [
    # Главная страница (дашборд, адаптируется по роли)
    path('', login_required(views.dashboard), name='dashboard'),

    # Посещаемость
    path('attendance/', login_required(user_passes_test(is_worker)(views.attendance)), name='attendance'),

    # Подать заявку на отпуск/больничный
    path('leave/request/', login_required(user_passes_test(is_worker)(views.leave_request)), name='leave_request'),

    # Редактирование табеля
    path('attendance/edit/', login_required(user_passes_test(is_editor)(views.edit_attendance)), name='edit_attendance'),

    # Согласование заявок
    path('leave/approve/', login_required(user_passes_test(is_approver)(views.approve_requests)), name='approve_requests'),

    # Управление пользователями (для админа)
    path('admin/users/', login_required(user_passes_test(lambda u: u.role == 'admin')(views.user_management)), name='user_management'),

    # Аутентификация
    path('accounts/', include('django.contrib.auth.urls')),
]

