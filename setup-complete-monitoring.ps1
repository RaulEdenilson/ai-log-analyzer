#!/usr/bin/env pwsh

param(
    [switch]$SkipDeploy,
    [switch]$OnlyTest,
    [string]$ApiUrl = "http://localhost:8000"
)

Write-Host "🎯 Setup completo de monitoreo para AI Log Analyzer" -ForegroundColor Magenta
Write-Host "=================================================" -ForegroundColor Magenta

if (-not $OnlyTest) {
    Write-Host ""
    Write-Host "1️⃣ DESPLEGANDO MONITOREO" -ForegroundColor Yellow
    Write-Host "========================" -ForegroundColor Yellow
    
    if (-not $SkipDeploy) {
        & .\deploy-monitoring.ps1
        
        Write-Host ""
        Write-Host "⏳ Esperando 30 segundos para que los servicios se estabilicen..." -ForegroundColor Yellow
        Start-Sleep -Seconds 30
    } else {
        Write-Host "⏭️ Saltando despliegue (--SkipDeploy especificado)" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "2️⃣ VERIFICANDO SERVICIOS" -ForegroundColor Yellow
Write-Host "========================" -ForegroundColor Yellow

# Verificar pods de monitoreo
Write-Host "📊 Estado de pods de monitoreo:" -ForegroundColor Cyan
kubectl get pods -n monitoring

Write-Host ""
Write-Host "🔍 Estado de servicios:" -ForegroundColor Cyan
kubectl get svc -n monitoring

Write-Host ""
Write-Host "3️⃣ CONFIGURANDO PORT-FORWARDS" -ForegroundColor Yellow
Write-Host "==============================" -ForegroundColor Yellow

# Función para verificar si un puerto está en uso
function Test-Port {
    param([int]$Port)
    try {
        $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $Port)
        $listener.Start()
        $listener.Stop()
        return $false
    } catch {
        return $true
    }
}

# Configurar port-forwards si no están activos
if (-not (Test-Port 3000)) {
    Write-Host "🚀 Iniciando port-forward para Grafana..." -ForegroundColor Green
    Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/grafana-service", "3000:3000", "-n", "monitoring" -WindowStyle Hidden
    Start-Sleep -Seconds 5
} else {
    Write-Host "✅ Grafana ya está disponible en puerto 3000" -ForegroundColor Green
}

if (-not (Test-Port 9090)) {
    Write-Host "🚀 Iniciando port-forward para Prometheus..." -ForegroundColor Green
    Start-Process -FilePath "kubectl" -ArgumentList "port-forward", "svc/prometheus-service", "9090:9090", "-n", "monitoring" -WindowStyle Hidden
    Start-Sleep -Seconds 5
} else {
    Write-Host "✅ Prometheus ya está disponible en puerto 9090" -ForegroundColor Green
}

Write-Host ""
Write-Host "4️⃣ EJECUTANDO PRUEBAS DE ANOMALÍAS" -ForegroundColor Yellow
Write-Host "===================================" -ForegroundColor Yellow

# Verificar si la API está disponible
try {
    $response = Invoke-WebRequest -Uri "$ApiUrl/health" -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ API disponible en $ApiUrl" -ForegroundColor Green
        
        # Ejecutar pruebas
        Write-Host "🧪 Ejecutando pruebas..." -ForegroundColor Cyan
        python test-anomalies.py
        
    } else {
        Write-Host "❌ API no responde correctamente" -ForegroundColor Red
    }
} catch {
    Write-Host "⚠️ API no disponible en $ApiUrl" -ForegroundColor Yellow
    Write-Host "💡 Asegúrate de que tu aplicación esté corriendo" -ForegroundColor Cyan
    Write-Host "   Puedes usar: kubectl port-forward svc/ai-logs-svc 8000:80 -n ai-logs" -ForegroundColor White
}

Write-Host ""
Write-Host "5️⃣ INFORMACIÓN DE ACCESO" -ForegroundColor Yellow
Write-Host "========================" -ForegroundColor Yellow

Write-Host "🌐 URLs disponibles:" -ForegroundColor Cyan
Write-Host "   Grafana:    http://localhost:3000 (admin/admin123)" -ForegroundColor White
Write-Host "   Prometheus: http://localhost:9090" -ForegroundColor White
Write-Host "   API:        $ApiUrl" -ForegroundColor White

Write-Host ""
Write-Host "📊 Dashboards en Grafana:" -ForegroundColor Cyan
Write-Host "   - AI Log Analyzer - Anomalías (automático)" -ForegroundColor White

Write-Host ""
Write-Host "🎯 Comandos útiles:" -ForegroundColor Cyan
Write-Host "   Ver logs API:     kubectl logs -f deployment/ai-logs-api -n ai-logs" -ForegroundColor White
Write-Host "   Ver pods:         kubectl get pods -n ai-logs" -ForegroundColor White
Write-Host "   Port-forward API: kubectl port-forward svc/ai-logs-svc 8000:80 -n ai-logs" -ForegroundColor White

Write-Host ""
Write-Host "✅ Setup completado!" -ForegroundColor Green
Write-Host "🚀 Tu proyecto está listo para la evaluación del Bootcamp" -ForegroundColor Magenta