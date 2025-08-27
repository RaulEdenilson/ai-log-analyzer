from fastapi import FastAPI
from fastapi.responses import Response
from pydantic import BaseModel
from typing import List, Union
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = FastAPI(title="AI Log Analyzer", version="0.1.0")
REQUESTS = Counter("requests_total", "Total requests", ["endpoint"])

class LogRecord(BaseModel):
    service: str
    level: str
    msg: str
    ts: str  # ISO-8601

@app.get("/health")
def health():
    REQUESTS.labels("health").inc()
    return {"status": "ok"}

@app.post("/upload-log")
def upload_log(payload: Union[LogRecord, List[LogRecord]]):
    count = len(payload) if isinstance(payload, list) else 1
    REQUESTS.labels("upload_log").inc(count)
    return {"accepted": count}

@app.get("/metrics")
def metrics():
    data = generate_latest()
    return Response(content=data, media_type=CONTENT_TYPE_LATEST)
