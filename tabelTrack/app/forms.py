from django import forms
from django.contrib.auth.models import User
from .models import LeaveRequest, CustomUser

class LeaveRequestForm(forms.ModelForm):
    class Meta:
        model = LeaveRequest
        fields = ['leave_type', 'start_date', 'end_date', 'comment']
        widgets = {
            'start_date': forms.DateInput(attrs={'type': 'date'}),
            'end_date': forms.DateInput(attrs={'type': 'date'}),
            'comment': forms.Textarea(attrs={'rows': 3}),
        }

class UserProfileForm(forms.ModelForm):
    class Meta:
        model = CustomUser
        fields = [
            'first_name',
            'last_name',
            'middle_name',
            'birth_date',
            'gender',
            'marital_status',
            'position',
            'department',
            'manager',
            'hire_date',
            'contract_type',
            'employee_id',
            'work_email',
            'personal_email',
            'work_phone',
            'mobile_phone',
            'address',
        ]
        widgets = {
            'birth_date': forms.DateInput(attrs={'type': 'date'}),
            'hire_date': forms.DateInput(attrs={'type': 'date'}),
        }