from aiogram import Router, types, F
from aiogram.fsm.state import State, StatesGroup
from aiogram.fsm.context import FSMContext
from asgiref.sync import sync_to_async
from app.models import CustomUser, LeaveRequest
from django.utils import timezone
from datetime import datetime

router = Router()

class VacationRequest(StatesGroup):
    start = State()
    end = State()
    comment = State()
    confirm = State()

@router.message(F.text == "/vacation")
async def start_vacation(message: types.Message, state: FSMContext):
    user = await sync_to_async(CustomUser.objects.filter(telegram_id=message.from_user.id).first)()
    if not user:
        await message.answer("❗ Сначала привяжите аккаунт через сайт.")
        return
    await message.answer("📅 Введите дату начала отпуска (в формате ДД.ММ.ГГГГ):")
    await state.set_state(VacationRequest.start)

@router.message(VacationRequest.start)
async def get_start_date(message: types.Message, state: FSMContext):
    try:
        start_date = datetime.strptime(message.text, "%d.%m.%Y").date()
        await state.update_data(start=start_date)
        await message.answer("📅 Введите дату окончания отпуска (в формате ДД.ММ.ГГГГ):")
        await state.set_state(VacationRequest.end)
    except:
        await message.answer("❌ Неверный формат. Повторите: ДД.ММ.ГГГГ")

@router.message(VacationRequest.end)
async def get_end_date(message: types.Message, state: FSMContext):
    try:
        end_date = datetime.strptime(message.text, "%d.%m.%Y").date()
        await state.update_data(end=end_date)
        await message.answer("📝 Укажите причину (необязательно, можно пропустить):")
        await state.set_state(VacationRequest.comment)
    except:
        await message.answer("❌ Неверный формат. Повторите: ДД.ММ.ГГГГ")

@router.message(VacationRequest.comment)
async def get_comment(message: types.Message, state: FSMContext):
    await state.update_data(comment=message.text)  # исправлено
    data = await state.get_data()

    confirm_text = (
        f"📋 Подтвердите заявку:\n\n"
        f"📅 {data['start'].strftime('%d.%m.%Y')} — {data['end'].strftime('%d.%m.%Y')}\n"
        f"📎 Причина: {data['comment'] or 'не указана'}\n\n"
        f"Отправить заявку?"
    )
    keyboard = types.InlineKeyboardMarkup(inline_keyboard=[
        [types.InlineKeyboardButton(text="✅ Подтвердить", callback_data="vacation_confirm")],
        [types.InlineKeyboardButton(text="❌ Отмена", callback_data="vacation_cancel")]
    ])
    await message.answer(confirm_text, reply_markup=keyboard)
    await state.set_state(VacationRequest.confirm)

@router.callback_query(F.data.in_({"vacation_confirm", "vacation_cancel"}))
async def process_confirmation(callback: types.CallbackQuery, state: FSMContext):
    if callback.data == "vacation_cancel":
        await state.clear()
        await callback.message.edit_text("❌ Заявка отменена.")
        return

    data = await state.get_data()
    user = await sync_to_async(CustomUser.objects.get)(telegram_id=callback.from_user.id)

    leave = LeaveRequest(
        user=user,
        leave_type='vacation',
        start_date=data['start'],
        end_date=data['end'],
        comment=data['comment'],  # исправлено
        status='pending',
        created_at=timezone.now()
    )

    await sync_to_async(leave.save)()
    await callback.message.edit_text("✅ Заявка успешно отправлена!")

    # Уведомляем руководителя через Celery
    from app.tasks import notify_approver_telegram
    notify_approver_telegram.delay(
        request_id=leave.id,
        employee_full_name=user.full_name,
        leave_type="Ежегодный отпуск",
        start_date=leave.start_date.strftime('%d.%m.%Y'),
        end_date=leave.end_date.strftime('%d.%m.%Y')
    )

    await state.clear()
