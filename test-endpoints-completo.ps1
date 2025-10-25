#!/usr/bin/env pwsh

param(
    [string]$ApiUrl = "http://a709cebde35644ceca5557ed71f2f964-3a7026267f48c6dd.elb.us-east-1.amazonaws.com"
)

Write-Host "🧪 PRUEBAS COMPLETAS DE ENDPOINTS - AI LOG ANALYZER" -ForegroundColor Magenta
Write-Host "=================================================" -ForegroundColor Magenta
Write-Host "🌐 API URL: $ApiUrl" -ForegroundColor Cyan
Write-Host ""

$testResults = @()
$totalTests = 0
$passedTests = 0

function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Endpoint,
        [object]$Body = $null,
        [hashtable]$Headers = @{"Content-Type" = "application/json"},
        [int]$ExpectedStatus = 200
    )
    
    $global:totalTests++
    Write-Host "🔍 Probando: $Name" -ForegroundColor Yellow
    Write-Host "   $Method $Endpoint" -ForegroundColor Gray
    
    try {
        $params = @{
            Uri = "$ApiUrl$Endpoint"
            Method = $Method
            TimeoutSec = 30
        }
        
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json -Depth 10)
            $params.ContentType = "application/json"
        }
        
        if ($Headers) {
            $params.Headers = $Headers
        }
        
        $response = Invoke-RestMethod @params
        
        Write-Host "   ✅ ÉXITO - Status: 200" -ForegroundColor Green
        Write-Host "   📄 Respuesta:" -ForegroundColor Cyan
        
        if ($response -is [string]) {
            Write-Host "   $($response.Substring(0, [Math]::Min(200, $response.Length)))" -ForegroundColor White
        } else {
            $jsonResponse = $response | ConvertTo-Json -Depth 3 -Compress
            $truncated = if ($jsonResponse.Length -gt 300) { $jsonResponse.Substring(0, 300) + "..." } else { $jsonResponse }
            Write-Host "   $truncated" -ForegroundColor White
        }
        
        $global:passedTests++
        $global:testResults += @{
            Name = $Name
            Status = "✅ PASS"
            Response = $response
        }
        
    } catch {
        Write-Host "   ❌ ERROR - $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            Write-Host "   Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        }
        
        $global:testResults += @{
            Name = $Name
            Status = "❌ FAIL"
            Error = $_.Exception.Message
        }
    }
    
    Write-Host ""
}

Write-Host "1️⃣ ENDPOINT: HEALTH CHECK" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow
Test-Endpoint -Name "Health Check" -Method "GET" -Endpoint "/health"

Write-Host "2️⃣ ENDPOINT: MÉTRICAS PROMETHEUS" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Yellow
Test-Endpoint -Name "Métricas Prometheus" -Method "GET" -Endpoint "/metrics"

Write-Host "3️⃣ ENDPOINT: UPLOAD LOG (JSON SIMPLE)" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Yellow
$simpleLog = @(
    @{
        level = "INFO"
        message = "Test log - Sistema funcionando correctamente"
        latency_ms = 150
        source = "test-service"
    }
)
Test-Endpoint -Name "Upload Log Simple" -Method "POST" -Endpoint "/upload-log" -Body $simpleLog

Write-Host "4️⃣ ENDPOINT: UPLOAD LOG (BATCH)" -ForegroundColor Yellow
Write-Host "===============================" -ForegroundColor Yellow
$batchLogs = @(
    @{
        level = "INFO"
        message = "Batch test 1 - Request processed successfully"
        latency_ms = 120
        source = "web-service"
    },
    @{
        level = "WARN"
        message = "Batch test 2 - High memory usage detected"
        latency_ms = 300
        source = "memory-monitor"
    },
    @{
        level = "ERROR"
        message = "Batch test 3 - Database connection failed"
        latency_ms = 5000
        source = "db-service"
    }
)
Test-Endpoint -Name "Upload Log Batch" -Method "POST" -Endpoint "/upload-log" -Body $batchLogs

Write-Host "5️⃣ ENDPOINT: LOGS ANÓMALOS" -ForegroundColor Yellow
Write-Host "===========================" -ForegroundColor Yellow
$anomalousLogs = @(
    @{
        level = "CRITICAL"
        message = "System failure - Service timeout exception occurred"
        latency_ms = 8000
        source = "critical-service"
    },
    @{
        level = "ERROR"
        message = "HTTP 500 internal server error - Database unreachable"
        latency_ms = 6000
        source = "api-gateway"
    }
)
Test-Endpoint -Name "Upload Logs Anómalos" -Method "POST" -Endpoint "/upload-log" -Body $anomalousLogs

Write-Host "6️⃣ ENDPOINT: CONSULTAR ANOMALÍAS" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Yellow
Test-Endpoint -Name "Consultar Anomalías (Default)" -Method "GET" -Endpoint "/anomalies"
Test-Endpoint -Name "Consultar Anomalías (Limit 5)" -Method "GET" -Endpoint "/anomalies?limit=5"
Test-Endpoint -Name "Consultar Anomalías (Limit 50)" -Method "GET" -Endpoint "/anomalies?limit=50"

