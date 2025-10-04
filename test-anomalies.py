#!/usr/bin/env python3
"""
Script para generar datos de prueba y verificar que las anomalías se detectan correctamente.
"""
import requests
import json
import time
import random
from datetime import datetime

# Configuración
API_URL = "http://a709cebde35644ceca5557ed71f2f964-3a7026267f48c6dd.elb.us-east-1.amazonaws.com"  # URL real de tu API
PROMETHEUS_URL = "http://ad9c1032dd1664448adb62cb9cf6b48b-1352347381.us-east-1.elb.amazonaws.com:9090"  # URL de Prometheus

def generate_normal_logs(count=10):
    """Genera logs normales"""
    logs = []
    for i in range(count):
        logs.append({
            "level": random.choice(["INFO", "DEBUG"]),
            "message": f"Processing request {i+1}",
            "latency_ms": random.randint(50, 200),
            "source": f"service-{random.randint(1, 3)}"
        })
    return logs

def generate_anomalous_logs(count=5):
    """Genera logs con anomalías"""
    logs = []
    anomaly_patterns = [
        {"level": "ERROR", "message": "Database connection failed", "latency_ms": 5000},
        {"level": "CRITICAL", "message": "Service timeout exception", "latency_ms": 8000},
        {"level": "ERROR", "message": "HTTP 500 internal server error", "latency_ms": 3000},
        {"level": "WARN", "message": "Connection refused by upstream", "latency_ms": 2000},
        {"level": "ERROR", "message": "Traceback: NullPointerException", "latency_ms": 1500},
    ]
    
    for i in range(count):
        pattern = random.choice(anomaly_patterns)
        logs.append({
            "level": pattern["level"],
            "message": pattern["message"],
            "latency_ms": pattern["latency_ms"],
            "source": f"service-{random.randint(1, 3)}"
        })
    return logs

def send_logs(logs):
    """Envía logs a la API"""
    try:
        response = requests.post(f"{API_URL}/upload-log", json=logs)
        if response.status_code == 200:
            data = response.json()
            anomalies = [log for log in data if log.get("is_anomalous", False)]
            print(f"✅ Enviados {len(logs)} logs, {len(anomalies)} anomalías detectadas")
            return len(anomalies)
        else:
            print(f"❌ Error enviando logs: {response.status_code}")
            return 0
    except Exception as e:
        print(f"❌ Error conectando a la API: {e}")
        return 0

def check_metrics():
    """Verifica las métricas en Prometheus"""
    try:
        # Consultar total de anomalías
        response = requests.get(f"{PROMETHEUS_URL}/api/v1/query", 
                              params={"query": "app_anomalies_detected_total"})
        if response.status_code == 200:
            data = response.json()
            if data["data"]["result"]:
                total_anomalies = float(data["data"]["result"][0]["value"][1])
                print(f"📊 Total de anomalías en Prometheus: {total_anomalies}")
            else:
                print("📊 No hay métricas de anomalías aún")
        
        # Consultar total de logs
        response = requests.get(f"{PROMETHEUS_URL}/api/v1/query", 
                              params={"query": "app_logs_ingested_total"})
        if response.status_code == 200:
            data = response.json()
            if data["data"]["result"]:
                total_logs = float(data["data"]["result"][0]["value"][1])
                print(f"📊 Total de logs en Prometheus: {total_logs}")
            else:
                print("📊 No hay métricas de logs aún")
                
    except Exception as e:
        print(f"❌ Error consultando Prometheus: {e}")

def main():
    print("🧪 Iniciando prueba de detección de anomalías...")
    print(f"🎯 API URL: {API_URL}")
    print(f"📊 Prometheus URL: {PROMETHEUS_URL}")
    print()
    
    total_anomalies = 0
    
    # Enviar logs normales
    print("1️⃣ Enviando logs normales...")
    normal_logs = generate_normal_logs(20)
    total_anomalies += send_logs(normal_logs)
    time.sleep(2)
    
    # Enviar logs con anomalías
    print("\n2️⃣ Enviando logs con anomalías...")
    anomalous_logs = generate_anomalous_logs(10)
    total_anomalies += send_logs(anomalous_logs)
    time.sleep(2)
    
    # Mezclar logs normales y anómalos
    print("\n3️⃣ Enviando mezcla de logs...")
    mixed_logs = generate_normal_logs(15) + generate_anomalous_logs(5)
    random.shuffle(mixed_logs)
    total_anomalies += send_logs(mixed_logs)
    time.sleep(2)
    
    print(f"\n🎯 Total de anomalías detectadas: {total_anomalies}")
    
    # Verificar métricas en Prometheus
    print("\n📊 Verificando métricas en Prometheus...")
    check_metrics()
    
    print("\n✅ Prueba completada!")
    print("\n🔍 Para ver los resultados:")
    print("- Grafana: http://localhost:3000 (admin/admin123)")
    print("- Prometheus: http://localhost:9090")
    print("- API anomalías: http://localhost:8000/anomalies")

if __name__ == "__main__":
    main()