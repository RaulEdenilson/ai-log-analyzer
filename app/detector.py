import re
from typing import Tuple, List
from .config import ANOMALY_THRESHOLD, LATENCY_MS_THRESHOLD

# Patrones simples de error en el mensaje
_ERR_PATTERNS = [
    r"\bexception\b",
    r"\btraceback\b",
    r"\btimeout\b",
    r"\bfailed\b|\bfailure\b",
    r"\brefused\b|\bunreachable\b",
    r"\b5\d{2}\b",  # HTTP 5xx
]

# Peso base por nivel
_LEVEL_WEIGHTS = {
    "DEBUG": 0.0,
    "INFO": 0.0,
    "WARN": 0.35,
    "WARNING": 0.35,
    "ERROR": 0.6,
    "CRITICAL": 0.8,
}

# Contribuciones al score
_LAT_WEIGHT = 0.4   # si supera LATENCY_MS_THRESHOLD
_MSG_WEIGHT = 0.5   # si hay patrón de error

def detect_anomaly(level: str, message: str, latency_ms: int) -> Tuple[bool, float, List[str]]:
    """
    Devuelve (is_anomaly, score, reasons) para un log individual.
    - Usa ANOMALY_THRESHOLD y LATENCY_MS_THRESHOLD de config.py.
    """
    lvl = (level or "INFO").upper()
    score = _LEVEL_WEIGHTS.get(lvl, 0.0)
    reasons: List[str] = []

    # Latencia alta
    try:
        lm = int(latency_ms or 0)
    except Exception:
        lm = 0
    if lm > LATENCY_MS_THRESHOLD:
        score += _LAT_WEIGHT
        reasons.append(f"latency_ms>{LATENCY_MS_THRESHOLD}")

    # Patrones de error en el mensaje
    msg = (message or "").lower()
    if any(re.search(p, msg) for p in _ERR_PATTERNS):
        score += _MSG_WEIGHT
        reasons.append("error_pattern_matched")

    is_anom = score >= ANOMALY_THRESHOLD
    return is_anom, round(score, 3), reasons