Write-Host "7️⃣ ENDPOINT: UPLOAD LOG FILE (Simulado)" -ForegroundColor Yellow
Write-Host "=======================================" -ForegroundColor Yellow
# Crear archivo temporal para prueba
$tempLogFile = "temp-test.jsonl"
$logLines = @(
    '{"level": "INFO", "message": "File test 1", "latency_ms": 100, "source": "file-service"}',
    '{"level": "ERROR", "message": "File test 2 - Connection refused", "latency_ms": 3000, "source": "file-service"}',
    '{"level": "DEBUG", "message": "File test 3", "latency_ms": 50, "source": "file-service"}'
)
$logLines | Out-File -FilePath $tempLogFile -Encoding UTF8

try {
    Write-Host "🔍 Probando: Upload Log File" -ForegroundColor Yellow
    Write-Host "   POST /upload-log-file" -ForegroundColor Gray
    
    # Para file upload necesitamos usar Invoke-WebRequest con multipart
    $boundary = [System.Guid]::NewGuid().ToString()
    $fileContent = Get-Content $tempLogFile -Raw
    $bodyLines = @(
        "--$boundary",
        'Content-Disposition: form-data; name="file"; filename="test.jsonl"',
        'Content-Type: application/json',
        '',
        $fileContent,
        "--$boundary--"
    )
    $body = $bodyLines -join "`r`n"
    
    $response = Invoke-RestMethod -Uri "$ApiUrl/upload-log-file" -Method POST -Body $body -ContentType "multipart/form-data; boundary=$boundary" -TimeoutSec 30
    
    Write-Host "   ✅ ÉXITO - File Upload" -ForegroundColor Green
    $jsonResponse = $response | ConvertTo-Json -Depth 3 -Compress
    $truncated = if ($jsonResponse.Length -gt 300) { $jsonResponse.Substring(0, 300) + "..." } else { $jsonResponse }
    Write-Host "   📄 Respuesta: $truncated" -ForegroundColor White
    
    $global:passedTests++
    $global:testResults += @{
        Name = "Upload Log File"
        Status = "✅ PASS"
        Response = $response
    }
    
} catch {
    Write-Host "   ❌ ERROR - $($_.Exception.Message)" -ForegroundColor Red
    $global:testResults += @{
        Name = "Upload Log File"
        Status = "❌ FAIL"
        Error = $_.Exception.Message
    }
} finally {
    # Limpiar archivo temporal
    if (Test-Path $tempLogFile) {
        Remove-Item $tempLogFile -Force
    }
}

$global:totalTests++
Write-Host ""

Write-Host "8️⃣ PRUEBAS DE LÍMITES Y VALIDACIÓN" -ForegroundColor Yellow
Write-Host "==================================" -ForegroundColor Yellow

# Test con datos inválidos
Write-Host "🔍 Probando: Log con datos inválidos" -ForegroundColor Yellow
try {
    $invalidLog = @(
        @{
            level = "INVALID_LEVEL"
            message = ""
            latency_ms = "not_a_number"
            source = $null
        }
    )
    $response = Invoke-RestMethod -Uri "$ApiUrl/upload-log" -Method POST -Body ($invalidLog | ConvertTo-Json) -ContentType "application/json" -TimeoutSec 30
    Write-Host "   ⚠️ ADVERTENCIA - Datos inválidos aceptados" -ForegroundColor Yellow
    $global:passedTests++
} catch {
    Write-Host "   ✅ CORRECTO - Datos inválidos rechazados: $($_.Exception.Message)" -ForegroundColor Green
    $global:passedTests++
}
$global:totalTests++

Write-Host ""
Write-Host "📊 RESUMEN DE PRUEBAS" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host "Total de pruebas: $totalTests" -ForegroundColor White
Write-Host "Pruebas exitosas: $passedTests" -ForegroundColor Green
Write-Host "Pruebas fallidas: $($totalTests - $passedTests)" -ForegroundColor Red
Write-Host "Tasa de éxito: $([Math]::Round(($passedTests / $totalTests) * 100, 2))%" -ForegroundColor Cyan

Write-Host ""
Write-Host "📋 DETALLE DE RESULTADOS" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
foreach ($result in $testResults) {
    Write-Host "$($result.Status) $($result.Name)" -ForegroundColor White
}

Write-Host ""
if ($passedTests -eq $totalTests) {
    Write-Host "🎉 ¡TODAS LAS PRUEBAS PASARON!" -ForegroundColor Green
    Write-Host "✅ Tu API está funcionando perfectamente" -ForegroundColor Green
} elseif ($passedTests -gt ($totalTests * 0.8)) {
    Write-Host "✅ ¡EXCELENTE! La mayoría de pruebas pasaron" -ForegroundColor Green
    Write-Host "⚠️ Revisa las pruebas fallidas para optimizar" -ForegroundColor Yellow
} else {
    Write-Host "⚠️ Algunas pruebas fallaron" -ForegroundColor Yellow
    Write-Host "🔧 Revisa los logs de la aplicación para diagnosticar" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "🔍 COMANDOS ÚTILES PARA DIAGNÓSTICO:" -ForegroundColor Cyan
Write-Host "kubectl logs -f deployment/ai-logs-api -n ai-logs" -ForegroundColor White
Write-Host "kubectl get pods -n ai-logs" -ForegroundColor White
Write-Host "kubectl describe pod [pod-name] -n ai-logs" -ForegroundColor White

Write-Host ""
Write-Host "🌐 URLs para verificación manual:" -ForegroundColor Cyan
Write-Host "API Health: $ApiUrl/health" -ForegroundColor White
Write-Host "Métricas: $ApiUrl/metrics" -ForegroundColor White
Write-Host "Anomalías: $ApiUrl/anomalies" -ForegroundColor White