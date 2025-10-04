#!/usr/bin/env pwsh

Write-Host "🔍 VERIFICACIÓN PRE-PRESENTACIÓN" -ForegroundColor Magenta
Write-Host "===============================" -ForegroundColor Magenta
Write-Host ""

$allGood = $true

# URLs del proyecto
$API_URL = "http://a709cebde35644ceca5557ed71f2f964-3a7026267f48c6dd.elb.us-east-1.amazonaws.com"
$GRAFANA_URL = "http://a5fa4f7534daa4dd38f04c1329304786-2024031885.us-east-1.elb.amazonaws.com:3000"
$PROMETHEUS_URL = "http://ad9c1032dd1664448adb62cb9cf6b48b-1352347381.us-east-1.elb.amazonaws.com:9090"

Write-Host "1️⃣ VERIFICANDO CONECTIVIDAD A KUBERNETES" -ForegroundColor Yellow
try {
    $clusterInfo = kubectl cluster-info --request-timeout=5s 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Kubernetes cluster accesible" -ForegroundColor Green
    } else {
        Write-Host "❌ No se puede conectar al cluster" -ForegroundColor Red
        $allGood = $false
    }
} catch {
    Write-Host "❌ Error conectando a Kubernetes" -ForegroundColor Red
    $allGood = $false
}

Write-Host "`n2️⃣ VERIFICANDO PODS DE LA APLICACIÓN" -ForegroundColor Yellow
try {
    $appPods = kubectl get pods -n ai-logs --no-headers 2>$null
    if ($appPods -and $appPods.Contains("Running")) {
        Write-Host "✅ Pods de aplicación corriendo" -ForegroundColor Green
    } else {
        Write-Host "❌ Pods de aplicación no están corriendo" -ForegroundColor Red
        $allGood = $false
    }
} catch {
    Write-Host "❌ Error verificando pods de aplicación" -ForegroundColor Red
    $allGood = $false
}

Write-Host "`n3️⃣ VERIFICANDO PODS DE MONITOREO" -ForegroundColor Yellow
try {
    $monitoringPods = kubectl get pods -n monitoring --no-headers 2>$null
    if ($monitoringPods -and $monitoringPods.Contains("Running")) {
        Write-Host "✅ Pods de monitoreo corriendo" -ForegroundColor Green
    } else {
        Write-Host "❌ Pods de monitoreo no están corriendo" -ForegroundColor Red
        $allGood = $false
    }
} catch {
    Write-Host "❌ Error verificando pods de monitoreo" -ForegroundColor Red
    $allGood = $false
}

Write-Host "`n4️⃣ VERIFICANDO API PRINCIPAL" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$API_URL/health" -Method GET -TimeoutSec 5
    if ($response.status -eq "ok") {
        Write-Host "✅ API principal respondiendo correctamente" -ForegroundColor Green
    } else {
        Write-Host "❌ API principal no responde correctamente" -ForegroundColor Red
        $allGood = $false
    }
} catch {
    Write-Host "❌ API principal no accesible" -ForegroundColor Red
    $allGood = $false
}

Write-Host "`n5️⃣ VERIFICANDO GRAFANA" -ForegroundColor Yellow
try {
    $grafanaResponse = Invoke-WebRequest -Uri $GRAFANA_URL -Method GET -TimeoutSec 5 -UseBasicParsing
    if ($grafanaResponse.StatusCode -eq 200) {
        Write-Host "✅ Grafana accesible" -ForegroundColor Green
    } else {
        Write-Host "❌ Grafana no accesible" -ForegroundColor Red
        $allGood = $false
    }
} catch {
    Write-Host "❌ Error accediendo a Grafana" -ForegroundColor Red
    $allGood = $false
}

Write-Host "`n6️⃣ VERIFICANDO PROMETHEUS" -ForegroundColor Yellow
try {
    $prometheusResponse = Invoke-WebRequest -Uri $PROMETHEUS_URL -Method GET -TimeoutSec 5 -UseBasicParsing
    if ($prometheusResponse.StatusCode -eq 200) {
        Write-Host "✅ Prometheus accesible" -ForegroundColor Green
    } else {
        Write-Host "❌ Prometheus no accesible" -ForegroundColor Red
        $allGood = $false
    }
} catch {
    Write-Host "❌ Error accediendo a Prometheus" -ForegroundColor Red
    $allGood = $false
}

Write-Host "`n7️⃣ VERIFICANDO ARCHIVOS DE PRESENTACIÓN" -ForegroundColor Yellow
$requiredFiles = @(
    "PRESENTACION-FINAL.md",
    "GUION-PRESENTACION.md",
    "demo-presentacion.ps1"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file presente" -ForegroundColor Green
    } else {
        Write-Host "❌ $file faltante" -ForegroundColor Red
        $allGood = $false
    }
}

Write-Host "`n" -NoNewline
Write-Host "🎯 RESUMEN DE VERIFICACIÓN" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan

if ($allGood) {
    Write-Host "🎉 ¡TODO LISTO PARA LA PRESENTACIÓN!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 CHECKLIST FINAL:" -ForegroundColor Cyan
    Write-Host "✅ Cluster EKS funcionando" -ForegroundColor Green
    Write-Host "✅ Aplicación desplegada y corriendo" -ForegroundColor Green
    Write-Host "✅ Monitoreo (Prometheus + Grafana) funcionando" -ForegroundColor Green
    Write-Host "✅ APIs accesibles externamente" -ForegroundColor Green
    Write-Host "✅ Documentación de presentación lista" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 PRÓXIMOS PASOS:" -ForegroundColor Yellow
    Write-Host "1. Revisar GUION-PRESENTACION.md" -ForegroundColor White
    Write-Host "2. Practicar la demo con demo-presentacion.ps1" -ForegroundColor White
    Write-Host "3. Abrir las URLs en pestañas del navegador" -ForegroundColor White
    Write-Host "4. ¡Presentar con confianza!" -ForegroundColor White
    Write-Host ""
    Write-Host "🌐 URLs PARA LA DEMO:" -ForegroundColor Cyan
    Write-Host "API:        $API_URL" -ForegroundColor White
    Write-Host "Grafana:    $GRAFANA_URL" -ForegroundColor White
    Write-Host "Prometheus: $PROMETHEUS_URL" -ForegroundColor White
} else {
    Write-Host "⚠️ HAY PROBLEMAS QUE RESOLVER" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 ACCIONES RECOMENDADAS:" -ForegroundColor Yellow
    Write-Host "1. Verificar conectividad a AWS/EKS" -ForegroundColor White
    Write-Host "2. Revisar estado de pods: kubectl get pods --all-namespaces" -ForegroundColor White
    Write-Host "3. Verificar logs: kubectl logs -f deployment/[nombre] -n [namespace]" -ForegroundColor White
    Write-Host "4. Reintentar en unos minutos" -ForegroundColor White
}

Write-Host ""
Write-Host "🎓 ¡ÉXITO EN TU EVALUACIÓN!" -ForegroundColor Magenta