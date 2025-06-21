# utils/date_utils.py
import re
from datetime import datetime, date
from typing import Optional, Tuple

def parse_date_from_voice(text: str) -> Optional[Tuple[date, date]]:
    """
    Дополнительные паттерны для распознавания дат в голосовых сообщениях
    """
    text_lower = text.lower()

    # Относительные даты
    relative_patterns = [
        # "со следующей недели на две недели"
        r'со?\s+следующей\s+недели\s+на\s+(\d+)\s+недел[ьяию]',
        # "с понедельника на неделю"
        r'с\s+понедельника\s+на\s+(\d+)\s+недел[ьяию]',
        # "с завтра на 10 дней"
        r'с\s+завтра\s+на\s+(\d+)\s+дн[ейяь]',
        # "через неделю на 5 дней"
        r'через\s+(\d+)\s+недел[ьяию]\s+на\s+(\d+)\s+дн[ейяь]'
    ]

    today = date.today()

    for pattern in relative_patterns:
        match = re.search(pattern, text_lower)
        if match:
            # Это можно расширить для более сложной логики
            # Пока возвращаем None, чтобы использовать основную логику
            pass

    return None

def validate_vacation_dates(start_date: date, end_date: date) -> Tuple[bool, str]:
    """
    Валидация дат отпуска
    """
    today = date.today()

    if start_date > end_date:
        return False, "Дата начала не может быть позже даты окончания"

    if start_date < today:
        return False, "Нельзя подавать заявку на отпуск задним числом"

    # Максимальный период отпуска (например, 28 дней подряд)
    max_vacation_days = 28
    requested_days = (end_date - start_date).days + 1

    if requested_days > max_vacation_days:
        return False, f"Максимальный период отпуска: {max_vacation_days} дней"

    return True, "OK"

def format_date_range(start_date: date, end_date: date) -> str:
    """
    Форматирование периода дат для отображения
    """
    if start_date.year == end_date.year:
        if start_date.month == end_date.month:
            return f"{start_date.day}-{end_date.day}.{start_date.month:02d}.{start_date.year}"
        else:
            return f"{start_date.day}.{start_date.month:02d} - {end_date.day}.{end_date.month:02d}.{end_date.year}"
    else:
        return f"{start_date.strftime('%d.%m.%Y')} - {end_date.strftime('%d.%m.%Y')}"