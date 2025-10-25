from __future__ import annotations
from typing import List

from fastapi import UploadFile
from sqlalchemy.orm import Session

from app import schemas
from app.prometheus_metrics import logs_ingested, anomalies_detected, latency_hist

from .parsers import from_json_payload, from_jsonl_file, from_plain_file
from .scoring import compute_score
from .persistence import persist_log_and_anomalies


class IngestService:
    """
    Orquesta: parseo -> scoring -> persistencia -> métricas -> respuesta.
    No expone detalles de DB ni de formatos de entrada.
    """

    def __init__(self, db: Session):
        self.db = db

    # -------- JSON (payload directo del endpoint) --------
    def process_payload(self, payload: dict | list) -> List[schemas.LogOut]:
        items = from_json_payload(payload)
        return self._process_items(items)

    # -------- Archivos (.jsonl / .log) --------
    async def process_file(self, file: UploadFile) -> List[schemas.LogOut]:
        name = (file.filename or "").lower()
        if name.endswith(".jsonl"):
            items = from_jsonl_file(file)
        else:
            items = from_plain_file(file)
        return self._process_items(items)

    # ---------------- CORE ----------------
    def _process_items(self, items: List[schemas.LogIn]) -> List[schemas.LogOut]:
        out: List[schemas.LogOut] = []

        for it in items:
            # métricas base
            lm = int(it.latency_ms or 0)
            latency_hist.observe(float(lm))
            logs_ingested.inc()

            # score + razones (usa tu detector internamente)
            is_anom, score, reasons = compute_score(it.level, it.message, lm)

            # persistencia
            row = persist_log_and_anomalies(self.db, it, is_anom, score, reasons)
            if is_anom:
                anomalies_detected.inc()

            # respuesta
            out.append(
                schemas.LogOut(
                    id=row.id,
                    ts=row.ts,
                    level=row.level,
                    message=row.message,
                    latency_ms=row.latency_ms,
                    source=row.source,
                    is_anomalous=row.is_anomaly,
                    anomaly_score=row.score,
                    anomaly_reasons=reasons,
                )
            )

        # commit del batch completo
        self.db.commit()
        return out
