#!/bin/bash

set -e

echo "🚀 Desplegando AI Log Analyzer en EKS..."

# Variables
ECR_REGISTRY="625512666928.dkr.ecr.us-east-1.amazonaws.com"
IMAGE_NAME="ai-log-analyzer"
REGION="us-east-1"

echo "📦 Autenticando con ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

echo "🔨 Construyendo imagen Docker..."
docker build -t $IMAGE_NAME .

echo "🏷️ Etiquetando imagen para ECR..."
docker tag $IMAGE_NAME:latest $ECR_REGISTRY/$IMAGE_NAME:latest

echo "⬆️ Subiendo imagen a ECR..."
docker push $ECR_REGISTRY/$IMAGE_NAME:latest

echo "☸️ Desplegando en Kubernetes..."
kubectl apply -f k8s/

echo "⏳ Esperando que el despliegue esté listo..."
kubectl wait --for=condition=available --timeout=300s deployment/ai-logs-api -n ai-logs

echo "✅ Despliegue completado!"
echo ""
echo "📊 Estado del despliegue:"
kubectl get all -n ai-logs

echo ""
echo "🌐 Para obtener la URL del LoadBalancer:"
echo "kubectl get svc ai-logs-svc -n ai-logs"

echo ""
echo "📝 Para ver logs:"
echo "kubectl logs -f deployment/ai-logs-api -n ai-logs"