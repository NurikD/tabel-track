from datetime import date
from calendar import monthrange
from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required, user_passes_test
from .forms import LeaveRequestForm
from .models import LeaveRequest, CustomUser, TelegramLink
from django.utils.timezone import now
from django.contrib import messages
from django.db.models import Q
from utils.holidays import get_holidays_from_api
from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
import json, asyncio
from app.telegram_utils import notify_approvers
import random
from django.contrib.auth import authenticate
from asgiref.sync import sync_to_async


# Ролевые проверки
def is_worker(user): return user.role == 'worker'
def is_editor(user): return user.role == 'editor'
def is_approver(user): return user.role == 'approver'
def is_admin(user): return user.role == 'admin'


# Главная страница — дашборд
@login_required
def dashboard(request):
    user = request.user
    today = date.today()

    # Если сотрудник (worker)
    if user.role == 'worker':
        vacation = LeaveRequest.objects.filter(user=user, leave_type='vacation', status='approved')
        sick = LeaveRequest.objects.filter(user=user, leave_type='sick', status='approved')

        vacation_days = sum((r.end_date - r.start_date).days + 1 for r in vacation)
        sick_days = sum((r.end_date - r.start_date).days + 1 for r in sick)
        absent_days = 0  # пока заглушка
        worked_days = 14  # заглушка

        my_requests = LeaveRequest.objects.filter(user=user).order_by('-created_at')[:5]

        return render(request, 'dashboard.html', {
            'user': user,
            'worked_days': worked_days,
            'vacation_days': vacation_days,
            'sick_days': sick_days,
            'absent_days': absent_days,
            'my_requests': my_requests,
        })

    # Для согласующего, редактора, админа — общая информация
    team_members = CustomUser.objects.filter(role='worker')
    total_employees = team_members.count()

    active_requests_today = LeaveRequest.objects.filter(
        status='approved',
        start_date__lte=today,
        end_date__gte=today
    )
    today_vacation = active_requests_today.filter(leave_type='vacation').count()
    today_sick = active_requests_today.filter(leave_type='sick').count()
    today_present = total_employees - today_vacation - today_sick

    stats = {
        "today_present": today_present,
        "today_sick": today_sick,
        "today_vacation": today_vacation,
        "total_employees": total_employees,
    }

    team_requests = LeaveRequest.objects.filter(user__role='worker').order_by('-created_at')[:5]

    detailed_members = []
    for member in team_members:
        vacation = LeaveRequest.objects.filter(user=member, leave_type='vacation', status='approved')
        sick = LeaveRequest.objects.filter(user=member, leave_type='sick', status='approved')

        vacation_days = sum((r.end_date - r.start_date).days + 1 for r in vacation)
        sick_days = sum((r.end_date - r.start_date).days + 1 for r in sick)
        worked_days = 14  # заглушка

        detailed_members.append({
            'get_full_name': member.get_full_name(),
            'position': member.get_position_display() if hasattr(member, 'get_position_display') else member.position,
            'vacation_days': vacation_days,
            'sick_days': sick_days,
            'worked_days': worked_days,
        })

    return render(request, 'dashboard.html', {
        'user': user,
        'stats': stats,
        'team_requests': team_requests,
        'team_members': detailed_members,
    })


# Табель
@login_required
@user_passes_test(is_worker)
def attendance(request):
    today = date.today()
    year = int(request.GET.get('year', today.year))
    month = int(request.GET.get('month', today.month))
    days_in_month = monthrange(year, month)[1]

    user = request.user
    gender = user.gender
    shift = user.shift_type
    shift_start = user.shift_start_date or date(2024, 1, 1)

    holidays = get_holidays_from_api(year)

    approved_requests = LeaveRequest.objects.filter(
        user=user,
        status='approved',
        start_date__lte=date(year, month, days_in_month),
        end_date__gte=date(year, month, 1)
    )

    calendar = []
    first_weekday, _ = monthrange(year, month)
    for _ in range(first_weekday):
        calendar.append({'date': None, 'status': None, 'status_label': '', 'hours_planned': ''})

    for day in range(1, days_in_month + 1):
        current_date = date(year, month, day)
        weekday = current_date.weekday()
        current_str = current_date.strftime('%Y-%m-%d')

        if current_str in holidays and holidays[current_str] == 'holiday':
            status = 'holiday'
        else:
            status = None
            for req in approved_requests:
                if req.start_date <= current_date <= req.end_date:
                    status = req.leave_type
                    break

            if not status:
                if shift == '5_2':
                    status = 'weekend' if weekday in [5, 6] else 'work'
                elif shift == '2_2':
                    index = (current_date - shift_start).days
                    status = 'weekend' if index >= 0 and (index % 4) in [2, 3] else 'work'
                elif shift == '1_3':
                    index = (current_date - shift_start).days
                    status = 'work' if index >= 0 and (index % 4) == 0 else 'weekend'
                else:
                    status = 'work'

        if status == 'work':
            if shift == '5_2':
                hours = 8 if gender == 'male' or weekday == 0 else 7
            elif shift in ['2_2', '1_3']:
                hours = 12
            else:
                hours = 8
        else:
            hours = 0

        status_label = {
            'work': 'Рабочий день',
            'vacation': 'Отпуск',
            'sick': 'Больничный',
            'absent': 'Неявка',
            'weekend': 'Выходной',
            'holiday': 'Праздник 🎉',
        }.get(status, 'Неизвестно')

        calendar.append({
            'date': current_date,
            'status': status,
            'status_label': status_label,
            'hours_planned': hours
        })

    weekdays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    return render(request, 'attendance.html', {
        'calendar': calendar,
        'today': today,
        'year_range': range(today.year - 1, today.year + 2),
        'weekdays': weekdays,
    })


