from __future__ import annotations
from time import perf_counter
from typing import List

from fastapi import FastAPI, Body, UploadFile, File, Query, Depends
from fastapi.responses import PlainTextResponse
from prometheus_client import (
    REGISTRY, generate_latest, CONTENT_TYPE_LATEST, Counter, Histogram
)

from sqlalchemy import desc
from sqlalchemy.orm import Session

from app.database import Base, engine, get_db
from app import schemas, models
from app.ingest import IngestService  # <- NUEVO: orquestador modular (parsers+scoring+persistence)

app = FastAPI(title="AI Log Analyzer", version="0.4.0")

# =====================
# Métricas HTTP
# =====================
REQ_COUNTER = Counter("http_requests_total", "Total de requests", ["method", "path", "status"])
REQ_LATENCY = Histogram("http_request_duration_seconds", "Latencia por request", ["method", "path"])

@app.middleware("http")
async def metrics_middleware(request, call_next):
    path = request.url.path
    method = request.method
    start = perf_counter()
    status = 500
    try:
        response = await call_next(request)
        status = response.status_code
        return response
    finally:
        duration = perf_counter() - start
        REQ_LATENCY.labels(method=method, path=path).observe(duration)
        REQ_COUNTER.labels(method=method, path=path, status=str(status)).inc()

# Crear tablas (SQLite) al levantar
Base.metadata.create_all(bind=engine)

@app.get("/health")
def health():
    return {"status": "ok"}

# =====================
# Ingesta JSON
# =====================
@app.post("/upload-log", response_model=List[schemas.LogOut])
def upload_log_json(
    payload: list[schemas.LogIn] | dict = Body(...),
    db: Session = Depends(get_db),
):
    """
    Ingesta vía JSON (single o batch).
    Devuelve la lista de logs normalizados con flags de anomalía (LogOut).
    """
    return IngestService(db).process_payload(payload)

# =====================
# Ingesta archivo (.jsonl / .log)
# =====================
@app.post("/upload-log-file", response_model=List[schemas.LogOut])
async def upload_log_file(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    """
    Ingesta vía archivo .log o .jsonl (multipart/form-data, key: file).
    """
    return await IngestService(db).process_file(file)

# =====================
# Métricas Prometheus
# =====================
@app.get("/metrics")
def metrics():
    data = generate_latest(REGISTRY)
    return PlainTextResponse(content=data.decode("utf-8"), media_type=CONTENT_TYPE_LATEST)

# =====================
# Anomalías desde DB
# =====================
@app.get("/anomalies", response_model=List[schemas.AnomalyOut])
def get_anomalies(
    limit: int = Query(20, ge=1, le=500),
    db: Session = Depends(get_db),
):
    """
    Lista las últimas N anomalías consultando la base de datos (no memoria).
    """
    q = (
        db.query(models.Anomaly, models.LogEntry)
          .join(models.LogEntry, models.Anomaly.log_id == models.LogEntry.id)
          .order_by(desc(models.Anomaly.created_at))
          .limit(limit)
    )
    out: list[schemas.AnomalyOut] = []
    for anom, log in q.all():
        out.append(
            schemas.AnomalyOut(
                id=anom.id,
                created_at=anom.created_at,
                score=anom.score,
                reason=anom.reason,
                log_id=log.id,
                level=log.level,
                message=log.message,
                latency_ms=log.latency_ms,
                ts=log.ts,
            )
        )
    return out

# =====================
# (Opcional) Tick IF/ventanas
# =====================
# Si tienes una clase detector con step()/last_anomalies(), deja este endpoint;
# si no, puedes eliminarlo sin afectar el resto.
try:
    from app.services.anomaly import detector  # si ya lo tenías
    @app.post("/tick")
    def tick():
        wf, score, is_anom = detector.step()
        return {
            "window": {"start": wf.start.isoformat(), "end": wf.end.isoformat()},
            "features": {
                "total": wf.total,
                "info": wf.count_info,
                "warn": wf.count_warn,
                "error": wf.count_error,
                "unique_sources": wf.unique_sources,
            },
            "score": round(score, 4),
            "is_anomalous": is_anom,
        }
except Exception:
    # No hay detector de ventanas: endpoint omitido
    pass

