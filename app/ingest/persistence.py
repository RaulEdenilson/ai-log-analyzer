from __future__ import annotations
from typing import List
from sqlalchemy.orm import Session

from app import models, schemas

def persist_log_and_anomalies(
    db: Session,
    item: schemas.LogIn,
    is_anom: bool,
    score: float,
    reasons: List[str],
) -> models.LogEntry:
    row = models.LogEntry(
        ts=item.ts,
        level=(item.level or "INFO").upper(),
        message=item.message,
        latency_ms=int(item.latency_ms or 0),
        source=item.source or "unknown",
        is_anomaly=bool(is_anom),
        score=float(score),
    )
    db.add(row)
    db.flush()

    if is_anom and reasons:
        combined_reason = ", ".join(reasons)
        db.add(models.Anomaly(log_id=row.id, reason=combined_reason, score=float(score)))

    return row


def persist_many(
    db: Session,
    items: List[schemas.LogIn],
    anomalies_info: List[tuple[bool, float, List[str]]],
) -> List[models.LogEntry]:
    rows: List[models.LogEntry] = []
    for it, (is_anom, score, reasons) in zip(items, anomalies_info):
        rows.append(persist_log_and_anomalies(db, it, is_anom, score, reasons))
    return rows