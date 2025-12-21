"""
Shifts Management API Endpoints
Handles employee clock in/out, breaks, and shift history
"""
from datetime import datetime, timedelta
from typing import List, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, desc
import bcrypt

from app.core.deps import get_db, get_current_user
from app.models.user import User

router = APIRouter()


# ============== Pydantic Schemas ==============

class EmployeePinCreate(BaseModel):
    employee_id: str
    employee_name: str
    employee_role: str = "staff"
    pin: str = Field(..., min_length=4, max_length=4, pattern=r"^\d{4}$")


class EmployeePinResponse(BaseModel):
    id: str
    venue_id: str
    employee_id: str
    employee_name: str
    employee_role: str
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True


class ClockInRequest(BaseModel):
    employee_id: str
    pin: str = Field(..., min_length=4, max_length=4)
    expected_hours: float = 8.0


class ClockOutRequest(BaseModel):
    notes: Optional[str] = None


class BreakResponse(BaseModel):
    id: str
    shift_id: str
    started_at: datetime
    ended_at: Optional[datetime]
    duration_minutes: Optional[int]


class ShiftResponse(BaseModel):
    id: str
    venue_id: str
    employee_id: str
    employee_name: str
    employee_role: str
    started_at: datetime
    ended_at: Optional[datetime]
    expected_hours: float
    actual_hours: Optional[float]
    overtime_minutes: int
    status: str
    total_break_minutes: int
    notes: Optional[str]
    breaks: List[BreakResponse] = []
    created_at: datetime


class ShiftSummary(BaseModel):
    active_shifts: int
    total_hours_today: float
    total_overtime_today: int
    employees_on_break: int


class ActiveShiftWithTimer(BaseModel):
    id: str
    employee_id: str
    employee_name: str
    employee_role: str
    started_at: datetime
    expected_hours: float
    elapsed_minutes: int
    is_on_break: bool
    total_break_minutes: int
    status: str


# ============== Helper Functions ==============

