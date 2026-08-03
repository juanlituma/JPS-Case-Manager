"""
routers/cases.py — Case create, update, and query endpoints.
Accepts JWT from either a User (iOS) or an Employee (Windows).
"""

from typing import Optional, Tuple, Union
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from database import get_db
from models import Case, CaseStatus, User, Employee
from schemas import CaseCreate, CaseUpdate, CaseOut, CaseListOut
from auth import get_any_actor

router = APIRouter(prefix="/cases", tags=["Cases"])


# ─── Helper: enrich a Case ORM object → CaseOut with creator name ────────────

def _enrich_case(case: Case) -> CaseOut:
    """
    Convert a Case ORM object to a CaseOut schema, computing created_by_name
    from whichever creator relationship is populated (User or Employee).
    """
    out = CaseOut.model_validate(case)
    creator_name: str | None = None
    if case.creator:                        # iOS User created it
        creator_name = case.creator.full_name or case.creator.username
    assignee_name: str | None = None
    if case.assignee:
        assignee_name = case.assignee.full_name or case.assignee.username
    return out.model_copy(update={"created_by_name": creator_name, "assigned_to_name": assignee_name})


# ─── POST /cases ──────────────────────────────────────────────────────────────

@router.post("", response_model=CaseOut, status_code=status.HTTP_201_CREATED)
def create_case(
    payload: CaseCreate,
    db: Session = Depends(get_db),
    actor: Tuple[str, Union[User, Employee]] = Depends(get_any_actor),
):
    """
    Create a new case.
    - If created by a User (iOS): creator's user ID is stored in created_by_id.
    - If created by an Employee (Windows): created_by_id is left NULL.
    - assigned_to_id references the employees table.
    """
    kind, actor_obj = actor

    # Resolve assigned employee: use the provided ID, or auto-assign to the first employee
    if payload.assigned_to_id:
        assignee = db.query(Employee).filter(Employee.id == payload.assigned_to_id).first()
        if not assignee:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Assigned employee id={payload.assigned_to_id} not found",
            )
        resolved_assignee_id = assignee.id
    else:
        first_employee = db.query(Employee).order_by(Employee.id).first()
        resolved_assignee_id = first_employee.id if first_employee else None

    new_case = Case(
        title=payload.title,
        description=payload.description,
        solution=payload.solution,
        delivery_provider=payload.delivery_provider,
        complaint_type=payload.complaint_type,
        created_by_id=actor_obj.id if kind == "user" else None,
        assigned_to_id=resolved_assignee_id,
    )
    db.add(new_case)
    db.commit()
    db.refresh(new_case)
    return _enrich_case(new_case)


# ─── PUT /cases/{case_id} ─────────────────────────────────────────────────────

@router.put("/{case_id}", response_model=CaseOut)
def update_case(
    case_id: int,
    payload: CaseUpdate,
    db: Session = Depends(get_db),
    actor: Tuple[str, Union[User, Employee]] = Depends(get_any_actor),
):
    """
    Update an existing case.
    - Employees (Windows) can update any case — that's their job.
    - Users (iOS) can only update their own cases unless they are admin.
    """
    kind, actor_obj = actor

    case = db.query(Case).filter(Case.id == case_id).first()
    if not case:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Case id={case_id} not found",
        )

    # Permission check for user actors — users may only update their own cases
    if kind == "user":
        user: User = actor_obj
        if case.created_by_id != user.id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not authorised to update this case",
            )
    # Employees may update any case — no additional check needed

    # Validate assigned employee if provided
    update_data = payload.model_dump(exclude_unset=True)
    if "assigned_to_id" in update_data and update_data["assigned_to_id"] is not None:
        assignee = db.query(Employee).filter(Employee.id == update_data["assigned_to_id"]).first()
        if not assignee:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Assigned employee id={update_data['assigned_to_id']} not found",
            )

    for field, value in update_data.items():
        setattr(case, field, value)

    db.commit()
    db.refresh(case)
    return _enrich_case(case)


# ─── GET /cases ───────────────────────────────────────────────────────────────

@router.get("", response_model=CaseListOut)
def list_cases(
    status: Optional[CaseStatus] = Query(None, description="Filter by case status"),
    assigned_to_id: Optional[int] = Query(None, description="Filter by assigned employee ID"),
    created_by_id:  Optional[int] = Query(None, description="Filter by creator user ID"),
    skip:  int = Query(0,  ge=0,  description="Number of records to skip"),
    limit: int = Query(20, ge=1, le=100, description="Max records to return"),
    db: Session = Depends(get_db),
    actor: Tuple[str, Union[User, Employee]] = Depends(get_any_actor),
):
    """Query cases with optional filters and pagination."""
    kind, actor_obj = actor
    query = db.query(Case)

    # iOS users always see only their own cases (enforced server-side).
    if kind == "user":
        user: User = actor_obj
        query = query.filter(Case.created_by_id == user.id)
    else:
        # Employees (Windows) see all cases; optional creator filter still applies.
        if created_by_id is not None:
            query = query.filter(Case.created_by_id == created_by_id)

    if status is not None:
        query = query.filter(Case.status == status)
    if assigned_to_id is not None:
        query = query.filter(Case.assigned_to_id == assigned_to_id)

    total = query.count()
    cases = query.order_by(Case.created_at.desc()).offset(skip).limit(limit).all()

    return CaseListOut(total=total, cases=[_enrich_case(c) for c in cases])


# ─── GET /cases/{case_id} ─────────────────────────────────────────────────────

@router.get("/{case_id}", response_model=CaseOut)
def get_case(
    case_id: int,
    db: Session = Depends(get_db),
    actor: Tuple[str, Union[User, Employee]] = Depends(get_any_actor),
):
    """Retrieve a single case by its ID."""
    case = db.query(Case).filter(Case.id == case_id).first()
    if not case:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Case id={case_id} not found",
        )
    return _enrich_case(case)
