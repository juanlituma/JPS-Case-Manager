"""
schemas.py — Pydantic request / response models
"""

from datetime import datetime
from typing import Optional
from pydantic import BaseModel, EmailStr
from models import CaseStatus, DeliveryProvider, ComplaintType


# ─── Auth / User (iOS accounts) ───────────────────────────────────────────────

class UserCreate(BaseModel):
    """Body for POST /auth/register"""
    username:  str
    email:     EmailStr
    full_name: Optional[str] = None
    password:  str


class UserLogin(BaseModel):
    """Body for POST /auth/login"""
    username: str
    password: str


class UserOut(BaseModel):
    """Returned after register or in profile responses"""
    id:         int
    username:   str
    email:      str
    full_name:  Optional[str]
    is_active:  bool
    created_at: datetime

    class Config:
        from_attributes = True


class Token(BaseModel):
    """Returned after successful user login"""
    access_token: str
    token_type:   str = "bearer"
    user:         UserOut


# ─── Employee Auth (Windows accounts — separate from users) ───────────────────

class EmployeeRegister(BaseModel):
    """Body for POST /employees/register"""
    username:        str
    email:           EmailStr
    full_name:       Optional[str] = None
    password:        str
    employee_number: str
    department:      Optional[str] = None
    phone:           Optional[str] = None


class EmployeeLogin(BaseModel):
    """Body for POST /employees/login"""
    username: str
    password: str


class EmployeeOut(BaseModel):
    """Returned for a single employee — no user object nested"""
    id:              int
    username:        str
    email:           str
    full_name:       Optional[str]
    employee_number: str
    department:      Optional[str]
    phone:           Optional[str]
    is_active:       bool
    created_at:      datetime

    class Config:
        from_attributes = True


class EmployeeToken(BaseModel):
    """Returned after successful employee login"""
    access_token: str
    token_type:   str = "bearer"
    employee:     EmployeeOut


class EmployeeUpdate(BaseModel):
    """Body for PUT /employees/{id} — all fields optional"""
    full_name:       Optional[str] = None
    employee_number: Optional[str] = None
    department:      Optional[str] = None
    phone:           Optional[str] = None


class EmployeeListOut(BaseModel):
    total:     int
    employees: list[EmployeeOut]


# ─── Case ─────────────────────────────────────────────────────────────────────

class CaseCreate(BaseModel):
    """Body for POST /cases"""
    title:             str
    description:       Optional[str]             = None
    solution:          Optional[str]             = None
    delivery_provider: Optional[DeliveryProvider] = None
    complaint_type:    Optional[ComplaintType]    = None
    assigned_to_id:    Optional[int]             = None


class CaseUpdate(BaseModel):
    """Body for PUT /cases/{id} — all fields optional"""
    title:             Optional[str]              = None
    description:       Optional[str]              = None
    solution:          Optional[str]              = None
    delivery_provider: Optional[DeliveryProvider] = None
    complaint_type:    Optional[ComplaintType]     = None
    status:            Optional[CaseStatus]        = None
    assigned_to_id:    Optional[int]               = None


class CaseOut(BaseModel):
    """Returned for a single case"""
    id:                    int
    title:                 str
    description:           Optional[str]
    solution:              Optional[str]
    delivery_provider:     Optional[DeliveryProvider]
    complaint_type:        Optional[ComplaintType]
    status:                CaseStatus
    created_by_id:    Optional[int]          # set when an iOS User created the case
    created_by_name:  Optional[str] = None  # computed: display name of the creator
    assigned_to_id:   Optional[int]
    assigned_to_name: Optional[str] = None  # computed: display name of the assigned employee
    created_at:            datetime
    updated_at:            datetime

    class Config:
        from_attributes = True


class CaseListOut(BaseModel):
    """Returned for paginated case list"""
    total: int
    cases: list[CaseOut]
