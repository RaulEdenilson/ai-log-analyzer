# Despliegue en EKS

## Configuración inicial (una sola vez)

### 1. Configurar rol IAM para GitHub Actions

```bash
# Actualizar el nombre del repo en setup-iam-role.sh
chmod +x setup-iam-role.sh
./setup-iam-role.sh
```

### 2. Configurar variables en GitHub

Ve a tu repositorio → Settings → Secrets and variables → Actions → Variables:

- `AWS_REGION`: `us-east-1`

### 3. Actualizar nombre del cluster EKS

Edita `.github/workflows/ci.yml` y `.github/workflows/initial-deploy.yml`:

```yaml
env:
  EKS_CLUSTER_NAME: tu-cluster-name  # Cambia por el nombre real
```

### 4. Configurar permisos en EKS

El rol de GitHub Actions necesita permisos para acceder al cluster:

```bash
# Agregar el rol al configmap aws-auth del cluster
kubectl edit configmap aws-auth -n kube-system
```

Agregar esta sección:

```yaml
  mapRoles: |
    - rolearn: arn:aws:iam::625512666928:role/GitHubActions-EKSDeploy
      username: github-actions
      groups:
        - system:masters
```

### 5. Despliegue inicial

1. Ve a Actions en GitHub
2. Ejecuta manualmente el workflow "initial-deploy-to-eks"
3. Esto creará todos los recursos de Kubernetes por primera vez

## Despliegues automáticos

Una vez configurado, cada push a `main` automáticamente:

1. ✅ Construye la imagen Docker
2. ✅ La sube a ECR con tag del commit
3. ✅ Actualiza el deployment en EKS
4. ✅ Espera que el rollout complete
5. ✅ Verifica el estado

## Comandos útiles

```bash
# Ver estado del despliegue
kubectl get all -n ai-logs

# Ver logs
kubectl logs -f deployment/ai-logs-api -n ai-logs

# Obtener URL del LoadBalancer
kubectl get svc ai-logs-svc -n ai-logs

# Rollback si hay problemas
kubectl rollout undo deployment/ai-logs-api -n ai-logs
```

## Estructura del pipeline

```
Push to main
    ↓
Build & Push Image (ECR)
    ↓
Deploy to EKS (solo en main)
    ↓
Verify Deployment
```

## Troubleshooting

### Error de permisos EKS
- Verificar que el rol esté en aws-auth configmap
- Verificar que el nombre del cluster sea correcto

### Error de imagen
- Verificar que ECR repository existe
- Verificar permisos del rol para ECR

### Error de despliegue
- Verificar logs: `kubectl logs -f deployment/ai-logs-api -n ai-logs`
- Verificar eventos: `kubectl get events -n ai-logs --sort-by='.lastTimestamp'`