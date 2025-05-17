from django.contrib import admin
from django.urls import path, include
from . import views

urlpatterns = [
    path('', views.dashboard, name='dashboard'),
    path('attendance/', views.attendance, name='attendance'),
    path('leave/request/', views.leave_request, name='leave_request'),
    path('attendance/edit/', views.edit_attendance, name='edit_attendance'),
    path('leave/approve/', views.approve_requests, name='approve_requests'),
    path('admin/users/', views.user_management, name='user_management'),
    path('accounts/', include('django.contrib.auth.urls')),
]
