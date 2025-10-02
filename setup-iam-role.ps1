# Script para crear el rol IAM para GitHub Actions EKS Deploy
# Ejecutar este script una sola vez para configurar los permisos

$ErrorActionPreference = "Stop"

$ACCOUNT_ID = "625512666928"
$GITHUB_REPO = "RaulEdenilson/ai-log-analyzer"
$REGION = "us-east-1"

Write-Host "🔐 Creando rol IAM para GitHub Actions EKS Deploy..." -ForegroundColor Green

# Crear trust policy para GitHub Actions
$trustPolicyContent = @"
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::$ACCOUNT_ID`:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:$GITHUB_REPO`:*"
                }
            }
        }
    ]
}
"@

# Guardar trust policy en archivo temporal
$trustPolicyContent | Out-File -FilePath "trust-policy.json" -Encoding UTF8

try {
    # Crear el rol
    Write-Host "Creando rol IAM..." -ForegroundColor Yellow
    aws iam create-role --role-name GitHubActions-EKSDeploy --assume-role-policy-document file://trust-policy.json

    # Adjuntar política personalizada
    Write-Host "Adjuntando política..." -ForegroundColor Yellow
    aws iam put-role-policy --role-name GitHubActions-EKSDeploy --policy-name EKSDeployPolicy --policy-document file://iam-policies/github-actions-eks-deploy-policy.json

    Write-Host "✅ Rol IAM creado: arn:aws:iam::$ACCOUNT_ID`:role/GitHubActions-EKSDeploy" -ForegroundColor Green
}
catch {
    Write-Host "❌ Error creando rol: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    # Limpiar archivos temporales
    if (Test-Path "trust-policy.json") {
        Remove-Item "trust-policy.json"
    }
}

Write-Host ""
Write-Host "📝 Próximos pasos:" -ForegroundColor Cyan
Write-Host "1. Actualiza el nombre del cluster EKS en .github/workflows/ci.yml"
Write-Host "2. Configura las variables de repositorio en GitHub:"
Write-Host "   - AWS_REGION: $REGION"
Write-Host "3. Asegúrate de que el cluster EKS tenga los permisos correctos para el rol"
Write-Host "4. Haz el primer despliegue manual con: kubectl apply -f k8s/"