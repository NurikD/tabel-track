import asyncio
from datetime import date
from calendar import monthrange
import json
from django.shortcuts import redirect, render
from django.contrib.auth.decorators import login_required, user_passes_test
from django.http import JsonResponse
from django.contrib import messages
from django.utils import timezone
from django.conf import settings

from .models import CustomUser, LeaveRequest
from .forms import LeaveRequestForm
from .utils.holidays import get_holidays_from_api
from django.db.models import Q

from app.tasks import notify_approver_email
from app.tasks import send_result_to_employee

from .models import TelegramLinkCode
from django.utils.crypto import get_random_string

# Ролевые проверки
def is_worker(user): return user.role == 'worker'
def is_editor(user): return user.role == 'editor'
def is_approver(user): return user.role == 'approver'
def is_admin(user): return user.role == 'admin'


@login_required
def dashboard(request):
    user = request.user
    today = date.today()
    year = today.year
    month = today.month
    days_in_month = monthrange(year, month)[1]

    # Общие данные
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

    # Личные данные текущего пользователя
    user = request.user
    my_requests = LeaveRequest.objects.filter(user=user).order_by('-created_at')[:5]
    total_used = sum((r.end_date - r.start_date).days + 1 for r in LeaveRequest.objects.filter(
        user=user, leave_type='vacation', status='approved'))
    available_days = 44 - total_used

    # Календарь для текущего пользователя
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

        hours = 0
        if status == 'work':
            if shift == '5_2':
                hours = 8 if gender == 'male' or weekday == 0 else 7
            elif shift in ['2_2', '1_3']:
                hours = 12
            else:
                hours = 8

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

    # Подсчёт отработанных дней и прогресса для текущего пользователя
    worked_days = sum(1 for day in calendar if day['status'] == 'work' and day['date'])
    hours_planned = sum(day['hours_planned'] for day in calendar if day['status'] == 'work' and day['date'])
    progress_percentage = (worked_days / days_in_month * 100) if days_in_month > 0 else 0
    max_hours = days_in_month * 8  # Предполагаем 8 часов в день как максимум
    hours_progress = (hours_planned / max_hours * 100) if max_hours > 0 else 0
    vacation_progress = (available_days / 44 * 100) if 44 > 0 else 0

    # Все заявки для approver
    all_requests = LeaveRequest.objects.filter(status__in=['pending', 'approved', 'rejected']).order_by('-created_at')

    # Детализация по сотрудникам для approver
    detailed_members = []
    for member in team_members:
        vacation = LeaveRequest.objects.filter(user=member, leave_type='vacation', status='approved')
        sick = LeaveRequest.objects.filter(user=member, leave_type='sick', status='approved')
        vacation_days = sum((r.end_date - r.start_date).days + 1 for r in vacation)
        sick_days = sum((r.end_date - r.start_date).days + 1 for r in sick)
        worked_days_member = sum(1 for day in calendar if day['status'] == 'work' and day['date'])
        detailed_members.append({
            'get_full_name': member.get_full_name(),
            'position': member.get_position_display() if hasattr(member, 'get_position_display') else member.position,
            'vacation_days': vacation_days,
            'sick_days': sick_days,
            'worked_days': worked_days_member,
        })

    # Выбор шаблона и данных в зависимости от роли
    if is_worker(user):
        return render(request, 'dashboard_worker.html', {
            'my_requests': my_requests,
            'worked_days': worked_days,
            'hours_planned': hours_planned,
            'available_days': available_days,
            'progress_percentage': round(progress_percentage, 2),
            'hours_progress': round(hours_progress, 2),
            'vacation_progress': round(vacation_progress, 2),
            'user': user,
            'calendar': calendar,
        })
    elif is_approver(user):
        return render(request, 'dashboard_approver.html', {
            'my_requests': my_requests,
            'worked_days': worked_days,
            'hours_planned': hours_planned,
            'available_days': available_days,
            'progress_percentage': round(progress_percentage, 2),
            'hours_progress': round(hours_progress, 2),
            'vacation_progress': round(vacation_progress, 2),
            'user': user,
            'stats': stats,
            'all_requests': all_requests,
            'team_members': detailed_members,
            'calendar': calendar,
        })
    elif is_editor(user):
        return render(request, 'dashboard_editor.html', {
            'my_requests': my_requests,
            'worked_days': worked_days,
            'hours_planned': hours_planned,
            'available_days': available_days,
            'progress_percentage': round(progress_percentage, 2),
            'hours_progress': round(hours_progress, 2),
            'vacation_progress': round(vacation_progress, 2),
            'user': user,
            'calendar': calendar,
        })
    else:
        return render(request, 'dashboard.html', {'user': user})

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
            leave.created_at = timezone.now()

            start = leave.start_date
            end = leave.end_date
            leave_type = leave.leave_type

            # Расчёт оставшегося отпуска — должен быть до проверок
            total_used = sum(
                (r.end_date - r.start_date).days + 1
                for r in LeaveRequest.objects.filter(
                    user=request.user,
                    leave_type='vacation',
                    status='approved'
                )
            )
            available_days = 44 - total_used

            # 1. Проверка даты начала и окончания
            if start > end:
                return JsonResponse({'success': False, 'error': "Дата начала не может быть позже даты окончания."})

            # 2. Запрет отпуска задним числом (кроме больничного)
            if leave_type != 'sick' and start < date.today():
                return JsonResponse({'success': False, 'error': "Нельзя подавать заявку на отпуск задним числом."})

            # 3. Проверка на пересекающиеся заявки
            overlapping = LeaveRequest.objects.filter(
                user=request.user,
                status__in=['pending', 'approved'],
                start_date__lte=end,
                end_date__gte=start
            ).exclude(id=leave.id)

            if overlapping.exists():
                return JsonResponse({'success': False, 'error': "У вас уже есть активная заявка, перекрывающая эти даты."})

            # 4. Лимит отпуска
            requested_days = (end - start).days + 1
            if leave_type == 'vacation':
                if requested_days > available_days:
                    return JsonResponse({'success': False, 'error': f"Превышен лимит отпуска. Осталось {available_days} дн."})
                if requested_days < 14:
                    messages.warning(request, "По ТК РФ хотя бы один отпуск должен быть не менее 14 дней.")

            # 5. Проверка совмещения
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
                    return JsonResponse({'success': False, 'error': f"{dict(LeaveRequest.TYPE_CHOICES)[leave_type]} не может пересекаться с {dict(LeaveRequest.TYPE_CHOICES)[opposite_type].lower()}."})

            # 6. Сохраняем
            leave.status = 'approved' if leave_type == 'sick' else 'pending'
            leave.save()

            # 7. Отправка уведомлений согласующим
            # Email уведомления (существующая логика)
            approvers = CustomUser.objects.filter(role='approver').values_list('email', flat=True)
            for email in approvers:
                notify_approver_email.delay(
                    leave.user.get_full_name(),
                    leave.get_leave_type_display(),
                    leave.start_date.strftime('%d.%m.%Y'),
                    leave.end_date.strftime('%d.%m.%Y'),
                    email
                )

            # ✅ НОВОЕ: Telegram уведомления для согласующих
            if leave.status == 'pending':  # Только для заявок, требующих согласования
                from app.tasks import notify_approver_telegram
                notify_approver_telegram.delay(
                    request_id=leave.id,
                    employee_full_name=leave.user.get_full_name(),
                    leave_type=leave.get_leave_type_display(),
                    start_date=leave.start_date.strftime('%d.%m.%Y'),
                    end_date=leave.end_date.strftime('%d.%m.%Y')
                )

            return JsonResponse({'success': True})
        else:
            return JsonResponse({'success': False, 'error': form.errors.as_json()})

    else:
        form = LeaveRequestForm()
        my_requests = LeaveRequest.objects.filter(user=request.user).order_by('-created_at')

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
            leave.reviewed_at = timezone.now()
            leave.save()

            # ✉️ Email уведомление сотрудника о результате
            send_result_to_employee.delay(
                leave.user.email,
                leave.get_leave_type_display(),
                leave.start_date.strftime('%d.%m.%Y'),
                leave.end_date.strftime('%d.%m.%Y'),
                leave.status
            )

            # ✅ НОВОЕ: Telegram уведомление сотрудника
            if leave.user.telegram_id:
                from app.tasks import notify_employee_telegram
                notify_employee_telegram.delay(
                    employee_telegram_id=leave.user.telegram_id,
                    leave_type=leave.get_leave_type_display(),
                    start_date=leave.start_date.strftime('%d.%m.%Y'),
                    end_date=leave.end_date.strftime('%d.%m.%Y'),
                    status=leave.status
                )

            messages.success(
                request,
                f"Заявка {'одобрена' if action == 'approve' else 'отклонена'}."
            )

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


