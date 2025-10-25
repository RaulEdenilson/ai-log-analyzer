# 🚀 Ejemplos de Peticiones - AI Log Analyzer API

## 🌐 URL Base
```
http://a709cebde35644ceca5557ed71f2f964-3a7026267f48c6dd.elb.us-east-1.amazonaws.com
```

---

## 1️⃣ **Health Check**

### **GET** `/health`
```http
GET /health HTTP/1.1
Host: a709cebde35644ceca5557ed71f2f964-3a7026267f48c6dd.elb.us-east-1.amazonaws.com
```

**Respuesta:**
```json
{
  "status": "ok"
}
```

---

## 2️⃣ **Métricas Prometheus**

### **GET** `/metrics`
```http
GET /metrics HTTP/1.1
Host: a709cebde35644ceca5557ed71f2f964-3a7026267f48c6dd.elb.us-east-1.amazonaws.com
```

**Respuesta:**
```
# HELP app_logs_ingested_total Total de logs ingeridos
# TYPE app_logs_ingested_total counter
app_logs_ingested_total 15.0
# HELP app_anomalies_detected_total Total de anomalías detectadas
# TYPE app_anomalies_detected_total counter
app_anomalies_detected_total 3.0
# HELP http_requests_total Total de requests
# TYPE http_requests_total counter
http_requests_total{method="POST",path="/upload-log",status="200"} 5.0
```

---

## 3️⃣ **Upload Log Simple (Normal)**

### **POST** `/upload-log`
```http
POST /upload-log HTTP/1.1
Host: a709cebde35644ceca5557ed71f2f964-3a7026267f48c6dd.elb.us-east-1.amazonaws.com
Content-Type: application/json

[
  {
    "level": "INFO",
    "message": "Usuario logueado exitosamente",
    "latency_ms": 120,
    "source": "auth-service"
  }
]
```

**Respuesta:**
```json
[
  {
    "id": 1,
    "level": "INFO",
    "message": "Usuario logueado exitosamente",
    "latency_ms": 120,
    "source": "auth-service",
    "is_anomalous": false,
    "anomaly_score": 0.0,
    "anomaly_reasons": [],
    "ts": "2025-10-03T20:30:15.123456"
  }
]
```

---

## 4️⃣ **Upload Log Anómalo (ERROR)**

### **POST** `/upload-log`
```http
POST /upload-log HTTP/1.1
Host: a709cebde35644ceca5557ed71f2f964-3a7026267f48c6dd.elb.us-east-1.amazonaws.com
Content-Type: application/json

[
  {
    "level": "ERROR",
    "message": "Database connection failed with timeout exception",
    "latency_ms": 5000,
    "source": "database-service"
  }
]
```

**Respuesta:**
```json
[
  {
    "id": 2,
    "level": "ERROR",
    "message": "Database connection failed with timeout exception",
    "latency_ms": 5000,
    "source": "database-service",
    "is_anomalous": true,
    "anomaly_score": 1.5,
    "anomaly_reasons": ["latency_ms>500", "error_pattern_matched"],
    "ts": "2025-10-03T20:31:22.456789"
  }
]
```

---

## 5️⃣ **Upload Log Crítico**

### **POST** `/upload-log`
```http
POST /upload-log HTTP/1.1
Host: a709cebde35644ceca5557ed71f2f964-3a7026267f48c6dd.elb.us-east-1.amazonaws.com
Content-Type: application/json

[
  {
    "level": "CRITICAL",
    "message": "System failure - Service unreachable",
    "latency_ms": 8000,
    "source": "critical-service"
  }
]
```

**Respuesta:**
```json
[
  {
    "id": 3,
    "level": "CRITICAL",
    "message": "System failure - Service unreachable",
    "latency_ms": 8000,
    "source": "critical-service",
    "is_anomalous": true,
    "anomaly_score": 1.7,
    "anomaly_reasons": ["latency_ms>500", "error_pattern_matched"],
    "ts": "2025-10-03T20:32:10.789012"
  }
]
```

---

## 6️⃣ **Upload Batch de Logs**

