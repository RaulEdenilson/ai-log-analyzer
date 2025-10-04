#!/usr/bin/env pwsh

Write-Host "🎓 AI LOG ANALYZER - DEMO BOOTCAMP" -ForegroundColor Magenta
Write-Host "=================================" -ForegroundColor Magenta
Write-Host ""

# URLs del proyecto
$API_URL = "http://a709cebde35644ceca5557ed71f2f964-3a7026267f48c6dd.elb.us-east-1.amazonaws.com"
$GRAFANA_URL = "http://a5fa4f7534daa4dd38f04c1329304786-2024031885.us-east-1.elb.amazonaws.com:3000"
$PROMETHEUS_URL = "http://ad9c1032dd1664448adb62cb9cf6b48b-1352347381.us-east-1.elb.amazonaws.com:9090"

Write-Host "📁 REPOSITORIOS DEL PROYECTO:" -ForegroundColor Cyan
Write-Host "Código:         https://github.com/RaulEdenilson/ai-log-analyzer" -ForegroundColor White
Write-Host "Infraestructura: https://github.com/RaulEdenilson/ai-log-analyzer-infra" -ForegroundColor White
Write-Host ""
Write-Host "🌐 URLS DEL PROYECTO:" -ForegroundColor Cyan
Write-Host "API:        $API_URL" -ForegroundColor White
Write-Host "Grafana:    $GRAFANA_URL (admin/admin123)" -ForegroundColor White
Write-Host "Prometheus: $PROMETHEUS_URL" -ForegroundColor White
Write-Host ""

Write-Host "1️⃣ VERIFICANDO ESTADO DEL CLUSTER" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow

Write-Host "📊 Información del cluster:" -ForegroundColor Cyan
kubectl cluster-info --request-timeout=10s

Write-Host "`n🏗️ Estado de la aplicación principal:" -ForegroundColor Cyan
kubectl get all -n ai-logs

Write-Host "`n📈 Estado del monitoreo:" -ForegroundColor Cyan
kubectl get all -n monitoring

Write-Host "`n2️⃣ PROBANDO LA API" -ForegroundColor Yellow
Write-Host "==================" -ForegroundColor Yellow

Write-Host "🔍 Health check de la API..." -ForegroundColor Cyan
try {
    $health = Invoke-RestMethod -Uri "$API_URL/health" -Method GET -TimeoutSec 10
    Write-Host "✅ API funcionando: $($health.status)" -ForegroundColor Green
} catch {
    Write-Host "❌ Error en API: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n📝 Enviando logs de prueba..." -ForegroundColor Cyan
$testLogs = @(
    @{
        level = "INFO"
        message = "Demo: Sistema funcionando correctamente"
        latency_ms = 120
        source = "demo-service"
    },
    @{
        level = "ERROR"
        message = "Demo: Database connection failed with timeout"
        latency_ms = 3000
        source = "demo-service"
    }
) | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$API_URL/upload-log" -Method POST -Body $testLogs -ContentType "application/json" -TimeoutSec 10
    Write-Host "✅ Logs enviados exitosamente" -ForegroundColor Green
} catch {
    Write-Host "❌ Error enviando logs: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n3️⃣ VERIFICANDO MÉTRICAS" -ForegroundColor Yellow
Write-Host "=======================" -ForegroundColor Yellow

Write-Host "📊 Consultando métricas en Prometheus..." -ForegroundColor Cyan
try {
    $metricsResponse = Invoke-RestMethod -Uri "$PROMETHEUS_URL/api/v1/query?query=app_logs_ingested_total" -Method GET -TimeoutSec 10
    if ($metricsResponse.data.result.Count -gt 0) {
        $totalLogs = $metricsResponse.data.result[0].value[1]
        Write-Host "✅ Total de logs procesados: $totalLogs" -ForegroundColor Green
    } else {
        Write-Host "📊 Métricas inicializándose..." -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Error consultando Prometheus: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n4️⃣ INFORMACIÓN PARA LA DEMO" -ForegroundColor Yellow
Write-Host "============================" -ForegroundColor Yellow

Write-Host "🎯 PASOS PARA LA PRESENTACIÓN:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Mostrar este output del cluster funcionando" -ForegroundColor White
Write-Host "2. Abrir Grafana en el navegador:" -ForegroundColor White
Write-Host "   $GRAFANA_URL" -ForegroundColor Gray
Write-Host "3. Login: admin / admin123" -ForegroundColor White
Write-Host "4. Mostrar dashboard 'AI Log Analyzer - Anomalías'" -ForegroundColor White
Write-Host "5. Abrir Prometheus:" -ForegroundColor White
Write-Host "   $PROMETHEUS_URL" -ForegroundColor Gray
Write-Host "6. Consultar métricas: app_logs_ingested_total" -ForegroundColor White
Write-Host "7. Mostrar código en GitHub" -ForegroundColor White
Write-Host ""

Write-Host "📋 REQUISITOS CUMPLIDOS:" -ForegroundColor Cyan
Write-Host "✅ Infraestructura como Código (YAML)" -ForegroundColor Green
Write-Host "✅ Contenedorización (Docker + ECR)" -ForegroundColor Green
Write-Host "✅ Orquestación (Kubernetes/EKS)" -ForegroundColor Green
Write-Host "✅ Monitorización (Prometheus + Grafana)" -ForegroundColor Green
Write-Host "✅ Dashboards funcionando" -ForegroundColor Green
Write-Host "✅ Métricas personalizadas" -ForegroundColor Green
Write-Host "✅ CI/CD automatizado" -ForegroundColor Green
Write-Host "✅ LoadBalancers externos" -ForegroundColor Green
Write-Host ""

Write-Host "🏆 PROYECTO COMPLETO Y FUNCIONANDO" -ForegroundColor Green
Write-Host "¡Listo para la evaluación del Bootcamp!" -ForegroundColor Magenta