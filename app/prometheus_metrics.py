from __future__ import annotations
from prometheus_client import Counter, Histogram

# Total de logs ingeridos (incrementa en cada item procesado)
logs_ingested = Counter(
    "app_logs_ingested_total",
    "Total de logs ingeridos",
)

# Total de anomalías detectadas (incrementa cuando detect_anomaly devuelve True)
anomalies_detected = Counter(
    "app_anomalies_detected_total",
    "Total de anomalías detectadas",
)

# Histograma de latencia por log (en milisegundos)
latency_hist = Histogram(
    "app_log_latency_ms",
    "Latencia en ms de logs",
    buckets=(50, 100, 200, 400, 800, 1200, 2000, 5000, 10000)
)
