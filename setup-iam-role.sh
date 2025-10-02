#!/bin/bash

# Script para crear el rol IAM para GitHub Actions EKS Deploy
# Ejecutar este script una sola vez para configurar los permisos

set -e

ACCOUNT_ID="625512666928"
GITHUB_REPO="tu-usuario/tu-repo"  # Cambia por tu repo
REGION="us-east-1"

echo "🔐 Creando rol IAM para GitHub Actions EKS Deploy..."

# Crear trust policy para GitHub Actions
cat > trust-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:${GITHUB_REPO}:*"
                }
            }
        }
    ]
}
EOF

# Crear el rol
aws iam create-role \
    --role-name GitHubActions-EKSDeploy \
    --assume-role-policy-document file://trust-policy.json

# Adjuntar política personalizada
aws iam put-role-policy \
    --role-name GitHubActions-EKSDeploy \
    --policy-name EKSDeployPolicy \
    --policy-document file://iam-policies/github-actions-eks-deploy-policy.json

echo "✅ Rol IAM creado: arn:aws:iam::${ACCOUNT_ID}:role/GitHubActions-EKSDeploy"

# Limpiar archivos temporales
rm trust-policy.json

echo ""
echo "📝 Próximos pasos:"
echo "1. Actualiza el nombre del cluster EKS en .github/workflows/ci.yml"
echo "2. Configura las variables de repositorio en GitHub:"
echo "   - AWS_REGION: ${REGION}"
echo "3. Asegúrate de que el cluster EKS tenga los permisos correctos para el rol"
echo "4. Haz el primer despliegue manual con: kubectl apply -f k8s/"