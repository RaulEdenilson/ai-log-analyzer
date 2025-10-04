#!/bin/bash

echo "🚀 Desplegando stack completo de monitoreo..."

# Crear namespace si no existe
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Aplicar configuraciones
echo "📊 Aplicando configuración de Prometheus..."
kubectl apply -f monitoring/prometheus-config.yaml
kubectl apply -f monitoring/alerting-rules.yaml
kubectl apply -f monitoring/prometheus-deployment.yaml

echo "📈 Aplicando configuración de Grafana..."
kubectl apply -f monitoring/grafana-config.yaml
kubectl apply -f monitoring/grafana-deployment.yaml

# Esperar a que los pods estén listos
echo "⏳ Esperando a que Prometheus esté listo..."
kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n monitoring

echo "⏳ Esperando a que Grafana esté listo..."
kubectl wait --for=condition=available --timeout=300s deployment/grafana -n monitoring

# Mostrar información de acceso
echo ""
echo "✅ Despliegue completado!"
echo ""
echo "🔍 Acceso a servicios:"
echo "Prometheus: kubectl port-forward svc/prometheus-service 9090:9090 -n monitoring"
echo "Grafana: kubectl port-forward svc/grafana-service 3000:3000 -n monitoring"
echo ""
echo "📊 Credenciales de Grafana:"
echo "Usuario: admin"
echo "Contraseña: admin123"
echo ""
echo "🎯 URLs después del port-forward:"
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000"
echo ""
echo "📈 El dashboard 'AI Log Analyzer - Anomalías' estará disponible automáticamente"