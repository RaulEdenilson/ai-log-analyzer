# 🎓 AI Log Analyzer - Presentación Final Bootcamp

## 👨‍💻 Información del Proyecto
- **Estudiante**: Raúl Edenilson
- **Proyecto**: AI Log Analyzer - Sistema de Análisis de Logs con Detección de Anomalías
- **Fecha**: Octubre 2025
- **Repositorios**:
  - **Código**: https://github.com/RaulEdenilson/ai-log-analyzer
  - **Infraestructura**: https://github.com/RaulEdenilson/ai-log-analyzer-infra

---

## 🎯 Resumen Ejecutivo

He desarrollado un **sistema completo de análisis de logs cloud-native** que simula una solución empresarial real para detectar anomalías en aplicaciones distribuidas. El proyecto demuestra dominio completo del stack DevOps moderno.

### 🏗️ Arquitectura del Sistema
```
Internet → AWS LoadBalancer → EKS Cluster → Pods
                                ↓
                          Prometheus ← API Metrics
                                ↓
                            Grafana Dashboards
```

---

## ✅ Cumplimiento de Requisitos Técnicos

### 1. 🏗️ **Infraestructura como Código**
- **✅ CUMPLIDO**: Separación profesional de infraestructura y código
- **Repositorio de Infraestructura**: https://github.com/RaulEdenilson/ai-log-analyzer-infra
- **Repositorio de Aplicación**: https://github.com/RaulEdenilson/ai-log-analyzer
- **Archivos**: `k8s/*.yaml`, `monitoring/*.yaml`, Terraform/CloudFormation
- **Componentes**: Deployments, Services, ConfigMaps, Namespaces

### 2. 🐳 **Contenedorización**
- **✅ CUMPLIDO**: Docker + Amazon ECR
- **Imagen**: `625512666928.dkr.ecr.us-east-1.amazonaws.com/ai-log-analyzer`
- **Características**: Multi-stage build, optimizada para producción

### 3. ☸️ **Orquestación con Kubernetes**
- **✅ CUMPLIDO**: Deployment completo en Amazon EKS
- **Componentes**: Pods, Services, ConfigMaps, Namespaces
- **Alta Disponibilidad**: 2 réplicas con LoadBalancer

### 4. 📊 **Monitorización**
- **✅ CUMPLIDO**: Prometheus + Grafana integrados
- **Métricas**: CPU, memoria, requests HTTP, anomalías detectadas
- **Dashboards**: Visualización en tiempo real

---

## 🌐 URLs de Demostración

### 🔗 Servicios Desplegados (Acceso Directo)
- **API Principal**: http://a709cebde35644ceca5557ed71f2f964-3a7026267f48c6dd.elb.us-east-1.amazonaws.com
- **Grafana**: http://a5fa4f7534daa4dd38f04c1329304786-2024031885.us-east-1.elb.amazonaws.com:3000
- **Prometheus**: http://ad9c1032dd1664448adb62cb9cf6b48b-1352347381.us-east-1.elb.amazonaws.com:9090

### 🔐 Credenciales
- **Grafana**: admin / admin123

---

## 🚀 Demostración en Vivo

### 1. **Estado del Cluster**
```bash
kubectl get all -n ai-logs
kubectl get all -n monitoring
```

### 2. **API Funcionando**
```bash
curl http://a709cebde35644ceca5557ed71f2f964-3a7026267f48c6dd.elb.us-east-1.amazonaws.com/health
```

### 3. **Envío de Logs**
```bash
curl -X POST "http://[API-URL]/upload-log" \
  -H "Content-Type: application/json" \
  -d '[{"level": "INFO", "message": "Sistema funcionando", "latency_ms": 100}]'
```

### 4. **Métricas en Prometheus**
- Navegar a Prometheus UI
- Consultar: `app_logs_ingested_total`
- Consultar: `http_requests_total`

### 5. **Dashboards en Grafana**
- Login en Grafana
- Dashboard: "AI Log Analyzer - Anomalías"
- Métricas en tiempo real

---

## 🛠️ Stack Tecnológico Implementado

### **Arquitectura de Repositorios (Mejores Prácticas)**
- **🏗️ Infraestructura**: https://github.com/RaulEdenilson/ai-log-analyzer-infra
  - Terraform/CloudFormation para recursos AWS
  - Configuración de EKS, VPC, IAM
  - Separación clara de responsabilidades
- **💻 Aplicación**: https://github.com/RaulEdenilson/ai-log-analyzer
  - Código de la aplicación FastAPI
  - Manifiestos de Kubernetes
  - Configuración de monitoreo

### **Backend**
- **FastAPI**: Framework moderno y rápido
- **SQLite**: Base de datos para persistencia
- **Pydantic**: Validación de datos
- **Prometheus Client**: Métricas personalizadas

### **Infraestructura**
- **Amazon EKS**: Kubernetes gestionado
- **Amazon ECR**: Registry de contenedores
- **AWS LoadBalancer**: Balanceador de carga
- **GitHub Actions**: CI/CD automatizado

