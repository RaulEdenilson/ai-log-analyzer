# Script para diagnosticar problemas OIDC con GitHub Actions

Write-Host "Diagnosticando configuracion OIDC..." -ForegroundColor Green

# 1. Verificar proveedor OIDC
Write-Host "1. Verificando proveedor OIDC..." -ForegroundColor Yellow
$oidcProviders = aws iam list-open-id-connect-providers --query 'OpenIDConnectProviderList[?contains(Arn, `token.actions.githubusercontent.com`)].Arn' --output text

if ($oidcProviders) {
    Write-Host "Proveedor OIDC encontrado: $oidcProviders" -ForegroundColor Green
    
    # Obtener detalles del proveedor
    Write-Host "Detalles del proveedor:" -ForegroundColor Cyan
    aws iam get-open-id-connect-provider --open-id-connect-provider-arn $oidcProviders
} else {
    Write-Host "Proveedor OIDC no encontrado" -ForegroundColor Red
    Write-Host "Creando proveedor OIDC..." -ForegroundColor Yellow
    
    aws iam create-open-id-connect-provider --url https://token.actions.githubusercontent.com --client-id-list sts.amazonaws.com --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 1c58a3a8518e8759bf075b76b750d4f2df264fcd
}

# 2. Verificar rol
Write-Host "2. Verificando rol GitHubActions-EKSDeploy..." -ForegroundColor Yellow
aws iam get-role --role-name GitHubActions-EKSDeploy --query 'Role.AssumeRolePolicyDocument'

# 3. Verificar politicas del rol
Write-Host "3. Verificando politicas del rol..." -ForegroundColor Yellow
aws iam list-role-policies --role-name GitHubActions-EKSDeploy

Write-Host "4. Verificando politica EKSDeployPolicy..." -ForegroundColor Yellow
aws iam get-role-policy --role-name GitHubActions-EKSDeploy --policy-name EKSDeployPolicy