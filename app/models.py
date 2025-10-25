from __future__ import annotations
from datetime import datetime
from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, Text, ForeignKey
from sqlalchemy.orm import relationship
from .database import Base

class LogEntry(Base):
    __tablename__ = "logs"

    id = Column(Integer, primary_key=True, index=True)
    ts = Column(DateTime, default=datetime.utcnow, index=True)
    level = Column(String(20), default="INFO", index=True)
    message = Column(Text, nullable=False)
    latency_ms = Column(Integer, default=0)
    source = Column(String(100), default="unknown", index=True)
    is_anomaly = Column(Boolean, default=False, index=True)
    score = Column(Float, default=0.0)

    anomalies = relationship("Anomaly", back_populates="log", cascade="all, delete-orphan")

class Anomaly(Base):
    __tablename__ = "anomalies"

    id = Column(Integer, primary_key=True, index=True)
    log_id = Column(Integer, ForeignKey("logs.id", ondelete="CASCADE"), nullable=False, index=True)
    reason = Column(Text, nullable=False)
    score = Column(Float, default=0.0)
    created_at = Column(DateTime, default=datetime.utcnow, index=True)

    log = relationship("LogEntry", back_populates="anomalies")
