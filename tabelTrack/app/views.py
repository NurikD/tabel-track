from datetime import date
from calendar import monthrange
from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required, user_passes_test
from .forms import LeaveRequestForm
from .models import LeaveRequest, CustomUser
from django.utils.timezone import now
from django.contrib import messages
from django.db.models import Q
from utils.holidays import get_holidays_from_api

# Проверки ролей
def is_worker(user): return user.role == 'worker'
def is_editor(user): return user.role == 'editor'
def is_approver(user): return user.role == 'approver'
def is_admin(user): return user.role == 'admin'


# Главная страница — доступна всем авторизованным
@login_required
@user_passes_test(is_approver)
def dashboard(request):
    today = date.today()

    # Список всех сотрудников
    team_members = CustomUser.objects.filter(role='worker')

    # Подсчёт общей статистики
    total_employees = team_members.count()

    # Заявки, перекрывающие сегодня
    active_requests_today = LeaveRequest.objects.filter(
        status='approved',
        start_date__lte=today,
        end_date__gte=today
    )

    today_vacation = active_requests_today.filter(leave_type='vacation').count()
    today_sick = active_requests_today.filter(leave_type='sick').count()
    today_present = total_employees - today_vacation - today_sick

    # Статистика
    stats = {
        "today_present": today_present,
        "today_sick": today_sick,
        "today_vacation": today_vacation,
        "total_employees": total_employees,
    }

    # Последние 5 заявок сотрудников
    team_requests = LeaveRequest.objects.filter(
        user__role='worker'
    ).order_by('-created_at')[:5]

    # По каждому сотруднику: сколько отработал, отпуск, больничный
    detailed_members = []
    for member in team_members:
        vacation = LeaveRequest.objects.filter(user=member, leave_type='vacation', status='approved')
        sick = LeaveRequest.objects.filter(user=member, leave_type='sick', status='approved')

        vacation_days = sum((r.end_date - r.start_date).days + 1 for r in vacation)
        sick_days = sum((r.end_date - r.start_date).days + 1 for r in sick)
        absent_days = 0  # сюда можно добавить отсутствие без причины

        # Для примера: считаем отработанные дни = общее кол-во рабочих дней - отпуск - больничный
        worked_days = 14  # ❗пока фиксированное число (можно связать с табелем)

        detailed_members.append({
            'get_full_name': member.get_full_name(),
            'position': getattr(member, 'position', '—'),
            'vacation_days': vacation_days,
            'sick_days': sick_days,
            'worked_days': worked_days,
        })

    return render(request, 'dashboard.html', {
        'stats': stats,
        'team_requests': team_requests,
        'team_members': detailed_members,
        'user': request.user
    })


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

    first_weekday, _ = monthrange(year, month)  # День недели первого дня месяца (0=Пн)
    # Добавляем пустые слоты, чтобы выровнять календарь
    for _ in range(first_weekday):
        calendar.append({'date': None, 'status': None, 'status_label': '', 'hours_planned': ''})

    for day in range(1, days_in_month + 1):
        current_date = date(year, month, day)
        weekday = current_date.weekday()
        current_str = current_date.strftime('%Y-%m-%d')

        # 1. Праздник
        if current_str in holidays and holidays[current_str] == 'holiday':
            status = 'holiday'
        else:
            # 2. Отпуск / больничный
            status = None
            for req in approved_requests:
                if req.start_date <= current_date <= req.end_date:
                    status = req.leave_type  # 'vacation' или 'sick'
                    break

            # 3. Выходной по графику (если не отпуск/больничный)
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

        # 4. Часы
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


# Подача заявки — только сотрудник
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

            if start > end:
                messages.error(request, "Дата начала не может быть позже даты окончания.")
                return redirect('leave_request')

            # 1. Запрет отпуска задним числом (больничный — можно)
            if leave_type != 'sick' and start < date.today():
                messages.error(request, "Нельзя подавать заявку на отпуск задним числом.")
                return redirect('leave_request')

            # 2. Проверка пересечений любых заявок
            overlapping = LeaveRequest.objects.filter(
                user=request.user,
                status__in=['pending', 'approved'],
                start_date__lte=end,
                end_date__gte=start
            ).exclude(id=leave.id)

            if overlapping.exists():
                messages.error(request, "У вас уже есть активная заявка, перекрывающая эти даты.")
                return redirect('leave_request')

            # 3. Лимит ежегодного отпуска
            requested_days = (end - start).days + 1
            available_days = 44  # по ТК РФ

            if leave_type == 'vacation':
                total_used = sum(
                    (r.end_date - r.start_date).days + 1
                    for r in LeaveRequest.objects.filter(
                        user=request.user,
                        leave_type='vacation',
                        status='approved'
                    )
                )
                remaining = available_days - total_used
                if requested_days > remaining:
                    messages.error(request, f"Превышен лимит отпуска. Осталось {remaining} дн.")
                    return redirect('leave_request')

                if requested_days < 14:
                    messages.warning(request, "❗ По ТК РФ хотя бы одна часть отпуска должна быть не менее 14 дней.")

            # 4. Взаимоисключение отпуск ↔ больничный
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
                    messages.error(
                        request,
                        f"{dict(LeaveRequest.TYPE_CHOICES)[leave_type]} не может пересекаться с {dict(LeaveRequest.TYPE_CHOICES)[opposite_type].lower()}."
                    )
                    return redirect('leave_request')

            # 5. Статус: больничный — сразу approved
            leave.status = 'approved' if leave_type == 'sick' else 'pending'

            leave.save()
            messages.success(request, "Заявка успешно отправлена.")
            return redirect('dashboard')
    else:
        form = LeaveRequestForm()

    my_requests = LeaveRequest.objects.filter(user=request.user).order_by('-created_at')

    # Подсчёт оставшегося отпуска
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



# Согласование заявок — только согласующий
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
            messages.success(request, f"Заявка была {'одобрена' if action == 'approve' else 'отклонена'}.")

        return redirect('approve_requests')

    leave_type_filter = request.GET.get('type', '')
    filter_q = Q()
    if leave_type_filter in ['vacation', 'sick']:
        filter_q &= Q(leave_type=leave_type_filter)

    pending_requests = LeaveRequest.objects.filter(filter_q, status='pending').order_by('-created_at')
    approved_requests = LeaveRequest.objects.filter(filter_q, status='approved').order_by('-created_at')
    rejected_requests = LeaveRequest.objects.filter(filter_q, status='rejected').order_by('-created_at')

    return render(request, 'approve_requests.html', {
        'pending_requests': pending_requests,
        'approved_requests': approved_requests,
        'rejected_requests': rejected_requests,
        'selected_type': leave_type_filter
    })


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
