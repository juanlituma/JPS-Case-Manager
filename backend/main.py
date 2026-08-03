"""
main.py — FastAPI application entry point
Run with:  uvicorn main:app --host 0.0.0.0 --port 8000 --reload
"""

import time

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware

from database import engine, Base
from routers import users, cases, employees
from logger import get_logger

logger = get_logger("access")

# ─── Create all tables on startup ─────────────────────────────────────────────
Base.metadata.create_all(bind=engine)

# ─── App ──────────────────────────────────────────────────────────────────────
app = FastAPI(
    title="JPS Case Management API",
    description=(
        "Backend server for the JPS Case Management System.\n\n"
        "Supports user registration/login (JWT), case creation, "
        "case updates, and case queries."
    ),
    version="1.0.0",
    docs_url="/docs",       # Swagger UI
    redoc_url="/redoc",     # ReDoc UI
)

# ─── Access-log middleware ────────────────────────────────────────────────────
@app.middleware("http")
async def access_log_middleware(request: Request, call_next):
    """
    Log every HTTP request and its response.

    Logged fields:
      • client IP
      • HTTP method + path + query string
      • actor type & ID extracted from the JWT (if present)
      • HTTP response status code
      • response time in milliseconds
    """
    start = time.perf_counter()

    # ── Try to identify the caller from the Authorization header ──────────────
    actor_info = "anonymous"
    auth_header = request.headers.get("Authorization", "")
    if auth_header.startswith("Bearer "):
        try:
            from jose import jwt as _jwt
            from auth import SECRET_KEY, ALGORITHM
            token = auth_header.split(" ", 1)[1]
            payload = _jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
            if "emp_sub" in payload:
                actor_info = f"employee:{payload['emp_sub']}"
            elif "sub" in payload:
                actor_info = f"user:{payload['sub']}"
        except Exception:
            actor_info = "invalid-token"

    # ── Determine the client IP (handle reverse-proxy headers) ────────────────
    client_ip = request.headers.get("X-Forwarded-For", "").split(",")[0].strip()
    if not client_ip:
        client_ip = request.client.host if request.client else "unknown"

    query = f"?{request.url.query}" if request.url.query else ""

    response = await call_next(request)

    elapsed_ms = (time.perf_counter() - start) * 1000

    logger.info(
        '%s "%s %s%s" %s %.1fms actor=%s',
        client_ip,
        request.method,
        request.url.path,
        query,
        response.status_code,
        elapsed_ms,
        actor_info,
    )

    return response


# ─── CORS ─────────────────────────────────────────────────────────────────────
# Allow the iOS app and Windows client to call this API.
# In production, replace ["*"] with your specific origins.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─── Routers ──────────────────────────────────────────────────────────────────
app.include_router(users.router)
app.include_router(cases.router)
app.include_router(employees.router)


# ─── Health check ─────────────────────────────────────────────────────────────
@app.get("/", tags=["Health"])
def root():
    return {"status": "ok", "message": "JPS Case Management API is running"}
