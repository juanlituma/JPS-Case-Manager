"""
routers/employees.py — Standalone employee authentication and management.
Employees have completely separate credentials from users (iOS accounts).
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from database import get_db
from models import Employee
from schemas import (
    EmployeeRegister, EmployeeLogin,
    EmployeeOut, EmployeeToken, EmployeeUpdate, EmployeeListOut,
)
from auth import hash_password, verify_password, create_employee_token, get_current_employee

router = APIRouter(prefix="/employees", tags=["Employees"])


# ─── POST /employees/register ─────────────────────────────────────────────────

@router.post("/register", response_model=EmployeeOut, status_code=status.HTTP_201_CREATED)
def register_employee(payload: EmployeeRegister, db: Session = Depends(get_db)):
    """
    Create a new employee account.
    - username, email, and employee_number must be unique
    - password is stored as a bcrypt hash, never in plain text
    - completely independent of the users table
    """
    if db.query(Employee).filter(Employee.username == payload.username).first():
        raise HTTPException(status_code=400, detail="Username already registered")

    if db.query(Employee).filter(Employee.email == payload.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")

    if db.query(Employee).filter(Employee.employee_number == payload.employee_number).first():
        raise HTTPException(status_code=400, detail="Employee number already in use")

    emp = Employee(
        username=payload.username,
        email=payload.email,
        full_name=payload.full_name,
        hashed_password=hash_password(payload.password),
        employee_number=payload.employee_number,
        department=payload.department,
        phone=payload.phone,
    )
    db.add(emp)
    db.commit()
    db.refresh(emp)
    return emp


# ─── POST /employees/login ────────────────────────────────────────────────────

@router.post("/login", response_model=EmployeeToken)
def login_employee(payload: EmployeeLogin, db: Session = Depends(get_db)):
    """
    Authenticate an employee and return a JWT access token.
    Uses 'emp_sub' claim — entirely separate from user tokens.
    """
    emp = db.query(Employee).filter(Employee.username == payload.username).first()
    if not emp or not verify_password(payload.password, emp.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    if not emp.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Employee account is disabled",
        )

    token = create_employee_token(data={"emp_sub": str(emp.id)})
    return EmployeeToken(
        access_token=token,
        employee=EmployeeOut.model_validate(emp),
    )


# ─── GET /employees/me ────────────────────────────────────────────────────────

@router.get("/me", response_model=EmployeeOut)
def get_my_profile(current_emp: Employee = Depends(get_current_employee)):
    """Return the currently logged-in employee's profile."""
    return current_emp


# ─── GET /employees ───────────────────────────────────────────────────────────

@router.get("", response_model=EmployeeListOut)
def list_employees(
    db: Session = Depends(get_db),
    current_emp: Employee = Depends(get_current_employee),
):
    """Return all employees (requires employee login)."""
    employees = db.query(Employee).all()
    return EmployeeListOut(total=len(employees), employees=employees)


# ─── GET /employees/{employee_id} ─────────────────────────────────────────────

@router.get("/{employee_id}", response_model=EmployeeOut)
def get_employee(
    employee_id: int,
    db: Session = Depends(get_db),
    current_emp: Employee = Depends(get_current_employee),
):
    """Return a single employee by ID (requires employee login)."""
    emp = db.query(Employee).filter(Employee.id == employee_id).first()
    if not emp:
        raise HTTPException(status_code=404, detail=f"Employee id={employee_id} not found")
    return emp


# ─── PUT /employees/{employee_id} ─────────────────────────────────────────────

@router.put("/{employee_id}", response_model=EmployeeOut)
def update_employee(
    employee_id: int,
    payload: EmployeeUpdate,
    db: Session = Depends(get_db),
    current_emp: Employee = Depends(get_current_employee),
):
    """Update an employee's own record (employees can only edit their own profile)."""
    emp = db.query(Employee).filter(Employee.id == employee_id).first()
    if not emp:
        raise HTTPException(status_code=404, detail=f"Employee id={employee_id} not found")

    if emp.id != current_emp.id:
        raise HTTPException(status_code=403, detail="Not authorised to update another employee's record")

    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(emp, field, value)

    db.commit()
    db.refresh(emp)
    return emp
