"""
routers/users.py — User registration and login endpoints (iOS accounts)
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from database import get_db
from models import User
from schemas import UserCreate, UserLogin, UserOut, Token
from auth import (
    hash_password, verify_password, create_access_token,
    get_current_user, get_current_employee,
)

router = APIRouter(prefix="/auth", tags=["Authentication"])


# ─── POST /auth/register ──────────────────────────────────────────────────────

@router.post("/register", response_model=UserOut, status_code=status.HTTP_201_CREATED)
def register(payload: UserCreate, db: Session = Depends(get_db)):
    """
    Create a new user account (iOS app).
    - username and email must be unique
    - password is stored as a bcrypt hash
    """
    if db.query(User).filter(User.username == payload.username).first():
        raise HTTPException(status_code=400, detail="Username already registered")
    if db.query(User).filter(User.email == payload.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")

    new_user = User(
        username=payload.username,
        email=payload.email,
        full_name=payload.full_name,
        hashed_password=hash_password(payload.password),
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


# ─── POST /auth/login ─────────────────────────────────────────────────────────

@router.post("/login", response_model=Token)
def login(payload: UserLogin, db: Session = Depends(get_db)):
    """
    Authenticate a user (iOS app) and return a JWT access token.
    Token uses 'sub' claim — separate from employee tokens.
    """
    user = db.query(User).filter(User.username == payload.username).first()
    if not user or not verify_password(payload.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    if not user.is_active:
        raise HTTPException(status_code=403, detail="Account is disabled")

    token = create_access_token(data={"sub": str(user.id)})
    return Token(access_token=token, user=UserOut.model_validate(user))


# ─── GET /auth/me ─────────────────────────────────────────────────────────────

@router.get("/me", response_model=UserOut)
def get_me(current_user: User = Depends(get_current_user)):
    """Return the currently authenticated user's profile."""
    return current_user


# ─── GET /auth/users ──────────────────────────────────────────────────────────

@router.get("/users", response_model=list[UserOut])
def list_users(
    db: Session = Depends(get_db),
    # Accessible by employees (Windows) to populate the assign-to dropdown
    _emp=Depends(get_current_employee),
):
    """
    Return all active users (iOS accounts).
    Used by the Windows app to populate the 'Assign To' dropdown when
    creating or editing a case. Requires a valid employee token.
    """
    users = db.query(User).filter(User.is_active == True).all()
    return users
