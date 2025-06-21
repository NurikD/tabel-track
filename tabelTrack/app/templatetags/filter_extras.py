from django import template
from datetime import date

register = template.Library()

@register.filter
def to_range(start, end):
    return range(start, end + 1)

@register.filter
def days_since(value):
    if value:
        delta = date.today() - value
        return delta.days
    return 0

@register.simple_tag
def get_sick_leave_count(user):
    return user.leaverequest_set.filter(leave_type='sick', status='approved').count()