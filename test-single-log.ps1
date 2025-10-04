$apiUrl = "http://a709cebde35644ceca5557ed71f2f964-3a7026267f48c6dd.elb.us-east-1.amazonaws.com"

# Test 1: Log normal
Write-Host "🧪 Probando log normal..." -ForegroundColor Cyan
$normalLog = @(
    @{
        level = "INFO"
        message = "Processing request successfully"
        latency_ms = 100
        source = "test-service"
    }
) | ConvertTo-Json

try {
    $response1 = Invoke-RestMethod -Uri "$apiUrl/upload-log" -Method POST -Body $normalLog -ContentType "application/json"
    Write-Host "✅ Respuesta log normal:" -ForegroundColor Green
    $response1 | ConvertTo-Json -Depth 3
} catch {
    Write-Host "❌ Error con log normal: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n" -NoNewline

# Test 2: Log anómalo
Write-Host "🚨 Probando log anómalo..." -ForegroundColor Yellow
$anomalousLog = @(
    @{
        level = "ERROR"
        message = "Database connection failed with timeout exception"
        latency_ms = 5000
        source = "test-service"
    }
) | ConvertTo-Json

try {
    $response2 = Invoke-RestMethod -Uri "$apiUrl/upload-log" -Method POST -Body $anomalousLog -ContentType "application/json"
    Write-Host "✅ Respuesta log anómalo:" -ForegroundColor Green
    $response2 | ConvertTo-Json -Depth 3
} catch {
    Write-Host "❌ Error con log anómalo: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n" -NoNewline

# Test 3: Verificar anomalías en la API
Write-Host "📊 Consultando anomalías detectadas..." -ForegroundColor Cyan
try {
    $anomalies = Invoke-RestMethod -Uri "$apiUrl/anomalies" -Method GET
    Write-Host "✅ Anomalías encontradas:" -ForegroundColor Green
    $anomalies | ConvertTo-Json -Depth 3
} catch {
    Write-Host "❌ Error consultando anomalías: $($_.Exception.Message)" -ForegroundColor Red
}