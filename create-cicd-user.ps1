# Script para crear usuario IAM específico para CI/CD

Write-Host "🔐 Creando usuario IAM para CI/CD..." -ForegroundColor Green

# 1. Crear usuario
Write-Host "1. Creando usuario github-actions-user..." -ForegroundColor Yellow
aws iam create-user --user-name github-actions-user

# 2. Crear política personalizada para el usuario
$policyDocument = @"
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:PutImage"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "eks:DescribeCluster",
                "eks:ListClusters"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": "arn:aws:iam::625512666928:role/GitHubActions-EKSDeploy"
        }
    ]
}
"@

$policyDocument | Out-File -FilePath "cicd-policy.json" -Encoding UTF8

# 3. Crear política
Write-Host "2. Creando política..." -ForegroundColor Yellow
aws iam create-policy --policy-name GitHubActionsCICDPolicy --policy-document file://cicd-policy.json

# 4. Adjuntar política al usuario
Write-Host "3. Adjuntando política al usuario..." -ForegroundColor Yellow
aws iam attach-user-policy --user-name github-actions-user --policy-arn arn:aws:iam::625512666928:policy/GitHubActionsCICDPolicy

# 5. Crear access keys
Write-Host "4. Creando access keys..." -ForegroundColor Yellow
$keys = aws iam create-access-key --user-name github-actions-user | ConvertFrom-Json

Write-Host "✅ Usuario creado exitosamente!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Configura estos secrets en GitHub:" -ForegroundColor Cyan
Write-Host "AWS_ACCESS_KEY_ID: $($keys.AccessKey.AccessKeyId)"
Write-Host "AWS_SECRET_ACCESS_KEY: $($keys.AccessKey.SecretAccessKey)"

# Limpiar archivo temporal
Remove-Item "cicd-policy.json"

Write-Host ""
Write-Host "🔗 Ve a tu repo → Settings → Secrets and variables → Actions → Secrets"
Write-Host "Agrega los secrets de arriba"