### **Monitoreo**
- **Prometheus**: Recolección de métricas
- **Grafana**: Visualización y dashboards
- **Alerting**: Reglas de alertas configuradas

---

## 🔄 Pipeline CI/CD

### **Flujo Automatizado**
1. **Push a main** → Trigger automático
2. **Build & Test** → Construcción de imagen Docker
3. **Push to ECR** → Subida a registry
4. **Deploy to EKS** → Actualización automática
5. **Health Check** → Verificación de despliegue

### **Archivos Clave**
- `.github/workflows/ci.yml`: Pipeline principal
- `Dockerfile`: Configuración de contenedor
- `k8s/`: Manifiestos de Kubernetes

---

## 📈 Funcionalidades Implementadas

### **API REST Completa**
- `POST /upload-log`: Ingesta de logs (JSON/archivo)
- `GET /anomalies`: Consulta de anomalías detectadas
- `GET /metrics`: Métricas para Prometheus
- `GET /health`: Health check

### **Detección de Anomalías**
- **Análisis de nivel**: ERROR, CRITICAL, WARN
- **Análisis de latencia**: Umbrales configurables
- **Análisis de patrones**: Detección de errores en mensajes
- **Scoring inteligente**: Sistema de puntuación

### **Métricas Personalizadas**
- `app_logs_ingested_total`: Total de logs procesados
- `app_anomalies_detected_total`: Anomalías detectadas
- `app_log_latency_ms`: Histograma de latencias
- `http_requests_total`: Métricas HTTP estándar

---

## 🎯 Casos de Uso Demostrados

### **1. Ingesta Masiva de Logs**
```json
[
  {"level": "INFO", "message": "Request processed", "latency_ms": 150},
  {"level": "ERROR", "message": "Database timeout", "latency_ms": 5000}
]
```

### **2. Detección Automática**
- Logs normales: INFO/DEBUG con latencia baja
- Anomalías: ERROR/CRITICAL con patrones de fallo

### **3. Monitoreo en Tiempo Real**
- Dashboards actualizados cada 5 segundos
- Alertas automáticas por umbrales
- Métricas históricas y tendencias

---

## 🏆 Valor Empresarial

### **Problema Resuelto**
- **Monitoreo proactivo** de aplicaciones distribuidas
- **Detección temprana** de problemas en producción
- **Visibilidad completa** del estado del sistema

### **Beneficios**
- ⚡ **Respuesta rápida** a incidentes
- 📊 **Métricas centralizadas** para toma de decisiones
- 🔍 **Análisis histórico** de patrones
- 🚨 **Alertas automáticas** para el equipo

---

## 🔧 Comandos de Demostración

### **Verificar Estado**
```bash
# Estado general
kubectl cluster-info
kubectl get nodes

# Aplicación
kubectl get all -n ai-logs
kubectl logs -f deployment/ai-logs-api -n ai-logs

# Monitoreo
kubectl get all -n monitoring
```

### **Generar Datos de Prueba**
```bash
# Ejecutar script de pruebas
python test-anomalies.py

# O usar PowerShell
.\test-simple.ps1
```

### **Acceso a Servicios**
```bash
# Si necesitas port-forward local
kubectl port-forward svc/grafana-service 3000:3000 -n monitoring
kubectl port-forward svc/prometheus-service 9090:9090 -n monitoring
```

---

## 📋 Checklist de Evaluación

### ✅ **Requisitos Obligatorios**
- [x] Infraestructura como Código
- [x] Contenedorización con Docker
- [x] Orquestación con Kubernetes
- [x] Monitorización con Prometheus y Grafana
- [x] Dashboards básicos funcionando
- [x] Métricas de CPU, memoria, requests

### ✅ **Bonus Implementados**
- [x] Alertas configuradas
- [x] Consultas personalizadas
- [x] CI/CD completo
- [x] LoadBalancers externos
- [x] Alta disponibilidad (2 réplicas)
- [x] Health checks y readiness probes

---

## 🎤 Puntos Clave para la Presentación

### **1. Demostrar Funcionamiento**
- Mostrar servicios corriendo en EKS
- Acceder a Grafana y mostrar dashboards
- Enviar logs y ver métricas en tiempo real

### **2. Explicar Arquitectura**
- Dibujar/mostrar diagrama de componentes
- Explicar flujo de datos
- Destacar decisiones técnicas

### **3. Mostrar Código**
- API REST bien estructurada
- Configuración de Kubernetes profesional
- Pipeline CI/CD automatizado

### **4. Destacar Valor**
- Solución empresarial real
- Escalable y mantenible
- Siguiendo mejores prácticas

---

## 🚀 **¡Proyecto Listo para Evaluación!**

Este proyecto demuestra **dominio completo** de:
- ☸️ Kubernetes y orquestación
- 🐳 Contenedorización y Docker
- 📊 Monitoreo y observabilidad
- 🔄 CI/CD y automatización
- ☁️ Arquitectura cloud-native
- 🛠️ Desarrollo de APIs modernas

**¡Éxito en tu evaluación!** 🎓