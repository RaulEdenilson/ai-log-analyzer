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
def from_json_payload(payload) -> List[schemas.LogIn]:
    """
    Admite:
      - lista de objetos (dict o LogIn)
      - un objeto único (dict o LogIn)
      - {"items": [...]}
    """
    print(f"DEBUG Parser: Input payload: {payload}")
    print(f"DEBUG Parser: Payload type: {type(payload)}")
    
    if isinstance(payload, list):
        print(f"DEBUG Parser: Processing as list, length: {len(payload)}")
        result = []
        for i, item in enumerate(payload):
            print(f"DEBUG Parser: Item {i}: {item}, type: {type(item)}")
            
            try:
                if isinstance(item, dict):
                    # Es un diccionario, procesarlo
                    coerced = _coerce_log_dict(item)
                    log_in = schemas.LogIn(**coerced)
                    result.append(log_in)
                    print(f"DEBUG Parser: Successfully processed dict item {i}")
                elif hasattr(item, 'level') and hasattr(item, 'message'):
                    # Es un objeto tipo LogIn, convertirlo a dict y procesarlo
                    item_dict = {
                        'level': getattr(item, 'level', 'INFO'),
                        'message': getattr(item, 'message', ''),
                        'latency_ms': getattr(item, 'latency_ms', 0),
                        'source': getattr(item, 'source', 'unknown'),
                        'ts': getattr(item, 'ts', None)
                    }
                    coerced = _coerce_log_dict(item_dict)
                    log_in = schemas.LogIn(**coerced)
                    result.append(log_in)
                    print(f"DEBUG Parser: Successfully processed LogIn-like item {i}")
                else:
                    print(f"DEBUG Parser: Skipping item {i} - unsupported type: {type(item)}")
            except Exception as e:
                print(f"DEBUG Parser: Error processing item {i}: {e}")
                import traceback
                traceback.print_exc()
                
        print(f"DEBUG Parser: Final result length: {len(result)}")
        return result
        
    elif isinstance(payload, dict):
        print(f"DEBUG Parser: Processing as dict")
        # Verificar si es un wrapper con "items"
        if "items" in payload and isinstance(payload.get("items"), list):
            print(f"DEBUG Parser: Found items array with {len(payload['items'])} items")
            return from_json_payload(payload["items"])  # Recursión
        else:
            # Es un objeto log individual
            print(f"DEBUG Parser: Processing as single log dict")
            try:
                coerced = _coerce_log_dict(payload)
                log_in = schemas.LogIn(**coerced)
                return [log_in]
            except Exception as e:
                print(f"DEBUG Parser: Error processing single dict: {e}")
                return []
                
    elif hasattr(payload, 'level') and hasattr(payload, 'message'):
        # Es un objeto LogIn individual
        print(f"DEBUG Parser: Processing single LogIn-like object")
        try:
            item_dict = {
                'level': getattr(payload, 'level', 'INFO'),
                'message': getattr(payload, 'message', ''),
                'latency_ms': getattr(payload, 'latency_ms', 0),
                'source': getattr(payload, 'source', 'unknown'),
                'ts': getattr(payload, 'ts', None)
            }
            coerced = _coerce_log_dict(item_dict)
            log_in = schemas.LogIn(**coerced)
            return [log_in]
        except Exception as e:
            print(f"DEBUG Parser: Error processing single LogIn: {e}")
            return []
    else:
        print(f"DEBUG Parser: Unsupported payload type: {type(payload)}")
        return []
def _coerce_log_dict(d: dict) -> dict:
    """Normaliza alias: ts/timestamp, message/msg, latency_ms/latency."""
    if not isinstance(d, dict):
        raise ValueError(f"Expected dict, got {type(d)}")
    
    print(f"DEBUG _coerce_log_dict: Input dict: {d}")
    
    # Procesar timestamp - PERMITIR None
    ts = d.get("ts") or d.get("timestamp")
    if isinstance(ts, str):
        try:
            ts = datetime.fromisoformat(ts.replace("Z", "+00:00"))
        except Exception as e:
            print(f"DEBUG _coerce_log_dict: Error parsing timestamp '{ts}': {e}")
            ts = None
    # NO forzar datetime.utcnow() - dejar None si no viene
    
    # Procesar mensaje - PERMITIR vacío
    message = d.get("message") or d.get("msg")
    if message is None:
        message = ""  # Permitir mensaje vacío
    
    # Procesar latencia
    try:
        latency_ms = int(d.get("latency_ms", d.get("latency", 0)) or 0)
    except (ValueError, TypeError):
        latency_ms = 0
    
    result = {
        "ts": ts,
        "level": str(d.get("level", "INFO")).upper(),
        "message": str(message),
        "latency_ms": latency_ms,
        "source": str(d.get("source", "unknown")),
    }
    
    print(f"DEBUG _coerce_log_dict: Output dict: {result}")
    return result
    """Normaliza alias: ts/timestamp, message/msg, latency_ms/latency."""
    if not isinstance(d, dict):
        raise ValueError(f"Expected dict, got {type(d)}")
    
    print(f"DEBUG _coerce_log_dict: Input dict: {d}")
    
    # Procesar timestamp
    ts = d.get("ts") or d.get("timestamp")
    if isinstance(ts, str):
        try:
            ts = datetime.fromisoformat(ts.replace("Z", "+00:00"))
        except Exception as e:
            print(f"DEBUG _coerce_log_dict: Error parsing timestamp '{ts}': {e}")
            ts = None
    elif ts is None:
        ts = datetime.utcnow()  # Usar timestamp actual si no se proporciona
    
    # Procesar mensaje
    message = d.get("message") or d.get("msg") or ""
    if not message:
        raise ValueError("Message is required and cannot be empty")
    
    # Procesar latencia
    try:
        latency_ms = int(d.get("latency_ms", d.get("latency", 0)) or 0)
    except (ValueError, TypeError):
        latency_ms = 0
    
    result = {
        "ts": ts,
        "level": str(d.get("level", "INFO")).upper(),
        "message": str(message),
        "latency_ms": latency_ms,
        "source": str(d.get("source", "unknown")),
    }
    
    print(f"DEBUG _coerce_log_dict: Output dict: {result}")
    return result

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
