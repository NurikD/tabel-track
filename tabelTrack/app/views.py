from datetime import date
from calendar import monthrange
from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required, user_passes_test
from .forms import LeaveRequestForm
from .models import LeaveRequest
from django.utils.timezone import now
from django.contrib import messages

# Проверки ролей
def is_worker(user): return user.role == 'worker'
def is_editor(user): return user.role == 'editor'
def is_approver(user): return user.role == 'approver'
def is_admin(user): return user.role == 'admin'


# Главная страница — доступна всем авторизованным
@login_required
def dashboard(request):
    return render(request, 'dashboard.html')


# Табель — только для сотрудников
@login_required
@user_passes_test(is_worker)
def attendance(request):
    today = date.today()
    year, month = today.year, today.month
    days_in_month = monthrange(year, month)[1]

    statuses = ['work', 'vacation', 'sick', 'absent']
    status_labels = {
        'work': 'Работа',
        'vacation': 'Отпуск',
        'sick': 'Больничный',
        'absent': 'Неявка'
    }

    calendar = []
    for day in range(1, days_in_month + 1):
        d = date(year, month, day)
        if day % 9 == 0:
            status = 'vacation'
        elif day % 7 == 0:
            status = 'sick'
        elif day % 6 == 0:
            status = 'absent'
        else:
            status = 'work'

        calendar.append({
            'date': d,
            'status': status,
            'status_label': status_labels[status]
        })

    return render(request, 'attendance.html', {'calendar': calendar})


# Подача заявки на отпуск / больничный — только сотрудник
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


# Редактирование табеля — только редактор
@login_required
@user_passes_test(is_editor)
def edit_attendance(request):
    return render(request, 'stub.html')


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

    pending_requests = LeaveRequest.objects.filter(status='pending').order_by('-created_at')
    return render(request, 'approve_requests.html', {'requests': pending_requests})


# Управление пользователями — только админ
@login_required
@user_passes_test(is_admin)
def user_management(request):
    return render(request, 'stub.html')
