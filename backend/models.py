"""
models.py — SQLAlchemy ORM models for User, Employee, and Case tables
"""

from datetime import datetime, timezone, timedelta
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError
from sqlalchemy import (
    Column, Integer, String, Text, Enum, DateTime,
    ForeignKey, Boolean
)
from sqlalchemy.orm import relationship
from database import Base
import enum

# New York / Eastern Time — used so updated_at is stored in ET, not UTC
# Falls back gracefully if tzdata is not yet installed (Windows requires it separately).
try:
    _EASTERN = ZoneInfo("America/New_York")
    def _now_eastern() -> datetime:
        """Return the current time in New York (ET), timezone-stripped for DB storage."""
        return datetime.now(_EASTERN).replace(tzinfo=None)
except ZoneInfoNotFoundError:
    # tzdata package not installed — approximate with a fixed UTC-5 offset.
    # Run:  pip install tzdata   to get proper DST-aware Eastern Time.
    _ET_OFFSET = timedelta(hours=-5)
    def _now_eastern() -> datetime:  # type: ignore[misc]
        return datetime.now(timezone(_ET_OFFSET)).replace(tzinfo=None)


# ─── Enums ────────────────────────────────────────────────────────────────────

class CaseStatus(str, enum.Enum):
    OPEN        = "open"
    IN_PROGRESS = "in_progress"
    RESOLVED    = "resolved"


class DeliveryProvider(str, enum.Enum):
    UBER          = "Uber"
    DOORDASH      = "DoorDash"
    GRABHUB       = "GrabHub"
    SELF_DELIVERY = "Self Delivery"


class ComplaintType(str, enum.Enum):
    NOT_RECEIVE_FOOD    = "not_receive_food"
    FOOD_BAD_QUALITY    = "food_bad_quality"
    MISSING_ITEM        = "missing_item"
    RECEIVED_WRONG_ORDER = "received_wrong_order"


# ─── User (iOS app accounts) ──────────────────────────────────────────────────

class User(Base):
    __tablename__ = "users"

    id              = Column(Integer, primary_key=True, index=True, autoincrement=True)
    username        = Column(String(100), unique=True, nullable=False, index=True)
    email           = Column(String(255), unique=True, nullable=False, index=True)
    full_name       = Column(String(255), nullable=True)
    hashed_password = Column(String(255), nullable=False)
    is_active       = Column(Boolean, default=True, nullable=False)
    created_at      = Column(DateTime, default=_now_eastern, nullable=False)
    updated_at      = Column(DateTime, default=_now_eastern, onupdate=_now_eastern)

    # Relationships
    created_cases  = relationship("Case", back_populates="creator",
                                  foreign_keys="Case.created_by_id")


# ─── Employee (Windows app accounts — completely separate from users) ──────────

class Employee(Base):
    __tablename__ = "employees"

    id              = Column(Integer, primary_key=True, index=True, autoincrement=True)
    # Login credentials (independent of users table)
    username        = Column(String(100), unique=True, nullable=False, index=True)
    email           = Column(String(255), unique=True, nullable=False, index=True)
    full_name       = Column(String(255), nullable=True)
    hashed_password = Column(String(255), nullable=False)
    is_active       = Column(Boolean, default=True, nullable=False)
    # Employee-specific info
    employee_number = Column(String(50), unique=True, nullable=False)
    department      = Column(String(100), nullable=True)
    phone           = Column(String(50), nullable=True)
    created_at      = Column(DateTime, default=_now_eastern, nullable=False)
    updated_at      = Column(DateTime, default=_now_eastern, onupdate=_now_eastern)


# ─── Case ─────────────────────────────────────────────────────────────────────

class Case(Base):
    __tablename__ = "cases"

    id                = Column(Integer, primary_key=True, index=True, autoincrement=True)
    title             = Column(String(255), nullable=False)
    description       = Column(Text, nullable=True)
    solution          = Column(Text, nullable=True)
    delivery_provider = Column(Enum(DeliveryProvider, values_callable=lambda obj: [e.value for e in obj]),
                               nullable=True)
    complaint_type    = Column(Enum(ComplaintType, values_callable=lambda obj: [e.value for e in obj]),
                               nullable=True)
    status            = Column(Enum(CaseStatus, values_callable=lambda obj: [e.value for e in obj]),
                               default=CaseStatus.OPEN, nullable=False)
    # created_by_id is nullable — set when an iOS User creates a case
    created_by_id  = Column(Integer, ForeignKey("users.id"),     nullable=True)
    assigned_to_id = Column(Integer, ForeignKey("employees.id"), nullable=True)
    created_at             = Column(DateTime, default=_now_eastern, nullable=False)
    updated_at             = Column(DateTime, default=_now_eastern,
                                    onupdate=_now_eastern, nullable=False)

    # Relationships
    creator  = relationship("User",     back_populates="created_cases",
                            foreign_keys=[created_by_id])
    assignee = relationship("Employee", foreign_keys=[assigned_to_id])