# ✅ НОВОЕ: API endpoint для обработки согласования через Telegram
@login_required
def telegram_approve_request(request):
    """API endpoint для согласования заявок через Telegram бота"""
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            request_id = data.get('request_id')
            action = data.get('action')  # 'approve' или 'reject'
            telegram_id = data.get('telegram_id')

            # Проверяем, что пользователь с данным telegram_id имеет права approver
            try:
                approver = CustomUser.objects.get(telegram_id=telegram_id, role='approver')
            except CustomUser.DoesNotExist:
                return JsonResponse({'success': False, 'error': 'Нет прав на согласование'})

            # Получаем заявку
            try:
                leave = LeaveRequest.objects.get(id=request_id, status='pending')
            except LeaveRequest.DoesNotExist:
                return JsonResponse({'success': False, 'error': 'Заявка не найдена или уже обработана'})

            # Обновляем статус заявки
            leave.status = 'approved' if action == 'approve' else 'rejected'
            leave.reviewed_by = approver
            leave.reviewed_at = timezone.now()
            leave.save()

            # Отправляем уведомления
            # Email
            send_result_to_employee.delay(
                leave.user.email,
                leave.get_leave_type_display(),
                leave.start_date.strftime('%d.%m.%Y'),
                leave.end_date.strftime('%d.%m.%Y'),
                leave.status
            )

            # Telegram
            if leave.user.telegram_id:
                from app.tasks import notify_employee_telegram
                notify_employee_telegram.delay(
                    employee_telegram_id=leave.user.telegram_id,
                    leave_type=leave.get_leave_type_display(),
                    start_date=leave.start_date.strftime('%d.%m.%Y'),
                    end_date=leave.end_date.strftime('%d.%m.%Y'),
                    status=leave.status
                )

            return JsonResponse({
                'success': True,
                'message': f"Заявка {'одобрена' if action == 'approve' else 'отклонена'}"
            })

        except Exception as e:
            return JsonResponse({'success': False, 'error': str(e)})

    return JsonResponse({'success': False, 'error': 'Метод не поддерживается'})

# Редактирование табеля — только редактор
@login_required
@user_passes_test(is_editor)
def edit_attendance(request):
    return render(request, 'stub.html')

# Управление пользователями — только админ
@login_required
@user_passes_test(is_admin)
def user_management(request):
    return render(request, 'stub.html')

@login_required
def link_telegram(request):
    user = request.user

    code_obj, created = TelegramLinkCode.objects.get_or_create(user=user)

    if created or not code_obj.code:
        code_obj.code = get_random_string(length=6, allowed_chars='0123456789')
        code_obj.save()

    return render(request, 'link_telegram.html', {
        'code': code_obj.code
    })