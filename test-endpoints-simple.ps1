#!/usr/bin/env pwsh

$ApiUrl = "http://a709cebde35644ceca5557ed71f2f964-3a7026267f48c6dd.elb.us-east-1.amazonaws.com"

Write-Host "🧪 PRUEBAS DE ENDPOINTS - AI LOG ANALYZER" -ForegroundColor Magenta
Write-Host "=========================================" -ForegroundColor Magenta
Write-Host "🌐 API URL: $ApiUrl" -ForegroundColor Cyan
Write-Host ""

$testCount = 0
$passCount = 0

function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Endpoint,
        [object]$Body = $null
    )
    
    $script:testCount++
    Write-Host "🔍 $testCount. $Name" -ForegroundColor Yellow
    Write-Host "   $Method $Endpoint" -ForegroundColor Gray
    
    try {
        if ($Body) {
            $jsonBody = $Body | ConvertTo-Json -Depth 10
            $response = Invoke-RestMethod -Uri "$ApiUrl$Endpoint" -Method $Method -Body $jsonBody -ContentType "application/json" -TimeoutSec 15
        } else {
            $response = Invoke-RestMethod -Uri "$ApiUrl$Endpoint" -Method $Method -TimeoutSec 15
        }
        
        Write-Host "   ✅ ÉXITO" -ForegroundColor Green
        
        if ($response -is [string] -and $response.Length -gt 200) {
            Write-Host "   📄 Respuesta: $($response.Substring(0, 200))..." -ForegroundColor White
        } elseif ($response -is [object]) {
            $jsonResponse = $response | ConvertTo-Json -Depth 2 -Compress
            if ($jsonResponse.Length -gt 300) {
                Write-Host "   📄 Respuesta: $($jsonResponse.Substring(0, 300))..." -ForegroundColor White
            } else {
                Write-Host "   📄 Respuesta: $jsonResponse" -ForegroundColor White
            }
        } else {
            Write-Host "   📄 Respuesta: $response" -ForegroundColor White
        }
        
        $script:passCount++
        return $true
        
    } catch {
        Write-Host "   ❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
    
    Write-Host ""
}

# 1. Health Check
Test-Endpoint -Name "Health Check" -Method "GET" -Endpoint "/health"

# 2. Métricas
Test-Endpoint -Name "Métricas Prometheus" -Method "GET" -Endpoint "/metrics"

# 3. Log simple
Write-Host ""
$simpleLog = @(
    @{
        level = "INFO"
        message = "Test - Sistema funcionando"
        latency_ms = 150
        source = "test-service"
    }
)
Test-Endpoint -Name "Upload Log Simple" -Method "POST" -Endpoint "/upload-log" -Body $simpleLog

# 4. Logs batch
Write-Host ""
$batchLogs = @(
    @{
        level = "INFO"
        message = "Batch 1 - Request OK"
        latency_ms = 120
        source = "web-service"
    },
    @{
        level = "WARN"
        message = "Batch 2 - High memory"
        latency_ms = 300
        source = "monitor"
    },
    @{
        level = "ERROR"
        message = "Batch 3 - DB failed"
        latency_ms = 5000
        source = "db-service"
    }
)
Test-Endpoint -Name "Upload Batch Logs" -Method "POST" -Endpoint "/upload-log" -Body $batchLogs

# 5. Logs anómalos
Write-Host ""
$anomalousLogs = @(
    @{
        level = "CRITICAL"
        message = "System failure - timeout exception"
        latency_ms = 8000
        source = "critical-service"
    },
    @{
        level = "ERROR"
        message = "HTTP 500 - Database unreachable"
        latency_ms = 6000
        source = "api-gateway"
    }
)
Test-Endpoint -Name "Upload Logs Anómalos" -Method "POST" -Endpoint "/upload-log" -Body $anomalousLogs

# 6. Consultar anomalías
Write-Host ""
Test-Endpoint -Name "Consultar Anomalías" -Method "GET" -Endpoint "/anomalies"

# 7. Consultar anomalías con límite
Write-Host ""
Test-Endpoint -Name "Consultar Anomalías (Limit 5)" -Method "GET" -Endpoint "/anomalies?limit=5"

# Resumen
Write-Host ""
Write-Host "📊 RESUMEN DE PRUEBAS" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host "Total: $testCount" -ForegroundColor White
Write-Host "Exitosas: $passCount" -ForegroundColor Green
Write-Host "Fallidas: $($testCount - $passCount)" -ForegroundColor Red
Write-Host "Éxito: $([Math]::Round(($passCount / $testCount) * 100, 1))%" -ForegroundColor Cyan

Write-Host ""
if ($passCount -eq $testCount) {
    Write-Host "🎉 ¡TODAS LAS PRUEBAS EXITOSAS!" -ForegroundColor Green
} elseif ($passCount -gt ($testCount * 0.8)) {
    Write-Host "✅ ¡EXCELENTE! Mayoría exitosas" -ForegroundColor Green
} else {
    Write-Host "⚠️ Algunas pruebas fallaron" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🔧 Comandos de diagnóstico:" -ForegroundColor Cyan
Write-Host "kubectl logs -f deployment/ai-logs-api -n ai-logs" -ForegroundColor White
Write-Host "kubectl get pods -n ai-logs" -ForegroundColor White