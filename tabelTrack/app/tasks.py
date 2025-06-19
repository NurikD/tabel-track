from celery import shared_task
from django.core.mail import send_mail
from django.conf import settings

@shared_task
def notify_approver_email(employee_full_name, leave_type, start_date, end_date, approver_email):
    subject = f"📩 Новая заявка на {leave_type}"
    message = (
        f"Сотрудник {employee_full_name} подал заявку на {leave_type} "
        f"с {start_date} по {end_date}.\n\n"
        f"Пожалуйста, согласуйте заявку в системе."
    )
    send_mail(
        subject,
        message,
        settings.DEFAULT_FROM_EMAIL,
        [approver_email],
        fail_silently=False
    )

@shared_task
def send_result_to_employee(employee_email, leave_type, start_date, end_date, status):
    subject = f"📝 Ваша заявка на {leave_type} {status_display(status)}"
    message = (
        f"Ваша заявка на {leave_type} с {start_date} по {end_date} была {status_display(status)}.\n\n"
        f"Спасибо!"
    )
    send_mail(
        subject,
        message,
        settings.DEFAULT_FROM_EMAIL,
        [employee_email],
        fail_silently=False
    )

def status_display(status):
    return {
        'approved': 'одобрена ✅',
        'rejected': 'отклонена ❌',
        'pending': 'на рассмотрении ⏳'
    }.get(status, 'обработана')
