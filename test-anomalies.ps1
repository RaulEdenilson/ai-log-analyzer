#!/usr/bin/env pwsh

Write-Host "🧪 Iniciando prueba de detección de anomalías..." -ForegroundColor Green

# Verificar si Python está disponible
try {
    $pythonVersion = python --version 2>&1
    Write-Host "🐍 Python detectado: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Python no encontrado. Por favor instala Python 3.x" -ForegroundColor Red
    exit 1
}

# Verificar si requests está instalado
try {
    python -c "import requests" 2>$null
    Write-Host "✅ Módulo requests disponible" -ForegroundColor Green
} catch {
    Write-Host "📦 Instalando módulo requests..." -ForegroundColor Yellow
    pip install requests
}

# Ejecutar el script de prueba
Write-Host "🚀 Ejecutando pruebas de anomalías..." -ForegroundColor Cyan
python test-anomalies.py

Write-Host ""
Write-Host "✅ Pruebas completadas!" -ForegroundColor Green
Write-Host ""
Write-Host "🔍 Para ver los resultados en tiempo real:" -ForegroundColor Cyan
Write-Host "1. Abrir nueva terminal y ejecutar: kubectl port-forward svc/grafana-service 3000:3000 -n monitoring" -ForegroundColor White
Write-Host "2. Abrir otra terminal y ejecutar: kubectl port-forward svc/prometheus-service 9090:9090 -n monitoring" -ForegroundColor White
Write-Host "3. Ir a http://localhost:3000 (admin/admin123)" -ForegroundColor White
Write-Host "4. El dashboard estará disponible automáticamente" -ForegroundColor White