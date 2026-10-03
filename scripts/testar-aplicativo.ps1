$ErrorActionPreference = 'Stop'

function Ok($m){ Write-Host "OK - $m" -ForegroundColor Green }
function Step($m){ Write-Host "`n$m" -ForegroundColor Cyan }

try {
    Step '1/5 - Backend publico'
    $vehicles = Invoke-RestMethod -Uri 'http://127.0.0.1:8080/api/public/vehicles' -TimeoutSec 8
    if (-not $vehicles -or $vehicles.Count -lt 1) { throw 'Nenhum veiculo retornado pelo backend.' }
    Ok 'Catalogo publico respondeu.'

    Step '2/5 - Login do lojista direto no backend'
    $body = @{email='lojista@automarketplace.local';password='Loja@123'} | ConvertTo-Json
    $login = Invoke-RestMethod -Uri 'http://127.0.0.1:8080/api/auth/login' -Method Post -ContentType 'application/json' -Body $body -TimeoutSec 8
    if (-not $login.token) { throw 'Login nao retornou token.' }
    Ok 'Login do lojista aprovado.'

    Step '3/5 - Endpoint protegido do lojista'
    $headers = @{Authorization="Bearer $($login.token)"}
    $dealer = Invoke-RestMethod -Uri 'http://127.0.0.1:8080/api/dealer/vehicles' -Headers $headers -TimeoutSec 8
    Ok 'Painel do lojista autorizado.'

    Step '4/5 - Frontend e proxy'
    $page = Invoke-WebRequest -Uri 'http://127.0.0.1:5173' -UseBasicParsing -TimeoutSec 8
    if ($page.StatusCode -ne 200) { throw 'Frontend nao respondeu 200.' }
    $proxyVehicles = Invoke-RestMethod -Uri 'http://127.0.0.1:5173/api/public/vehicles' -TimeoutSec 8
    if (-not $proxyVehicles -or $proxyVehicles.Count -lt 1) { throw 'Proxy do frontend nao retornou veiculos.' }
    Ok 'Frontend e proxy responderam.'

    Step '5/5 - Login passando pelo frontend/proxy'
    $proxyLogin = Invoke-RestMethod -Uri 'http://127.0.0.1:5173/api/auth/login' -Method Post -ContentType 'application/json' -Body $body -TimeoutSec 8
    if (-not $proxyLogin.token) { throw 'Login via proxy nao retornou token.' }
    Ok 'Login via frontend/proxy aprovado.'

    Write-Host "`n==============================================" -ForegroundColor Green
    Write-Host ' TODOS OS TESTES PRINCIPAIS PASSARAM' -ForegroundColor Green
    Write-Host '==============================================' -ForegroundColor Green
    exit 0
}
catch {
    Write-Host "`nFALHA: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