@login_required
@user_passes_test(is_worker)
def leave_request(request):
    if request.method == 'POST':
        form = LeaveRequestForm(request.POST)
        if form.is_valid():
            leave = form.save(commit=False)
            leave.user = request.user
            leave.created_at = now()

            start = leave.start_date
            end = leave.end_date
            leave_type = leave.leave_type

            # 1. Проверка даты начала и окончания
            if start > end:
                messages.error(request, "Дата начала не может быть позже даты окончания.")
                return redirect('leave_request')

            # 2. Запрет отпусков задним числом
            if leave_type != 'sick' and start < date.today():
                messages.error(request, "Нельзя подавать заявку на отпуск задним числом.")
                return redirect('leave_request')

            # 3. Проверка на пересекающиеся заявки
            overlapping = LeaveRequest.objects.filter(
                user=request.user,
                status__in=['pending', 'approved'],
                start_date__lte=end,
                end_date__gte=start
            ).exclude(id=leave.id)

            if overlapping.exists():
                messages.error(request, "У вас уже есть перекрывающая заявка.")
                return redirect('leave_request')

            # 4. Лимит ежегодного отпуска
            requested_days = (end - start).days + 1
            if leave_type == 'vacation':
                total_used = sum(
                    (r.end_date - r.start_date).days + 1
                    for r in LeaveRequest.objects.filter(
                        user=request.user,
                        leave_type='vacation',
                        status='approved'
                    )
                )
                if requested_days > 44 - total_used:
                    messages.error(request, f"Превышен лимит отпуска. Осталось {44 - total_used} дн.")
                    return redirect('leave_request')
                if requested_days < 14:
                    messages.warning(request, "По ТК РФ хотя бы один отпуск должен быть не менее 14 дней.")

            # 5. Проверка совмещения отпуск ↔ больничный
            opposite_type = 'sick' if leave_type == 'vacation' else 'vacation' if leave_type == 'sick' else None
            if opposite_type:
                conflict = LeaveRequest.objects.filter(
                    user=request.user,
                    leave_type=opposite_type,
                    status__in=['pending', 'approved'],
                    start_date__lte=end,
                    end_date__gte=start
                ).exists()
                if conflict:
                    messages.error(request, "Нельзя совмещать отпуск и больничный.")
                    return redirect('leave_request')

            # 6. Устанавливаем статус
            leave.status = 'approved' if leave_type == 'sick' else 'pending'
            leave.save()

            # 7. Уведомление руководителям через asyncio.run()
            message_text = f"📩 Новая заявка от {leave.user.get_full_name()} на {leave.get_leave_type_display()} ({start} — {end})"
            asyncio.run(notify_approvers(message_text))  # Запуск асинхронной задачи через asyncio.run()

            messages.success(request, "Заявка успешно отправлена.")
            return redirect('dashboard')

    else:
        form = LeaveRequestForm()

    # Заявки пользователя
    my_requests = LeaveRequest.objects.filter(user=request.user).order_by('-created_at')

    # Расчёт оставшегося отпуска
    total_used = sum(
        (r.end_date - r.start_date).days + 1
        for r in LeaveRequest.objects.filter(
            user=request.user,
            leave_type='vacation',
            status='approved'
        )
    )
    available_days = 44 - total_used

    return render(request, 'leave_request.html', {
        'form': form,
        'my_requests': my_requests,
        'available_days': available_days
    })


# Согласование заявок
@login_required
@user_passes_test(is_approver)
def approve_requests(request):
    if request.method == 'POST':
        request_id = request.POST.get('request_id')
        action = request.POST.get('action')
        leave = LeaveRequest.objects.get(id=request_id)
        if leave.status == 'pending':
            leave.status = 'approved' if action == 'approve' else 'rejected'
            leave.reviewed_by = request.user
            leave.reviewed_at = now()
            leave.save()
            messages.success(request, f"Заявка {'одобрена' if action == 'approve' else 'отклонена'}.")

        return redirect('approve_requests')

    leave_type_filter = request.GET.get('type', '')
    filter_q = Q()
    if leave_type_filter in ['vacation', 'sick']:
        filter_q &= Q(leave_type=leave_type_filter)

    return render(request, 'approve_requests.html', {
        'pending_requests': LeaveRequest.objects.filter(filter_q, status='pending'),
        'approved_requests': LeaveRequest.objects.filter(filter_q, status='approved'),
        'rejected_requests': LeaveRequest.objects.filter(filter_q, status='rejected'),
        'selected_type': leave_type_filter
    })


# Дополнительные роли
@login_required
@user_passes_test(is_editor)
def edit_attendance(request):
    return render(request, 'stub.html')


@login_required
@user_passes_test(is_admin)
def user_management(request):
    return render(request, 'stub.html')


@csrf_exempt
def telegram_login(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            username = data.get('username')
            password = data.get('password')
            telegram_id = data.get('telegram_id')

            user = authenticate(username=username, password=password)

            if user is None:
                return JsonResponse({"error": "Неверный логин или пароль"}, status=403)

            # Привязываем
            user.telegram_id = telegram_id
            user.save()
            return JsonResponse({"status": "ok", "message": "Telegram успешно привязан."})
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)

    return JsonResponse({"error": "Bad request"}, status=400)
