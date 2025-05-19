from datetime import date
from calendar import monthrange
from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required, user_passes_test
from .forms import LeaveRequestForm
from .models import LeaveRequest
from django.utils.timezone import now
from django.contrib import messages
from django.db.models import Q

# Проверки ролей
def is_worker(user): return user.role == 'worker'
def is_editor(user): return user.role == 'editor'
def is_approver(user): return user.role == 'approver'
def is_admin(user): return user.role == 'admin'


# Главная страница — доступна всем авторизованным
@login_required
def dashboard(request):
    context = {}

    if request.user.role == 'worker':
        user = request.user

        # Последние 5 заявок
        my_requests = LeaveRequest.objects.filter(user=user).order_by('-created_at')[:5]

        # Счётчики по типу отпуска (approved)
        approved = LeaveRequest.objects.filter(user=user, status='approved')
        vacation_days = sum((r.end_date - r.start_date).days + 1 for r in approved if r.leave_type == 'vacation')
        sick_days = sum((r.end_date - r.start_date).days + 1 for r in approved if r.leave_type == 'sick')

        context.update({
            'my_requests': my_requests,
            'vacation_days': vacation_days,
            'sick_days': sick_days,
            'absent_days': 3,  # Пока статично — можно потом вычислять по табелю
            'worked_days': 14  # Пока статично — можно интегрировать из attendance
        })

    return render(request, 'dashboard.html', context)


# Табель — только для сотрудников
@login_required
@user_passes_test(is_worker)
def attendance(request):
    today = date.today()
    year = int(request.GET.get('year', today.year))
    month = int(request.GET.get('month', today.month))
    days_in_month = monthrange(year, month)[1]

    user = request.user

    # Получаем все одобренные заявки пользователя
    approved_requests = LeaveRequest.objects.filter(
        user=user,
        status='approved',
        start_date__year=year,
        end_date__year=year,
    )

    # Строим календарь
    calendar = []
    for day in range(1, days_in_month + 1):
        current_date = date(year, month, day)
        status = 'work'

        for req in approved_requests:
            if req.start_date <= current_date <= req.end_date:
                status = req.leave_type  # 'vacation' или 'sick'
                break

        calendar.append({
            'date': current_date,
            'status': status,
            'status_label': {
                'work': 'Работа',
                'vacation': 'Отпуск',
                'sick': 'Больничный',
                'absent': 'Неявка'
            }[status]
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
            leave.save()
            messages.success(request, "Заявка успешно отправлена.")
            return redirect('dashboard')
    else:
        form = LeaveRequestForm()

    my_requests = LeaveRequest.objects.filter(user=request.user).order_by('-created_at')

    return render(request, 'leave_request.html', {
        'form': form,
        'my_requests': my_requests
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
