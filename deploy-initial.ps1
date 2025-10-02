# Script para hacer el despliegue inicial desde máquina local
# Ejecutar una sola vez para configurar todo en EKS

Write-Host "🚀 Desplegando AI Log Analyzer en EKS..." -ForegroundColor Green

# Verificar conexión
Write-Host "🔍 Verificando conexión al cluster..." -ForegroundColor Yellow
kubectl get nodes

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error conectando al cluster. Verifica tu kubeconfig." -ForegroundColor Red
    exit 1
}

# Limpiar despliegue anterior si existe
Write-Host "🧹 Limpiando despliegue anterior..." -ForegroundColor Yellow
kubectl delete namespace ai-logs --ignore-not-found=true
Start-Sleep -Seconds 10

# Desplegar en orden
Write-Host "📦 Desplegando manifiestos..." -ForegroundColor Yellow
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/serviceaccount.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Esperar que esté listo
Write-Host "⏳ Esperando que el despliegue esté listo..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=300s deployment/ai-logs-api -n ai-logs

# Mostrar estado
Write-Host "✅ Despliegue completado!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Estado del despliegue:" -ForegroundColor Cyan
kubectl get all -n ai-logs

Write-Host ""
Write-Host "🌐 Para obtener la URL del LoadBalancer:" -ForegroundColor Cyan
Write-Host "kubectl get svc ai-logs-svc -n ai-logs"

Write-Host ""
Write-Host "📝 Próximos pasos:" -ForegroundColor Cyan
Write-Host "- Los pushes a main actualizarán automáticamente la imagen"
Write-Host "- El pipeline construirá y desplegará nuevas versiones"