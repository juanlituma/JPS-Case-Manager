"""
logger.py — Centralised logging configuration for the JPS backend.

Usage (in any module):
    from logger import get_logger
    logger = get_logger(__name__)
    logger.info("something happened")

Log files are written to  backend/logs/access.log  and rotated at 5 MB,
keeping the last 5 backups.  All messages also appear on stdout so
uvicorn's console output stays useful during development.
"""

import logging
import os
from logging.handlers import RotatingFileHandler

# ─── Paths ────────────────────────────────────────────────────────────────────

# Resolve the directory that contains this file (backend/)
_BASE_DIR  = os.path.dirname(os.path.abspath(__file__))
_LOGS_DIR  = os.path.join(_BASE_DIR, "logs")
_LOG_FILE  = os.path.join(_LOGS_DIR, "access.log")

os.makedirs(_LOGS_DIR, exist_ok=True)

# ─── Format ───────────────────────────────────────────────────────────────────

_LOG_FORMAT = "%(asctime)s | %(levelname)-8s | %(name)s | %(message)s"
_DATE_FORMAT = "%Y-%m-%d %H:%M:%S"

# ─── Root logger ──────────────────────────────────────────────────────────────

def _configure_root() -> None:
    """Configure handlers on the root logger once."""
    root = logging.getLogger()
    if root.handlers:
        return  # already configured (e.g. uvicorn reloads)

    root.setLevel(logging.INFO)

    formatter = logging.Formatter(_LOG_FORMAT, datefmt=_DATE_FORMAT)

    # Rotating file handler — 5 MB per file, keep 5 backups
    fh = RotatingFileHandler(
        _LOG_FILE,
        maxBytes=5 * 1024 * 1024,  # 5 MB
        backupCount=5,
        encoding="utf-8",
    )
    fh.setLevel(logging.INFO)
    fh.setFormatter(formatter)

    # Console handler
    ch = logging.StreamHandler()
    ch.setLevel(logging.INFO)
    ch.setFormatter(formatter)

    root.addHandler(fh)
    root.addHandler(ch)


_configure_root()


# ─── Public helper ────────────────────────────────────────────────────────────

def get_logger(name: str) -> logging.Logger:
    """Return a named logger.  Call once at module level with __name__."""
    return logging.getLogger(name)
