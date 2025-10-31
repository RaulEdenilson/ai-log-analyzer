from __future__ import annotations
from time import perf_counter
from typing import List, Any

from fastapi import FastAPI, Body, UploadFile, File, Query, Depends
from fastapi.responses import PlainTextResponse
from prometheus_client import (
    REGISTRY, generate_latest, CONTENT_TYPE_LATEST, Counter, Histogram
)

from sqlalchemy import desc
from sqlalchemy.orm import Session

from app.database import Base, engine, get_db
from app import schemas, models
from app.ingest import IngestService

app = FastAPI(title="AI Log Analyzer", version="0.4.0")

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

Base.metadata.create_all(bind=engine)

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/debug-upload")
def debug_upload(request: Any = Body(...)):
    return {
        "received_type": str(type(request)),
        "received_data": str(request),
        "is_list": isinstance(request, list),
        "is_dict": isinstance(request, dict),
        "length": len(request) if hasattr(request, '__len__') else "N/A",
        "first_item_type": str(type(request[0])) if isinstance(request, list) and len(request) > 0 else "N/A"
    }

@app.post("/upload-log", response_model=List[schemas.LogOut])
def upload_log_json(
    payload: Any = Body(...),
    db: Session = Depends(get_db),
):
    try:
        print(f"DEBUG ENDPOINT: Received payload type: {type(payload)}")
        print(f"DEBUG ENDPOINT: Payload content: {payload}")
        
        items = []
        
        if isinstance(payload, list):
            print(f"DEBUG ENDPOINT: Processing list with {len(payload)} items")
            for idx, item in enumerate(payload):
                try:
                    if isinstance(item, dict):
                        log_in = schemas.LogIn(
                            ts=item.get('ts'),
                            level=item.get('level', 'INFO'),
                            message=item.get('message', ''),
                            latency_ms=item.get('latency_ms', 0),
                            source=item.get('source', 'unknown')
                        )
                        items.append(log_in)
                        print(f"DEBUG ENDPOINT: Successfully processed item {idx}")
                    else:
                        print(f"DEBUG ENDPOINT: Skipping non-dict item {idx}")
                except Exception as e:
                    print(f"ERROR ENDPOINT: Failed to process item {idx}: {e}")
                    continue
                    
        elif isinstance(payload, dict):
            print(f"DEBUG ENDPOINT: Processing single dict")
            log_in = schemas.LogIn(
                ts=payload.get('ts'),
                level=payload.get('level', 'INFO'),
                message=payload.get('message', ''),
                latency_ms=payload.get('latency_ms', 0),
                source=payload.get('source', 'unknown')
            )
            items.append(log_in)
        
        if not items:
            print("WARNING ENDPOINT: No items to process after parsing")
            return []
        
        print(f"DEBUG ENDPOINT: Processing {len(items)} items through service")
        service = IngestService(db)
        result = service._process_items(items)
        
        print(f"DEBUG ENDPOINT: Returning {len(result)} results")
        return result
        
    except Exception as e:
        print(f"ERROR ENDPOINT: Exception occurred: {e}")
        import traceback
        traceback.print_exc()
        from fastapi import HTTPException
        raise HTTPException(status_code=400, detail=f"Error processing payload: {str(e)}")

@app.post("/upload-log-file", response_model=List[schemas.LogOut])
async def upload_log_file(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    return await IngestService(db).process_file(file)

@app.get("/metrics")
def metrics():
    data = generate_latest(REGISTRY)
    return PlainTextResponse(content=data.decode("utf-8"), media_type=CONTENT_TYPE_LATEST)

@app.get("/anomalies")
def get_anomalies(
    limit: int = Query(20, ge=1, le=500),
    db: Session = Depends(get_db),
):
    try:
        anomalies = db.query(models.Anomaly).limit(limit).all()
        
        result = []
        for anom in anomalies:
            try:
                log = db.query(models.LogEntry).filter(models.LogEntry.id == anom.log_id).first()
                if log:
                    result.append({
                        "id": anom.id,
                        "created_at": anom.created_at.isoformat() if anom.created_at else None,
                        "score": anom.score,
                        "reason": anom.reason,
                        "log_id": log.id,
                        "level": log.level,
                        "message": log.message,
                        "latency_ms": log.latency_ms,
                        "ts": log.ts.isoformat() if log.ts else None,
                    })
            except Exception as e:
                continue
        
        return {"anomalies": result, "count": len(result)}
    except Exception as e:
        return {"error": str(e), "anomalies": [], "count": 0}

try:
    from app.services.anomaly import detector
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
    pass