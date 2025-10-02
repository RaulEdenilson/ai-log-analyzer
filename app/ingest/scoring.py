from __future__ import annotations
import re
from typing import List, Tuple
from app.detector import detect_anomaly  # reutiliza tu detector base

# fallback: si no viene latency_ms explícito, intentamos leer "123ms" del mensaje
_MS_RE = re.compile(r"(\d+)\s*ms", re.IGNORECASE)

def compute_score(level: str | None, message: str, latency_ms: int | None) -> Tuple[bool, float, List[str]]:
    """
    Usa detect_anomaly con latency_ms, y si no viene prueba extraer del texto.
    Devuelve (is_anom, score, reasons).
    """
    lm = int(latency_ms or 0)
    is_anom, score, reasons = detect_anomaly(level or "INFO", message or "", lm)

    if not latency_ms:  # fallback: buscar 'NNNms' en el mensaje
        m = _MS_RE.search(message or "")
        if m:
            try:
                lm2 = int(m.group(1))
                is2, sc2, rs2 = detect_anomaly(level or "INFO", message or "", lm2)
                if sc2 > score:  # nos quedamos con el peor caso
                    is_anom, score, reasons = is2, sc2, list(set(reasons + rs2))
            except Exception:
                pass

    return is_anom, score, reasons
