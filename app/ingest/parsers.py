from __future__ import annotations
import json
import re
from datetime import datetime
from typing import Iterable, Iterator, List

from fastapi import UploadFile
from app import schemas

# Línea texto plano: "2025-01-02T03:04:05Z INFO mensaje..."
_LINE_RE = re.compile(
    r"^(?P<ts>\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}:\d{2}(?:Z|[+-]\d{2}:\d{2})?)\s+"
    r"(?P<level>[A-Z]+)\s+(?P<msg>.+)$"
)

def _parse_text_line(line: str) -> schemas.LogIn | None:
    line = line.strip()
    if not line:
        return None
    m = _LINE_RE.match(line)
    if not m:
        # línea libre → INFO sin timestamp
        return schemas.LogIn(ts=None, level="INFO", message=line, latency_ms=0)

    ts_raw = m.group("ts")
    try:
        ts = datetime.fromisoformat(ts_raw.replace("Z", "+00:00"))
    except Exception:
        ts = None

    level = (m.group("level") or "INFO").upper()
    msg = m.group("msg") or ""
    return schemas.LogIn(ts=ts, level=level, message=msg, latency_ms=0)

# -------- JSON (payload del endpoint) --------
def from_json_payload(payload: dict | list) -> List[schemas.LogIn]:
    """
    Admite:
      - lista de objetos
      - un objeto único
      - {"items": [...]}
    """
    if isinstance(payload, list):
        return [schemas.LogIn(**_coerce_log_dict(d)) for d in payload if isinstance(d, dict)]
    if isinstance(payload, dict):
        if isinstance(payload.get("items"), list):
            return [schemas.LogIn(**_coerce_log_dict(d)) for d in payload["items"] if isinstance(d, dict)]
        return [schemas.LogIn(**_coerce_log_dict(payload))]
    return []

def _coerce_log_dict(d: dict) -> dict:
    """Normaliza alias: ts/timestamp, message/msg, latency_ms/latency."""
    if not isinstance(d, dict):
        raise ValueError(f"Expected dict, got {type(d)}")
    
    ts = d.get("ts") or d.get("timestamp")
    if isinstance(ts, str):
        try:
            ts = datetime.fromisoformat(ts.replace("Z", "+00:00"))
        except Exception:
            ts = None
    
    return {
        "ts": ts,
        "level": str(d.get("level", "INFO")).upper(),
        "message": str(d.get("message", d.get("msg", ""))),
        "latency_ms": int(d.get("latency_ms", d.get("latency", 0)) or 0),
        "source": str(d.get("source", "unknown")),
    }

# -------- Archivos (.jsonl / .log) --------
def _iter_file_lines(file: UploadFile) -> Iterator[str]:
    while True:
        chunk = file.file.readline()
        if not chunk:
            break
        yield chunk.decode(errors="ignore")

def from_jsonl_file(file: UploadFile) -> List[schemas.LogIn]:
    out: List[schemas.LogIn] = []
    for ln in _iter_file_lines(file):
        ln = ln.strip()
        if not ln:
            continue
        try:
            obj = json.loads(ln)
            out.append(schemas.LogIn(**_coerce_log_dict(obj)))
        except Exception:
            continue
    return out

def from_plain_file(file: UploadFile) -> List[schemas.LogIn]:
    out: List[schemas.LogIn] = []
    for ln in _iter_file_lines(file):
        item = _parse_text_line(ln)
        if item:
            out.append(item)
    return out
