from __future__ import annotations
import os

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# Puedes centralizar esto en app/config.py si prefieres.
SQLITE_URL = os.getenv("SQLITE_URL", "sqlite:///./data.db")

engine = create_engine(
    SQLITE_URL,
    connect_args={"check_same_thread": False} if SQLITE_URL.startswith("sqlite") else {},
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
