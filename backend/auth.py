"""
auth.py — Password hashing + JWT token utilities
          Supports two separate actor types: User (iOS) and Employee (Windows)
"""

import os
from datetime import datetime, timedelta
from typing import Optional, Tuple, Union

from dotenv import load_dotenv
from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import Depends, HTTPException, Request, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from database import get_db
from models import User, Employee

load_dotenv()

from logger import get_logger as _get_logger
_auth_logger = _get_logger("auth")

# ─── Config ───────────────────────────────────────────────────────────────────

SECRET_KEY                  = os.getenv("JWT_SECRET_KEY", "282efa5d3b68c50064d0a7c4eae08a8064185675f49822aa8436f48f66c8d04a")
ALGORITHM                   = os.getenv("JWT_ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "60"))

# ─── Password hashing ─────────────────────────────────────────────────────────

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(plain_password: str) -> str:
    return pwd_context.hash(plain_password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

# ─── JWT helpers ──────────────────────────────────────────────────────────────

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """Create a JWT for a User. Payload key: 'sub' (user ID)."""
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def create_employee_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """Create a JWT for an Employee. Payload key: 'emp_sub' (employee ID)."""
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# ─── OAuth2 schemes (used for OpenAPI Swagger UI) ─────────────────────────────

oauth2_scheme          = OAuth2PasswordBearer(tokenUrl="/auth/login")
employee_oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/employees/login")

# ─── User dependency ──────────────────────────────────────────────────────────

def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db),
) -> User:
    """FastAPI dependency — decodes JWT and returns the authenticated User."""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("sub")
        if user_id is None:
            _auth_logger.warning("Token rejected: missing 'sub' claim (user auth)")
            raise credentials_exception
    except JWTError:
        _auth_logger.warning("Token rejected: invalid or expired JWT (user auth)")
        raise credentials_exception

    user = db.query(User).filter(User.id == int(user_id)).first()
    if user is None or not user.is_active:
        _auth_logger.warning("Token rejected: user id=%s not found or inactive", user_id)
        raise credentials_exception
    _auth_logger.info("Token validated: user id=%s (%s)", user.id, user.username)
    return user

# ─── Employee dependency ──────────────────────────────────────────────────────

def get_current_employee(
    token: str = Depends(employee_oauth2_scheme),
    db: Session = Depends(get_db),
) -> Employee:
    """FastAPI dependency — decodes JWT and returns the authenticated Employee."""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate employee credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        emp_id = payload.get("emp_sub")
        if emp_id is None:
            _auth_logger.warning("Token rejected: missing 'emp_sub' claim (employee auth)")
            raise credentials_exception
    except JWTError:
        _auth_logger.warning("Token rejected: invalid or expired JWT (employee auth)")
        raise credentials_exception

    emp = db.query(Employee).filter(Employee.id == int(emp_id)).first()
    if emp is None or not emp.is_active:
        _auth_logger.warning("Token rejected: employee id=%s not found or inactive", emp_id)
        raise credentials_exception
    _auth_logger.info("Token validated: employee id=%s (%s)", emp.id, emp.username)
    return emp

# ─── Combined dependency (user OR employee) ───────────────────────────────────

def get_any_actor(
    request: Request,
    db: Session = Depends(get_db),
) -> Tuple[str, Union[User, Employee]]:
    """
    FastAPI dependency that accepts a JWT from either a User or an Employee.
    Returns ("user", User) or ("employee", Employee).
    Used by the cases router so both iOS users and Windows employees can
    create, view, and update cases.
    """
    auth_header = request.headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        _auth_logger.warning("Request rejected: no Bearer token provided (%s %s)", request.method, request.url.path)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Not authenticated — provide a Bearer token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    token = auth_header.split(" ", 1)[1]
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    except JWTError:
        _auth_logger.warning("Request rejected: invalid or expired token (%s %s)", request.method, request.url.path)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Employee token
    if "emp_sub" in payload:
        emp_id = payload["emp_sub"]
        emp = db.query(Employee).filter(Employee.id == int(emp_id)).first()
        if emp and emp.is_active:
            _auth_logger.info("Actor resolved: employee id=%s (%s)", emp.id, emp.username)
            return ("employee", emp)
        _auth_logger.warning("Token rejected: employee id=%s not found or inactive", emp_id)

    # User token
    elif "sub" in payload:
        user_id = payload["sub"]
        user = db.query(User).filter(User.id == int(user_id)).first()
        if user and user.is_active:
            _auth_logger.info("Actor resolved: user id=%s (%s)", user.id, user.username)
            return ("user", user)
        _auth_logger.warning("Token rejected: user id=%s not found or inactive", user_id)

    else:
        _auth_logger.warning("Token rejected: payload has neither 'sub' nor 'emp_sub'")

    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
