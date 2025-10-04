#!/usr/bin/env pwsh

Write-Host "🚀 Desplegando stack completo de monitoreo..." -ForegroundColor Green

# Crear namespace si no existe
Write-Host "📦 Creando namespace monitoring..." -ForegroundColor Yellow
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Aplicar configuraciones
Write-Host "📊 Aplicando configuración de Prometheus..." -ForegroundColor Yellow
kubectl apply -f monitoring/prometheus-config.yaml
kubectl apply -f monitoring/alerting-rules.yaml
kubectl apply -f monitoring/prometheus-deployment.yaml

Write-Host "📈 Aplicando configuración de Grafana..." -ForegroundColor Yellow
kubectl apply -f monitoring/grafana-config.yaml
kubectl apply -f monitoring/grafana-deployment.yaml

# Esperar a que los pods estén listos
Write-Host "⏳ Esperando a que Prometheus esté listo..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n monitoring

Write-Host "⏳ Esperando a que Grafana esté listo..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=300s deployment/grafana -n monitoring

# Mostrar información de acceso
Write-Host ""
Write-Host "✅ Despliegue completado!" -ForegroundColor Green
Write-Host ""
Write-Host "🔍 Acceso a servicios:" -ForegroundColor Cyan
Write-Host "Prometheus: kubectl port-forward svc/prometheus-service 9090:9090 -n monitoring" -ForegroundColor White
Write-Host "Grafana: kubectl port-forward svc/grafana-service 3000:3000 -n monitoring" -ForegroundColor White
Write-Host ""
Write-Host "📊 Credenciales de Grafana:" -ForegroundColor Cyan
Write-Host "Usuario: admin" -ForegroundColor White
Write-Host "Contraseña: admin123" -ForegroundColor White
Write-Host ""
Write-Host "🎯 URLs después del port-forward:" -ForegroundColor Cyan
Write-Host "Prometheus: http://localhost:9090" -ForegroundColor White
Write-Host "Grafana: http://localhost:3000" -ForegroundColor White
Write-Host ""
Write-Host "📈 El dashboard 'AI Log Analyzer - Anomalías' estará disponible automáticamente" -ForegroundColor Green