# 📮 Guía de Demo con Postman - AI Log Analyzer

## 🌐 URL Base de la API
```
http://a709cebde35644ceca5557ed71f2f964-3a7026267f48c6dd.elb.us-east-1.amazonaws.com
```

---

## 🚀 Secuencia de Demo Recomendada

### 1️⃣ **Health Check** - Verificar que la API funciona
**Método:** `GET`  
**URL:** `{{base_url}}/health`  
**Respuesta esperada:**
```json
{
  "status": "ok"
}
```

---

### 2️⃣ **Métricas Prometheus** - Mostrar integración con monitoreo
**Método:** `GET`  
**URL:** `{{base_url}}/metrics`  
**Respuesta esperada:** Métricas en formato Prometheus
```
# HELP app_logs_ingested_total Total de logs ingeridos
# TYPE app_logs_ingested_total counter
app_logs_ingested_total 42.0
...
```

---

### 3️⃣ **Log Normal** - Demostrar ingesta básica
**Método:** `POST`  
**URL:** `{{base_url}}/upload-log`  
**Headers:** `Content-Type: application/json`  
**Body:**
```json
[
  {
    "level": "INFO",
    "message": "Usuario logueado exitosamente",
    "latency_ms": 120,
    "source": "auth-service"
  }
]
```
**Respuesta esperada:**
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
    "ts": "2025-10-03T..."
  }
]
```

---

### 4️⃣ **Log Anómalo** - Demostrar detección de anomalías
**Método:** `POST`  
**URL:** `{{base_url}}/upload-log`  
**Headers:** `Content-Type: application/json`  
**Body:**
```json
[
  {
    "level": "ERROR",
    "message": "Database connection failed with timeout exception",
    "latency_ms": 5000,
    "source": "database-service"
  }
]
```
**Respuesta esperada:**
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
    "ts": "2025-10-03T..."
  }
]
```

---

### 5️⃣ **Batch de Logs** - Demostrar procesamiento masivo
**Método:** `POST`  
**URL:** `{{base_url}}/upload-log`  
**Headers:** `Content-Type: application/json`  
**Body:**
```json
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

---

### 6️⃣ **Consultar Anomalías** - Mostrar persistencia y consulta
**Método:** `GET`  
**URL:** `{{base_url}}/anomalies`  
**Respuesta esperada:**
```json
{
  "anomalies": [
    {
      "id": 1,
      "created_at": "2025-10-03T...",
      "score": 1.5,
      "reason": "latency_ms>500,error_pattern_matched",
      "log_id": 2,
      "level": "ERROR",
      "message": "Database connection failed with timeout exception",
      "latency_ms": 5000,
      "ts": "2025-10-03T..."
    }
  ],
  "count": 1
}
```

---

### 7️⃣ **Log Crítico** - Demostrar detección de nivel crítico
**Método:** `POST`  
**URL:** `{{base_url}}/upload-log`  
**Headers:** `Content-Type: application/json`  
**Body:**
```json
[
  {
    "level": "CRITICAL",
    "message": "System failure - Service unreachable",
    "latency_ms": 8000,
    "source": "critical-service"
  }
]
```

---

## 🎯 **Puntos Clave para Destacar en la Demo**

### **1. Ingesta Flexible**
- ✅ Acepta logs individuales o en batch
- ✅ Formato JSON estándar
- ✅ Validación automática de datos

### **2. Detección Inteligente**
- ✅ Análisis por nivel (ERROR, CRITICAL, WARN)
- ✅ Detección por latencia alta
- ✅ Patrones de error en mensajes
- ✅ Sistema de scoring configurable

### **3. Persistencia y Consulta**
- ✅ Almacenamiento en base de datos
- ✅ API para consultar anomalías
- ✅ Filtros por cantidad (limit)
- ✅ Información completa del contexto

### **4. Integración con Monitoreo**
- ✅ Métricas para Prometheus
- ✅ Contadores de logs procesados
- ✅ Contadores de anomalías detectadas
- ✅ Métricas HTTP estándar

---

## 📊 **Flujo de Demo Recomendado**

1. **Mostrar Health Check** → API funcionando
2. **Enviar logs normales** → Procesamiento básico
3. **Enviar logs anómalos** → Detección funcionando
4. **Consultar anomalías** → Persistencia y consulta
5. **Mostrar métricas** → Integración con Prometheus
6. **Abrir Grafana** → Visualización en tiempo real

---

## 🔧 **Configuración en Postman**

### **Importar Colección**
1. Abrir Postman
2. File → Import
3. Seleccionar `AI-Log-Analyzer-Postman-Collection.json`
4. La colección aparecerá con todos los endpoints configurados

### **Variable de Entorno**
La colección usa la variable `{{base_url}}` que ya está configurada con:
```
http://a709cebde35644ceca5557ed71f2f964-3a7026267f48c6dd.elb.us-east-1.amazonaws.com
```

### **Orden de Ejecución**
Ejecuta los requests en orden numérico para una demo fluida:
1. Health Check
2. Métricas Prometheus  
3. Upload Log Simple
4. Upload Log Batch
5. Upload Log Anomalía
6. Consultar Anomalías

---

## 🎤 **Script para la Presentación**

> "Ahora voy a demostrar la funcionalidad de la API usando Postman. Primero verifico que esté funcionando con el health check..."

> "Como pueden ver, la API responde correctamente. Ahora voy a enviar algunos logs normales para mostrar el procesamiento básico..."

> "Perfecto, los logs se procesan y almacenan. Ahora voy a enviar un log que debería ser detectado como anomalía - un ERROR con alta latencia y patrón de fallo..."

> "¡Excelente! Como pueden ver, el sistema detectó la anomalía automáticamente, le asignó un score de 1.5 y identificó las razones: alta latencia y patrón de error."

> "Finalmente, puedo consultar todas las anomalías detectadas a través de la API, mostrando que el sistema mantiene un historial completo..."

---

## 🏆 **¡Tu API está lista para impresionar!**