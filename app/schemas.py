from __future__ import annotations
from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel, Field

class LogIn(BaseModel):
    ts: Optional[datetime] = None
    level: Optional[str] = Field(default="INFO", examples=["INFO", "WARN", "ERROR", "CRITICAL"])
    message: str
    latency_ms: Optional[int] = 0

class LogOut(BaseModel):
    id: int
    ts: datetime
    level: str
    message: str
    latency_ms: int
    is_anomaly: bool
    score: float
    reasons: List[str] = []

    class Config:
        from_attributes = True  # pydantic v2: permite construir desde ORM

class AnomalyOut(BaseModel):
    id: int
    created_at: datetime
    score: float
    reason: str
    log_id: int
    level: str
    message: str
    latency_ms: int
    ts: datetime