### **POST** `/upload-log`
```http
POST /upload-log HTTP/1.1
Host: a709cebde35644ceca5557ed71f2f964-3a7026267f48c6dd.elb.us-east-1.amazonaws.com
Content-Type: application/json

[
  {
    "level": "INFO",
    "message": "GET /api/users - 200 OK",
    "latency_ms": 89,
    "source": "api-gateway"
  },
  {
    "level": "INFO",
    "message": "POST /api/orders - 201 Created",
    "latency_ms": 156,
    "source": "api-gateway"
  },
  {
    "level": "ERROR",
    "message": "HTTP 500 internal server error - Traceback in payment service",
    "latency_ms": 3500,
    "source": "payment-service"
  },
  {
    "level": "WARN",
    "message": "Connection refused by upstream database",
    "latency_ms": 2000,
    "source": "order-service"
  },
  {
    "level": "DEBUG",
    "message": "Cache miss for product ID 789",
    "latency_ms": 25,
    "source": "product-service"
  }
]
```

**Respuesta:**
```json
[
  {
    "id": 4,
    "level": "INFO",
    "message": "GET /api/users - 200 OK",
    "latency_ms": 89,
    "source": "api-gateway",
    "is_anomalous": false,
    "anomaly_score": 0.0,
    "anomaly_reasons": [],
    "ts": "2025-10-03T20:33:01.111111"
  },
  {
    "id": 5,
    "level": "INFO",
    "message": "POST /api/orders - 201 Created",
    "latency_ms": 156,
    "source": "api-gateway",
    "is_anomalous": false,
    "anomaly_score": 0.0,
    "anomaly_reasons": [],
    "ts": "2025-10-03T20:33:01.222222"
  },
  {
    "id": 6,
    "level": "ERROR",
    "message": "HTTP 500 internal server error - Traceback in payment service",
    "latency_ms": 3500,
    "source": "payment-service",
    "is_anomalous": true,
    "anomaly_score": 1.5,
    "anomaly_reasons": ["latency_ms>500", "error_pattern_matched"],
    "ts": "2025-10-03T20:33:01.333333"
  },
  {
    "id": 7,
    "level": "WARN",
    "message": "Connection refused by upstream database",
    "latency_ms": 2000,
    "source": "order-service",
    "is_anomalous": true,
    "anomaly_score": 0.75,
    "anomaly_reasons": ["latency_ms>500", "error_pattern_matched"],
    "ts": "2025-10-03T20:33:01.444444"
  },
  {
    "id": 8,
    "level": "DEBUG",
    "message": "Cache miss for product ID 789",
    "latency_ms": 25,
    "source": "product-service",
    "is_anomalous": false,
    "anomaly_score": 0.0,
    "anomaly_reasons": [],
    "ts": "2025-10-03T20:33:01.555555"
  }
]
```

---

## 7️⃣ **Consultar Anomalías (Todas)**

### **GET** `/anomalies`
```http
GET /anomalies HTTP/1.1
Host: a709cebde35644ceca5557ed71f2f964-3a7026267f48c6dd.elb.us-east-1.amazonaws.com
```

**Respuesta:**
```json
{
  "anomalies": [
    {
      "id": 1,
      "created_at": "2025-10-03T20:31:22.456789",
      "score": 1.5,
      "reason": "latency_ms>500,error_pattern_matched",
      "log_id": 2,
      "level": "ERROR",
      "message": "Database connection failed with timeout exception",
      "latency_ms": 5000,
      "ts": "2025-10-03T20:31:22.456789"
    },
    {
      "id": 2,
      "created_at": "2025-10-03T20:32:10.789012",
      "score": 1.7,
      "reason": "latency_ms>500,error_pattern_matched",
      "log_id": 3,
      "level": "CRITICAL",
      "message": "System failure - Service unreachable",
      "latency_ms": 8000,
      "ts": "2025-10-03T20:32:10.789012"
    },
    {
      "id": 3,
      "created_at": "2025-10-03T20:33:01.333333",
      "score": 1.5,
      "reason": "latency_ms>500,error_pattern_matched",
      "log_id": 6,
      "level": "ERROR",
      "message": "HTTP 500 internal server error - Traceback in payment service",
      "latency_ms": 3500,
      "ts": "2025-10-03T20:33:01.333333"
    }
  ],
  "count": 3
}
```

---

## 8️⃣ **Consultar Anomalías con Límite**

### **GET** `/anomalies?limit=5`
```http
GET /anomalies?limit=5 HTTP/1.1
Host: a709cebde35644ceca5557ed71f2f964-3a7026267f48c6dd.elb.us-east-1.amazonaws.com
```