def hash_pin(pin: str) -> str:
    """Hash a 4-digit PIN using bcrypt"""
    return bcrypt.hashpw(pin.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')


def verify_pin(pin: str, hashed: str) -> bool:
    """Verify a PIN against its hash"""
    return bcrypt.checkpw(pin.encode('utf-8'), hashed.encode('utf-8'))


# ============== PIN Management Endpoints ==============

@router.post("/venues/{venue_id}/pins", response_model=EmployeePinResponse)
async def create_employee_pin(
    venue_id: UUID,
    pin_data: EmployeePinCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Create a 4-digit PIN for an employee at a venue.
    Only owners/managers can create PINs.
    """
    # Hash the PIN
    pin_hash = hash_pin(pin_data.pin)

    # Check if employee already has a PIN at this venue
    result = await db.execute(
        select("*").select_from(db.get_bind().dialect.identifier_preparer.format_table("employee_pins")).where(
            and_(
                "venue_id" == str(venue_id),
                "employee_id" == pin_data.employee_id
            )
        )
    )

    # Use raw SQL for Supabase compatibility
    query = """
        INSERT INTO employee_pins (venue_id, employee_id, employee_name, employee_role, pin_hash)
        VALUES (:venue_id, :employee_id, :employee_name, :employee_role, :pin_hash)
        ON CONFLICT (venue_id, employee_id)
        DO UPDATE SET pin_hash = :pin_hash, employee_name = :employee_name, employee_role = :employee_role, updated_at = now()
        RETURNING id, venue_id, employee_id, employee_name, employee_role, is_active, created_at
    """

    from sqlalchemy import text
    result = await db.execute(
        text(query),
        {
            "venue_id": str(venue_id),
            "employee_id": pin_data.employee_id,
            "employee_name": pin_data.employee_name,
            "employee_role": pin_data.employee_role,
            "pin_hash": pin_hash,
        }
    )
    row = result.fetchone()

    return EmployeePinResponse(
        id=str(row.id),
        venue_id=str(row.venue_id),
        employee_id=row.employee_id,
        employee_name=row.employee_name,
        employee_role=row.employee_role,
        is_active=row.is_active,
        created_at=row.created_at,
    )


@router.get("/venues/{venue_id}/pins", response_model=List[EmployeePinResponse])
async def list_employee_pins(
    venue_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """List all employee PINs for a venue"""
    from sqlalchemy import text

    result = await db.execute(
        text("""
            SELECT id, venue_id, employee_id, employee_name, employee_role, is_active, created_at
            FROM employee_pins
            WHERE venue_id = :venue_id AND is_active = true
            ORDER BY employee_name
        """),
        {"venue_id": str(venue_id)}
    )
    rows = result.fetchall()

    return [
        EmployeePinResponse(
            id=str(row.id),
            venue_id=str(row.venue_id),
            employee_id=row.employee_id,
            employee_name=row.employee_name,
            employee_role=row.employee_role,
            is_active=row.is_active,
            created_at=row.created_at,
        )
        for row in rows
    ]


# ============== Clock In/Out Endpoints ==============

@router.post("/venues/{venue_id}/shifts/clock-in", response_model=ShiftResponse)
async def clock_in(
    venue_id: UUID,
    clock_in_data: ClockInRequest,
    db: AsyncSession = Depends(get_db),
):
    """
    Clock in an employee with PIN verification.
    Used on shared tablet with Bar account.
    """
    from sqlalchemy import text

    # Verify PIN
    result = await db.execute(
        text("""
            SELECT id, employee_id, employee_name, employee_role, pin_hash
            FROM employee_pins
            WHERE venue_id = :venue_id AND employee_id = :employee_id AND is_active = true
        """),
        {"venue_id": str(venue_id), "employee_id": clock_in_data.employee_id}
    )
    pin_record = result.fetchone()

    if not pin_record:
        raise HTTPException(status_code=404, detail="Employee not found or no PIN set")

    if not verify_pin(clock_in_data.pin, pin_record.pin_hash):
        raise HTTPException(status_code=401, detail="Invalid PIN")

    # Check if employee already has an active shift
    active_check = await db.execute(
        text("""
            SELECT id FROM shifts
            WHERE venue_id = :venue_id AND employee_id = :employee_id AND status IN ('active', 'on_break')
        """),
        {"venue_id": str(venue_id), "employee_id": clock_in_data.employee_id}
    )
    if active_check.fetchone():
        raise HTTPException(status_code=400, detail="Employee already has an active shift")

    # Create new shift
    result = await db.execute(
        text("""
            INSERT INTO shifts (venue_id, employee_id, employee_name, employee_role, expected_hours, status)
            VALUES (:venue_id, :employee_id, :employee_name, :employee_role, :expected_hours, 'active')
            RETURNING id, venue_id, employee_id, employee_name, employee_role, started_at, ended_at,
                      expected_hours, actual_hours, overtime_minutes, status, total_break_minutes, notes, created_at
        """),
        {
            "venue_id": str(venue_id),
            "employee_id": clock_in_data.employee_id,
            "employee_name": pin_record.employee_name,
            "employee_role": pin_record.employee_role,
            "expected_hours": clock_in_data.expected_hours,
        }
    )
    shift = result.fetchone()

    return ShiftResponse(
        id=str(shift.id),
        venue_id=str(shift.venue_id),
        employee_id=shift.employee_id,
        employee_name=shift.employee_name,
        employee_role=shift.employee_role,
        started_at=shift.started_at,
        ended_at=shift.ended_at,
        expected_hours=float(shift.expected_hours),
        actual_hours=float(shift.actual_hours) if shift.actual_hours else None,
        overtime_minutes=shift.overtime_minutes or 0,
        status=shift.status,
        total_break_minutes=shift.total_break_minutes or 0,
        notes=shift.notes,
        breaks=[],
        created_at=shift.created_at,
    )


@router.post("/venues/{venue_id}/shifts/{shift_id}/clock-out", response_model=ShiftResponse)
async def clock_out(
    venue_id: UUID,
    shift_id: UUID,
    clock_out_data: ClockOutRequest,
    db: AsyncSession = Depends(get_db),
):
    """Clock out an employee, ending their shift"""
    from sqlalchemy import text

    # End any active break first
    await db.execute(
        text("""
            UPDATE shift_breaks
            SET ended_at = now()
            WHERE shift_id = :shift_id AND ended_at IS NULL
        """),
        {"shift_id": str(shift_id)}
    )

    # Update shift to completed
    result = await db.execute(
        text("""
            UPDATE shifts
            SET status = 'completed', ended_at = now(), notes = COALESCE(:notes, notes)
            WHERE id = :shift_id AND venue_id = :venue_id AND status IN ('active', 'on_break')
            RETURNING id, venue_id, employee_id, employee_name, employee_role, started_at, ended_at,
                      expected_hours, actual_hours, overtime_minutes, status, total_break_minutes, notes, created_at
        """),
        {"shift_id": str(shift_id), "venue_id": str(venue_id), "notes": clock_out_data.notes}
    )
    shift = result.fetchone()

    if not shift:
        raise HTTPException(status_code=404, detail="Active shift not found")

    # Get breaks
    breaks_result = await db.execute(
        text("""
            SELECT id, shift_id, started_at, ended_at, duration_minutes
            FROM shift_breaks WHERE shift_id = :shift_id ORDER BY started_at
        """),
        {"shift_id": str(shift_id)}
    )
    breaks = breaks_result.fetchall()

    return ShiftResponse(
        id=str(shift.id),
        venue_id=str(shift.venue_id),
        employee_id=shift.employee_id,
        employee_name=shift.employee_name,
        employee_role=shift.employee_role,
        started_at=shift.started_at,
        ended_at=shift.ended_at,
        expected_hours=float(shift.expected_hours),
        actual_hours=float(shift.actual_hours) if shift.actual_hours else None,
        overtime_minutes=shift.overtime_minutes or 0,
        status=shift.status,
        total_break_minutes=shift.total_break_minutes or 0,
        notes=shift.notes,
        breaks=[
            BreakResponse(
                id=str(b.id),
                shift_id=str(b.shift_id),
                started_at=b.started_at,
                ended_at=b.ended_at,
                duration_minutes=b.duration_minutes,
            )
            for b in breaks
        ],
        created_at=shift.created_at,
    )


# ============== Break Endpoints ==============

@router.post("/venues/{venue_id}/shifts/{shift_id}/break/start", response_model=BreakResponse)
async def start_break(
    venue_id: UUID,
    shift_id: UUID,
    db: AsyncSession = Depends(get_db),
):
    """Start a break for an active shift"""
    from sqlalchemy import text

    # Verify shift is active
    shift_check = await db.execute(
        text("""
            SELECT id, status FROM shifts
            WHERE id = :shift_id AND venue_id = :venue_id AND status = 'active'
        """),
        {"shift_id": str(shift_id), "venue_id": str(venue_id)}
    )
    if not shift_check.fetchone():
        raise HTTPException(status_code=400, detail="Shift is not active or not found")

    # Check no active break exists
    active_break = await db.execute(
        text("""
            SELECT id FROM shift_breaks
            WHERE shift_id = :shift_id AND ended_at IS NULL
        """),
        {"shift_id": str(shift_id)}
    )
    if active_break.fetchone():
        raise HTTPException(status_code=400, detail="Break already in progress")

    # Create break
    result = await db.execute(
        text("""
            INSERT INTO shift_breaks (shift_id) VALUES (:shift_id)
            RETURNING id, shift_id, started_at, ended_at, duration_minutes
        """),
        {"shift_id": str(shift_id)}
    )
    break_record = result.fetchone()

    # Update shift status
    await db.execute(
        text("UPDATE shifts SET status = 'on_break' WHERE id = :shift_id"),
        {"shift_id": str(shift_id)}
    )

    return BreakResponse(
        id=str(break_record.id),
        shift_id=str(break_record.shift_id),
        started_at=break_record.started_at,
        ended_at=break_record.ended_at,
        duration_minutes=break_record.duration_minutes,
    )


@router.post("/venues/{venue_id}/shifts/{shift_id}/break/end", response_model=BreakResponse)
async def end_break(
    venue_id: UUID,
    shift_id: UUID,
    db: AsyncSession = Depends(get_db),
):
    """End an active break"""
    from sqlalchemy import text

    # End the break
    result = await db.execute(
        text("""
            UPDATE shift_breaks
            SET ended_at = now()
            WHERE shift_id = :shift_id AND ended_at IS NULL
            RETURNING id, shift_id, started_at, ended_at, duration_minutes
        """),
        {"shift_id": str(shift_id)}
    )
    break_record = result.fetchone()

    if not break_record:
        raise HTTPException(status_code=404, detail="No active break found")

    # Update shift status back to active
    await db.execute(
        text("UPDATE shifts SET status = 'active' WHERE id = :shift_id"),
        {"shift_id": str(shift_id)}
    )

    return BreakResponse(
        id=str(break_record.id),
        shift_id=str(break_record.shift_id),
        started_at=break_record.started_at,
        ended_at=break_record.ended_at,
        duration_minutes=break_record.duration_minutes,
    )


# ============== Query Endpoints ==============

@router.get("/venues/{venue_id}/shifts/active", response_model=List[ActiveShiftWithTimer])
async def get_active_shifts(
    venue_id: UUID,
    db: AsyncSession = Depends(get_db),
):
    """Get all active shifts for a venue with live timer data"""
    from sqlalchemy import text

    result = await db.execute(
        text("""
            SELECT s.id, s.employee_id, s.employee_name, s.employee_role, s.started_at,
                   s.expected_hours, s.total_break_minutes, s.status,
                   EXTRACT(EPOCH FROM (now() - s.started_at)) / 60 as elapsed_minutes,
                   EXISTS(SELECT 1 FROM shift_breaks sb WHERE sb.shift_id = s.id AND sb.ended_at IS NULL) as is_on_break
            FROM shifts s
            WHERE s.venue_id = :venue_id AND s.status IN ('active', 'on_break')
            ORDER BY s.started_at DESC
        """),
        {"venue_id": str(venue_id)}
    )
    shifts = result.fetchall()

    return [
        ActiveShiftWithTimer(
            id=str(s.id),
            employee_id=s.employee_id,
            employee_name=s.employee_name,
            employee_role=s.employee_role,
            started_at=s.started_at,
            expected_hours=float(s.expected_hours),
            elapsed_minutes=int(s.elapsed_minutes),
            is_on_break=s.is_on_break,
            total_break_minutes=s.total_break_minutes or 0,
            status=s.status,
        )
        for s in shifts
    ]


@router.get("/venues/{venue_id}/shifts/summary", response_model=ShiftSummary)
async def get_shift_summary(
    venue_id: UUID,
    db: AsyncSession = Depends(get_db),
):
    """Get shift summary/stats for the dashboard"""
    from sqlalchemy import text

    result = await db.execute(
        text("""
            SELECT
                COUNT(*) FILTER (WHERE status IN ('active', 'on_break')) as active_shifts,
                COALESCE(SUM(actual_hours) FILTER (WHERE DATE(started_at) = CURRENT_DATE), 0) as total_hours_today,
                COALESCE(SUM(overtime_minutes) FILTER (WHERE DATE(started_at) = CURRENT_DATE), 0) as total_overtime_today,
                COUNT(*) FILTER (WHERE status = 'on_break') as employees_on_break
            FROM shifts
            WHERE venue_id = :venue_id
        """),
        {"venue_id": str(venue_id)}
    )
    row = result.fetchone()

    return ShiftSummary(
        active_shifts=row.active_shifts or 0,
        total_hours_today=float(row.total_hours_today or 0),
        total_overtime_today=row.total_overtime_today or 0,
        employees_on_break=row.employees_on_break or 0,
    )


@router.get("/venues/{venue_id}/shifts/history", response_model=List[ShiftResponse])
async def get_shift_history(
    venue_id: UUID,
    employee_id: Optional[str] = Query(None),
    start_date: Optional[str] = Query(None, description="YYYY-MM-DD"),
    end_date: Optional[str] = Query(None, description="YYYY-MM-DD"),
    status: Optional[str] = Query(None),
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: AsyncSession = Depends(get_db),
):
    """Get shift history with filters"""
    from sqlalchemy import text

    # Build dynamic query
    conditions = ["venue_id = :venue_id"]
    params = {"venue_id": str(venue_id), "limit": limit, "offset": offset}

    if employee_id:
        conditions.append("employee_id = :employee_id")
        params["employee_id"] = employee_id

    if start_date:
        conditions.append("DATE(started_at) >= :start_date")
        params["start_date"] = start_date

    if end_date:
        conditions.append("DATE(started_at) <= :end_date")
        params["end_date"] = end_date

    if status:
        conditions.append("status = :status")
        params["status"] = status

    where_clause = " AND ".join(conditions)

    result = await db.execute(
        text(f"""
            SELECT id, venue_id, employee_id, employee_name, employee_role, started_at, ended_at,
                   expected_hours, actual_hours, overtime_minutes, status, total_break_minutes, notes, created_at
            FROM shifts
            WHERE {where_clause}
            ORDER BY started_at DESC
            LIMIT :limit OFFSET :offset
        """),
        params
    )
    shifts = result.fetchall()

    # Get breaks for all shifts
    shift_ids = [str(s.id) for s in shifts]
    breaks_by_shift = {}

    if shift_ids:
        breaks_result = await db.execute(
            text("""
                SELECT id, shift_id, started_at, ended_at, duration_minutes
                FROM shift_breaks
                WHERE shift_id = ANY(:shift_ids)
                ORDER BY started_at
            """),
            {"shift_ids": shift_ids}
        )
        for b in breaks_result.fetchall():
            shift_key = str(b.shift_id)
            if shift_key not in breaks_by_shift:
                breaks_by_shift[shift_key] = []
            breaks_by_shift[shift_key].append(
                BreakResponse(
                    id=str(b.id),
                    shift_id=str(b.shift_id),
                    started_at=b.started_at,
                    ended_at=b.ended_at,
                    duration_minutes=b.duration_minutes,
                )
            )

    return [
        ShiftResponse(
            id=str(s.id),
            venue_id=str(s.venue_id),
            employee_id=s.employee_id,
            employee_name=s.employee_name,
            employee_role=s.employee_role,
            started_at=s.started_at,
            ended_at=s.ended_at,
            expected_hours=float(s.expected_hours),
            actual_hours=float(s.actual_hours) if s.actual_hours else None,
            overtime_minutes=s.overtime_minutes or 0,
            status=s.status,
            total_break_minutes=s.total_break_minutes or 0,
            notes=s.notes,
            breaks=breaks_by_shift.get(str(s.id), []),
            created_at=s.created_at,
        )
        for s in shifts
    ]


@router.get("/venues/{venue_id}/shifts/{shift_id}", response_model=ShiftResponse)
async def get_shift(
    venue_id: UUID,
    shift_id: UUID,
    db: AsyncSession = Depends(get_db),
):
    """Get a specific shift by ID"""
    from sqlalchemy import text

    result = await db.execute(
        text("""
            SELECT id, venue_id, employee_id, employee_name, employee_role, started_at, ended_at,
                   expected_hours, actual_hours, overtime_minutes, status, total_break_minutes, notes, created_at
            FROM shifts
            WHERE id = :shift_id AND venue_id = :venue_id
        """),
        {"shift_id": str(shift_id), "venue_id": str(venue_id)}
    )
    shift = result.fetchone()

    if not shift:
        raise HTTPException(status_code=404, detail="Shift not found")

    # Get breaks
    breaks_result = await db.execute(
        text("""
            SELECT id, shift_id, started_at, ended_at, duration_minutes
            FROM shift_breaks WHERE shift_id = :shift_id ORDER BY started_at
        """),
        {"shift_id": str(shift_id)}
    )
    breaks = breaks_result.fetchall()

    return ShiftResponse(
        id=str(shift.id),
        venue_id=str(shift.venue_id),
        employee_id=shift.employee_id,
        employee_name=shift.employee_name,
        employee_role=shift.employee_role,
        started_at=shift.started_at,
        ended_at=shift.ended_at,
        expected_hours=float(shift.expected_hours),
        actual_hours=float(shift.actual_hours) if shift.actual_hours else None,
        overtime_minutes=shift.overtime_minutes or 0,
        status=shift.status,
        total_break_minutes=shift.total_break_minutes or 0,
        notes=shift.notes,
        breaks=[
            BreakResponse(
                id=str(b.id),
                shift_id=str(b.shift_id),
                started_at=b.started_at,
                ended_at=b.ended_at,
                duration_minutes=b.duration_minutes,
            )
            for b in breaks
        ],
        created_at=shift.created_at,
    )
