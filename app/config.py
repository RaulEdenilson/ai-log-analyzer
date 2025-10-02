import os

# Umbral global de score para considerar un log como anomalía (0.0–1.0)
ANOMALY_THRESHOLD: float = float(os.getenv("ANOMALY_THRESHOLD", 0.7))

# Umbral de latencia en milisegundos para sumar peso al score
LATENCY_MS_THRESHOLD: int = int(os.getenv("LATENCY_MS_THRESHOLD", 800))

# Ruta de la base de datos SQLite
SQLITE_URL: str = os.getenv("SQLITE_URL", "sqlite:///./data.db")

# (Opcional) parámetros para IsolationForest si lo usas en anomaly.py
ISOF_N_ESTIMATORS: int = int(os.getenv("ISOF_N_ESTIMATORS", 100))
ISOF_CONTAMINATION: float = float(os.getenv("ISOF_CONTAMINATION", 0.1))
ISOF_RANDOM_STATE: int = int(os.getenv("ISOF_RANDOM_STATE", 42))