**Respuesta:**
```json
{
  "anomalies": [
    {
      "id": 1,
      "created_at": "2025-10-03T20:31:22.456789",
      "score": 1.5,
      "reason": "latency_ms>500,error_pattern_matched",
      "log_id": 2,
      "level": "ERROR",
      "message": "Database connection failed with timeout exception",
      "latency_ms": 5000,
      "ts": "2025-10-03T20:31:22.456789"
    }
  ],
  "count": 1
}
```

---

## 9️⃣ **Ejemplos de Logs Realistas**

### **E-commerce Application**
```json
[
  {
    "level": "INFO",
    "message": "User 12345 added product 789 to cart",
    "latency_ms": 95,
    "source": "cart-service"
  },
  {
    "level": "INFO",
    "message": "Payment processed successfully for order 456",
    "latency_ms": 234,
    "source": "payment-service"
  },
  {
    "level": "ERROR",
    "message": "Payment gateway timeout - transaction failed",
    "latency_ms": 15000,
    "source": "payment-service"
  }
]
```

### **Microservices Monitoring**
```json
[
  {
    "level": "DEBUG",
    "message": "Service mesh routing to user-service v2.1",
    "latency_ms": 12,
    "source": "istio-proxy"
  },
  {
    "level": "WARN",
    "message": "Circuit breaker opened for recommendation-service",
    "latency_ms": 500,
    "source": "hystrix"
  },
  {
    "level": "CRITICAL",
    "message": "Kubernetes pod OOMKilled - memory limit exceeded",
    "latency_ms": 0,
    "source": "k8s-controller"
  }
]
```

### **API Gateway Logs**
```json
[
  {
    "level": "INFO",
    "message": "GET /api/v1/products?category=electronics - 200 OK",
    "latency_ms": 145,
    "source": "api-gateway"
  },
  {
    "level": "WARN",
    "message": "Rate limit exceeded for client IP 192.168.1.100",
    "latency_ms": 1,
    "source": "rate-limiter"
  },
  {
    "level": "ERROR",
    "message": "Upstream service unavailable - HTTP 503 returned",
    "latency_ms": 30000,
    "source": "load-balancer"
  }
]
```

---

## 🎯 **Patrones que Detectan Anomalías**

### **Por Nivel:**
- `ERROR` → Score base: 0.6
- `CRITICAL` → Score base: 0.8
- `WARN` → Score base: 0.35

### **Por Latencia:**
- `> 500ms` → +0.4 al score

### **Por Patrones en Mensaje:**
- `"failed"`, `"failure"` → +0.5
- `"exception"` → +0.5
- `"timeout"` → +0.5
- `"refused"`, `"unreachable"` → +0.5
- `"traceback"` → +0.5
- `"5xx"` (HTTP 5xx) → +0.5

### **Umbral de Anomalía:**
- Score ≥ 0.5 → **ANOMALÍA DETECTADA**

---

## 🚀 **Ejemplos Listos para Copiar/Pegar**

### **Ejemplo 1: Log Normal**
```bash
curl -X POST "http://a709cebde35644ceca5557ed71f2f964-3a7026267f48c6dd.elb.us-east-1.amazonaws.com/upload-log" \
  -H "Content-Type: application/json" \
  -d '[{"level": "INFO", "message": "Request processed successfully", "latency_ms": 120, "source": "web-service"}]'
```

### **Ejemplo 2: Log Anómalo**
```bash
curl -X POST "http://a709cebde35644ceca5557ed71f2f964-3a7026267f48c6dd.elb.us-east-1.amazonaws.com/upload-log" \
  -H "Content-Type: application/json" \
  -d '[{"level": "ERROR", "message": "Database connection failed", "latency_ms": 5000, "source": "db-service"}]'
```

### **Ejemplo 3: Consultar Anomalías**
```bash
curl -X GET "http://a709cebde35644ceca5557ed71f2f964-3a7026267f48c6dd.elb.us-east-1.amazonaws.com/anomalies"
```

---

## 🎤 **Para tu Presentación**

1. **Empieza con Health Check** → Muestra que la API funciona
2. **Envía logs normales** → Demuestra procesamiento básico
3. **Envía logs anómalos** → Muestra detección inteligente
4. **Consulta anomalías** → Demuestra persistencia
5. **Muestra métricas** → Integración con Prometheus

¡Tu API está lista para impresionar! 🏆