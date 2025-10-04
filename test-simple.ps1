$apiUrl = "http://a709cebde35644ceca5557ed71f2f964-3a7026267f48c6dd.elb.us-east-1.amazonaws.com"

Write-Host "Testing anomalous log..." -ForegroundColor Yellow

$body = '[{"level": "ERROR", "message": "Database connection failed with timeout exception", "latency_ms": 5000, "source": "test-service"}]'

try {
    $response = Invoke-RestMethod -Uri "$apiUrl/upload-log" -Method POST -Body $body -ContentType "application/json"
    Write-Host "Response received:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nChecking anomalies..." -ForegroundColor Cyan
try {
    $anomalies = Invoke-RestMethod -Uri "$apiUrl/anomalies" -Method GET
    Write-Host "Anomalies found:" -ForegroundColor Green
    $anomalies | ConvertTo-Json -Depth 3
} catch {
    Write-Host "Error checking anomalies: $($_.Exception.Message)" -ForegroundColor Red
}