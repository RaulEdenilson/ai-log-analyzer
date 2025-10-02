#!/bin/bash

set -e

echo "📝 Preparando commit con configuración de despliegue EKS..."

# Agregar todos los archivos
git add .

# Hacer commit
git commit -m "feat: configurar pipeline CI/CD para despliegue automático en EKS

- Actualizar workflow para incluir despliegue a EKS
- Agregar workflow de despliegue inicial
- Configurar manifiestos K8s optimizados para EKS
- Agregar scripts de configuración IAM
- Documentar proceso de despliegue

Cambios:
- Pipeline automático: build → push ECR → deploy EKS
- LoadBalancer con NLB para mejor rendimiento
- Recursos y límites configurados
- Health checks optimizados
- Rollout automático con verificación"

echo "🚀 Haciendo push al repositorio..."
git push origin main

echo ""
echo "✅ Cambios subidos al repositorio!"
echo ""
echo "📋 Próximos pasos:"
echo "1. Ejecutar setup-iam-role.sh para configurar permisos"
echo "2. Configurar variables AWS_REGION en GitHub"
echo "3. Actualizar nombre del cluster EKS en los workflows"
echo "4. Ejecutar workflow 'initial-deploy-to-eks' manualmente"
echo "5. Los siguientes pushes se desplegarán automáticamente"