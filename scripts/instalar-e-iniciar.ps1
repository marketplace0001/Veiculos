$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# AutoMarketplace - Instalador Windows v4
# Maven e instalado diretamente da distribuicao oficial Apache.

$Root = Split-Path -Parent $PSScriptRoot
$LogDir = Join-Path $Root 'logs'
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$Log = Join-Path $LogDir ("instalacao-{0}.log" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
$MavenVersion = '3.9.16'

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
} catch {}

function Write-Step([string]$Message) {
    $line = "[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $Message
    Write-Host "`n$line" -ForegroundColor Cyan
    Add-Content -Path $Log -Value $line
}

function Write-Ok([string]$Message) {
    Write-Host "  OK - $Message" -ForegroundColor Green
    Add-Content -Path $Log -Value "OK - $Message"
}

function Write-Warn([string]$Message) {
    Write-Host "  AVISO - $Message" -ForegroundColor Yellow
    Add-Content -Path $Log -Value "AVISO - $Message"
}

function Refresh-Path {
    $machine = [Environment]::GetEnvironmentVariable('Path','Machine')
    $user = [Environment]::GetEnvironmentVariable('Path','User')
    $env:Path = "$machine;$user"
}

function Test-Command([string]$Name) {
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Ensure-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Step 'Solicitando permissao de Administrador...'
        $bat = Join-Path $Root 'INSTALAR_E_INICIAR.bat'
        Start-Process -FilePath $bat -Verb RunAs
        exit 0
    }
}

function Ensure-Winget {
    Write-Step 'Verificando o Gerenciador de Pacotes do Windows (winget)...'
    if (-not (Test-Command 'winget')) {
        Write-Warn 'winget nao foi encontrado. Ele faz parte do App Installer da Microsoft.'
        Write-Host 'Abra a Microsoft Store, atualize/instale "App Installer" e execute este arquivo novamente.' -ForegroundColor Yellow
        try { Start-Process 'ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1' } catch {}
        exit 20
    }
    Write-Ok 'winget disponivel.'
}

function Install-WingetPackage([string]$Id, [string]$DisplayName, [string]$CommandName) {
    Write-Step "Verificando $DisplayName..."

    if ($CommandName -and (Test-Command $CommandName)) {
        Write-Ok "$DisplayName ja esta disponivel."
        return $false
    }

    $installed = winget list --id $Id --exact --accept-source-agreements 2>$null | Out-String
    if ($LASTEXITCODE -eq 0 -and $installed -match [regex]::Escape($Id)) {
        Refresh-Path
        if (-not $CommandName -or (Test-Command $CommandName)) {
            Write-Ok "$DisplayName ja esta instalado."
            return $false
        }
    }

    Write-Host "  Instalando $DisplayName..." -ForegroundColor White
    & winget install --id $Id --exact --silent --accept-source-agreements --accept-package-agreements --disable-interactivity
    $code = $LASTEXITCODE

    # 0 = sucesso. 3010/1641 sao codigos comuns de sucesso com reinicializacao.
    if ($code -ne 0 -and $code -ne 3010 -and $code -ne 1641) {
        throw "Falha ao instalar $DisplayName pelo winget (codigo $code)."
    }

    Refresh-Path
    if ($code -eq 3010 -or $code -eq 1641) {
        Write-Warn "$DisplayName foi instalado, mas o Windows pode precisar ser reiniciado."
    } else {
        Write-Ok "$DisplayName instalado."
    }
    return $true
}

function Add-MachinePath([string]$PathToAdd) {
    $machinePath = [Environment]::GetEnvironmentVariable('Path','Machine')
    $parts = @($machinePath -split ';' | Where-Object { $_ -and $_.Trim() -ne '' })
    $exists = $false
    foreach ($p in $parts) {
        if ($p.TrimEnd('\\') -ieq $PathToAdd.TrimEnd('\\')) { $exists = $true; break }
    }
    if (-not $exists) {
        $newPath = (($parts + $PathToAdd) -join ';')
        [Environment]::SetEnvironmentVariable('Path', $newPath, 'Machine')
    }
}

function Ensure-Maven {
    Write-Step "Verificando Apache Maven $MavenVersion..."

    if (Test-Command 'mvn') {
        try {
            $mvnText = (& mvn -version 2>&1 | Select-Object -First 1 | Out-String).Trim()
            Write-Ok "Maven ja esta disponivel ($mvnText)."
        } catch {
            Write-Ok 'Maven ja esta disponivel.'
        }
        return
    }

    $installBase = Join-Path $Env:ProgramFiles 'Apache\Maven'
    $mavenHome = Join-Path $installBase "apache-maven-$MavenVersion"
    $mavenBin = Join-Path $mavenHome 'bin'
    $mvnCmd = Join-Path $mavenBin 'mvn.cmd'

    if (-not (Test-Path $mvnCmd)) {
        Write-Host "  Baixando Maven $MavenVersion diretamente do Apache..." -ForegroundColor White
        New-Item -ItemType Directory -Force -Path $installBase | Out-Null

        $tempDir = Join-Path $env:TEMP ("AutoMarketplace-Maven-" + [Guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
        $zipPath = Join-Path $tempDir "apache-maven-$MavenVersion-bin.zip"
        $shaPath = "$zipPath.sha512"

        $mirrors = @(
            "https://dlcdn.apache.org/maven/maven-3/$MavenVersion/binaries/apache-maven-$MavenVersion-bin.zip",
            "https://archive.apache.org/dist/maven/maven-3/$MavenVersion/binaries/apache-maven-$MavenVersion-bin.zip"
        )

        $downloaded = $false
        foreach ($url in $mirrors) {
            try {
                Write-Host "  Tentando: $url" -ForegroundColor DarkGray
                Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing -TimeoutSec 180
                Invoke-WebRequest -Uri ($url + '.sha512') -OutFile $shaPath -UseBasicParsing -TimeoutSec 60

                $expectedText = Get-Content $shaPath -Raw
                $match = [regex]::Match($expectedText, '[A-Fa-f0-9]{128}')
                if (-not $match.Success) { throw 'Checksum SHA-512 oficial nao reconhecido.' }
                $expected = $match.Value.ToUpperInvariant()
                $actual = (Get-FileHash -Path $zipPath -Algorithm SHA512).Hash.ToUpperInvariant()
                if ($actual -ne $expected) { throw 'O checksum SHA-512 do Maven nao confere. Download cancelado.' }

                Write-Ok 'Download do Maven verificado por SHA-512.'
                $downloaded = $true
                break
            } catch {
                Write-Warn ("Falha neste servidor: " + $_.Exception.Message)
                Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
                Remove-Item $shaPath -Force -ErrorAction SilentlyContinue
            }
        }

        if (-not $downloaded) {
            throw 'Nao foi possivel baixar o Apache Maven dos servidores oficiais. Verifique a internet, antivirus/firewall e tente novamente.'
        }

        if (Test-Path $mavenHome) { Remove-Item $mavenHome -Recurse -Force }
        Expand-Archive -Path $zipPath -DestinationPath $installBase -Force
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    if (-not (Test-Path $mvnCmd)) {
        throw "Maven foi baixado, mas mvn.cmd nao foi encontrado em $mvnCmd."
    }

    [Environment]::SetEnvironmentVariable('MAVEN_HOME', $mavenHome, 'Machine')
    Add-MachinePath $mavenBin
    $env:MAVEN_HOME = $mavenHome
    if (-not ($env:Path -split ';' | Where-Object { $_.TrimEnd('\\') -ieq $mavenBin.TrimEnd('\\') })) {
        $env:Path = "$mavenBin;$env:Path"
    }

    if (-not (Test-Command 'mvn')) {
        throw 'Maven foi instalado, mas ainda nao pode ser executado nesta sessao.'
    }

    $versionLine = (& mvn -version 2>&1 | Select-Object -First 1 | Out-String).Trim()
    Write-Ok "Maven instalado e configurado ($versionLine)."
}


function Ensure-WSL2 {
    Write-Step 'Verificando Windows Subsystem for Linux (WSL 2)...'

    $wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -ErrorAction SilentlyContinue
    $vmFeature  = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -ErrorAction SilentlyContinue

    $needsRestart = $false

    if ($null -eq $wslFeature -or $wslFeature.State -ne 'Enabled') {
        Write-Host '  Ativando Windows Subsystem for Linux...' -ForegroundColor White
        & dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'Falha ao ativar o recurso Windows Subsystem for Linux.' }
        $needsRestart = $true
    } else {
        Write-Ok 'Recurso Windows Subsystem for Linux ja esta habilitado.'
    }

    if ($null -eq $vmFeature -or $vmFeature.State -ne 'Enabled') {
        Write-Host '  Ativando Virtual Machine Platform...' -ForegroundColor White
        & dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'Falha ao ativar o recurso Virtual Machine Platform.' }
        $needsRestart = $true
    } else {
        Write-Ok 'Recurso Virtual Machine Platform ja esta habilitado.'
    }

    if ($needsRestart) {
        Write-Warn 'WSL 2 foi habilitado. O Windows precisa ser reiniciado antes de continuar.'
        Write-Host ''
        Write-Host 'REINICIALIZACAO NECESSARIA:' -ForegroundColor Yellow
        Write-Host '1. Reinicie o Windows.' -ForegroundColor Yellow
        Write-Host '2. Depois execute INSTALAR_E_INICIAR.bat novamente.' -ForegroundColor Yellow
        Write-Host '3. O instalador continuara automaticamente.' -ForegroundColor Yellow
        Write-Host ''
        Write-Host "Log: $Log" -ForegroundColor Gray
        exit 23
    }

    # Com os recursos habilitados, garante a camada WSL atualizada e define WSL 2 como padrao.
    if (Test-Command 'wsl') {
        try {
            & wsl.exe --update --web-download 2>$null | Out-Null
        } catch {
            try { & wsl.exe --update 2>$null | Out-Null } catch {}
        }
        try { & wsl.exe --set-default-version 2 2>$null | Out-Null } catch {}
        Write-Ok 'WSL 2 pronto para o Docker Desktop.'
    } else {
        throw 'Os recursos do WSL estao habilitados, mas o comando wsl.exe nao foi encontrado. Execute Windows Update e tente novamente.'
    }
}

function Start-DockerDesktop {
    Write-Step 'Iniciando Docker Desktop...'
    Refresh-Path

    if (Test-Command 'docker') {
        try {
            docker info *> $null
            if ($LASTEXITCODE -eq 0) {
                Write-Ok 'Docker ja esta em execucao.'
                return $true
            }
        } catch {}
    }

    $candidates = @(
        "$Env:ProgramFiles\Docker\Docker\Docker Desktop.exe",
        "$Env:LOCALAPPDATA\Docker\Docker Desktop.exe"
    )
    $exe = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $exe) {
        Write-Warn 'Docker Desktop foi instalado, mas o executavel ainda nao foi localizado.'
        return $false
    }

    Start-Process -FilePath $exe | Out-Null
    Write-Host '  Aguardando o Docker ficar pronto' -NoNewline
    for ($i = 0; $i -lt 80; $i++) {
        Start-Sleep -Seconds 3
        Refresh-Path
        try {
            docker info *> $null
            if ($LASTEXITCODE -eq 0) {
                Write-Host ''
                Write-Ok 'Docker Desktop esta pronto.'
                return $true
            }
        } catch {}
        Write-Host '.' -NoNewline
    }
    Write-Host ''
    Write-Warn 'Docker ainda nao ficou pronto. Em primeira instalacao, o Windows pode pedir ativacao do WSL 2 ou reinicializacao.'
    return $false
}

function Show-Failure([string]$Message, [int]$Code) {
    Write-Host ''
    Write-Host '======================================================' -ForegroundColor Red
    Write-Host ' A instalacao nao conseguiu continuar' -ForegroundColor Red
    Write-Host '======================================================' -ForegroundColor Red
    Write-Host $Message -ForegroundColor Yellow
    Write-Host ''
    Write-Host "Log: $Log" -ForegroundColor Gray
    exit $Code
}

try {
    Ensure-Administrator
    Ensure-Winget
    Refresh-Path

    Write-Step 'Instalando/verificando dependencias do AutoMarketplace...'
    Install-WingetPackage 'EclipseAdoptium.Temurin.21.JDK' 'Java 21 (Temurin)' 'java' | Out-Null

    # IMPORTANTE: Maven nao usa winget nesta versao.
    Ensure-Maven

    Install-WingetPackage 'OpenJS.NodeJS.LTS' 'Node.js LTS' 'node' | Out-Null

    # Docker Desktop no Windows 11 usa WSL 2. Habilitamos antes de iniciar/instalar o Docker.
    Ensure-WSL2

    Install-WingetPackage 'Docker.DockerDesktop' 'Docker Desktop' 'docker' | Out-Null
    Refresh-Path

    Write-Step 'Validando comandos instalados...'
    $missing = @()
    foreach ($cmd in @('java','mvn','node','npm','docker')) {
        if (Test-Command $cmd) {
            Write-Ok "$cmd encontrado."
        } else {
            $missing += $cmd
            Write-Warn "$cmd ainda nao esta no PATH."
        }
    }

    if ($missing.Count -gt 0) {
        Show-Failure ("Alguns comandos ainda nao foram reconhecidos: " + ($missing -join ', ') + ". Reinicie o Windows e execute INSTALAR_E_INICIAR.bat novamente.") 21
    }

    $dockerReady = Start-DockerDesktop
    if (-not $dockerReady) {
        Write-Host ''
        Write-Host 'ACAO NECESSARIA APENAS NA PRIMEIRA VEZ:' -ForegroundColor Yellow
        Write-Host '1. Conclua qualquer configuracao exibida pelo Docker Desktop / WSL 2.' -ForegroundColor Yellow
        Write-Host '2. Se o Windows solicitar reinicializacao, reinicie.' -ForegroundColor Yellow
        Write-Host '3. Depois execute INSTALAR_E_INICIAR.bat novamente.' -ForegroundColor Yellow
        Write-Host ''
        Write-Host "Log: $Log" -ForegroundColor Gray
        exit 22
    }

    Write-Step 'Preparando banco PostgreSQL...'
    Push-Location $Root
    try {
        docker compose up -d
        if ($LASTEXITCODE -ne 0) { throw 'Nao foi possivel iniciar o PostgreSQL pelo Docker Compose.' }
        Write-Ok 'PostgreSQL iniciado.'
    } finally { Pop-Location }

    Write-Step 'Instalando dependencias do frontend...'
    Push-Location (Join-Path $Root 'frontend')
    try {
        & npm install --no-audit --no-fund
        if ($LASTEXITCODE -ne 0) { throw 'npm install falhou.' }
        Write-Ok 'Dependencias do frontend instaladas.'

        Write-Step 'Validando e compilando o frontend TypeScript...'
        & npm run build
        if ($LASTEXITCODE -ne 0) { throw 'O frontend nao passou na compilacao. Consulte a mensagem acima.' }
        Write-Ok 'Frontend compilado sem erros.'
    } finally { Pop-Location }

    Write-Step 'Compilando e testando o backend Java...'
    Push-Location (Join-Path $Root 'backend')
    try {
        & mvn test
        if ($LASTEXITCODE -ne 0) { throw 'Os testes do backend falharam. Consulte a mensagem acima.' }
        Write-Ok 'Backend compilado e testes automaticos aprovados.'
    } finally { Pop-Location }

    Write-Step 'Iniciando backend Java...'
    $backendAlreadyRunning = $false
    try {
        $existing = Invoke-WebRequest -Uri 'http://127.0.0.1:8080/api/public/vehicles' -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
        if ($existing.StatusCode -eq 200) { $backendAlreadyRunning = $true }
    } catch {}

    if ($backendAlreadyRunning) {
        Write-Warn 'Ja existe um backend respondendo na porta 8080. Ele sera utilizado nesta execucao.'
    } else {
        $backendCmd = "cd /d `"$Root\backend`" && mvn spring-boot:run"
        Start-Process 'cmd.exe' -ArgumentList '/k', $backendCmd -WorkingDirectory (Join-Path $Root 'backend') | Out-Null
    }

    Write-Step 'Aguardando backend responder...'
    $backendOk = $false
    for ($i = 0; $i -lt 90; $i++) {
        Start-Sleep -Seconds 2
        try {
            $response = Invoke-WebRequest -Uri 'http://127.0.0.1:8080/api/public/vehicles' -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
            if ($response.StatusCode -eq 200) { $backendOk = $true; break }
        } catch {}
    }
    if (-not $backendOk) { throw 'O backend nao respondeu na porta 8080.' }
    Write-Ok 'Backend esta respondendo.'

    Write-Step 'Verificando se a porta 5173 esta livre...'
    $frontInUse = $false
    try {
        $existingFront = Invoke-WebRequest -Uri 'http://127.0.0.1:5173' -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
        if ($existingFront.StatusCode -eq 200) { $frontInUse = $true }
    } catch {}

    if ($frontInUse) {
        Write-Warn 'Ja existe uma pagina na porta 5173. Feche a janela antiga do frontend se o teste abaixo falhar.'
    } else {
        Write-Step 'Iniciando frontend TypeScript...'
        $frontendCmd = "cd /d `"$Root\frontend`" && npm run dev"
        Start-Process 'cmd.exe' -ArgumentList '/k', $frontendCmd -WorkingDirectory (Join-Path $Root 'frontend') | Out-Null
    }

    Write-Step 'Aguardando pagina e proxy da API...'
    $frontendOk = $false
    for ($i = 0; $i -lt 60; $i++) {
        Start-Sleep -Seconds 2
        try {
            $page = Invoke-WebRequest -Uri 'http://127.0.0.1:5173' -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
            $proxy = Invoke-WebRequest -Uri 'http://127.0.0.1:5173/api/public/vehicles' -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
            if ($page.StatusCode -eq 200 -and $proxy.StatusCode -eq 200) { $frontendOk = $true; break }
        } catch {}
    }
    if (-not $frontendOk) {
        throw 'O frontend/proxy nao respondeu corretamente na porta 5173. Feche frontends antigos e execute novamente.'
    }
    Write-Ok 'Frontend e proxy da API estao respondendo.'

    Write-Step 'Executando teste final de login pelo frontend...'
    $loginBody = @{ email='lojista@automarketplace.local'; password='Loja@123' } | ConvertTo-Json
    try {
        $login = Invoke-RestMethod -Uri 'http://127.0.0.1:5173/api/auth/login' -Method Post -ContentType 'application/json' -Body $loginBody -TimeoutSec 10
        if (-not $login.token) { throw 'Token nao retornado.' }
        Write-Ok 'Login de demonstracao aprovado via proxy do frontend.'
    } catch {
        throw ('O teste final de login falhou: ' + $_.Exception.Message)
    }

    Write-Host ''
    Write-Host '======================================================' -ForegroundColor Green
    Write-Host ' AutoMarketplace v1.0 - v4 validada e iniciada' -ForegroundColor Green
    Write-Host ' Pagina: http://127.0.0.1:5173' -ForegroundColor White
    Write-Host '======================================================' -ForegroundColor Green
    Write-Host ''
    Write-Host 'Contas de teste:' -ForegroundColor White
    Write-Host 'Lojista:  lojista@automarketplace.local / Loja@123'
    Write-Host 'Locadora: locadora@automarketplace.local / Locadora@123'
    Write-Host 'Admin:    admin@automarketplace.local / Admin@123'
    Write-Host ''
    Write-Host "Log desta instalacao: $Log" -ForegroundColor Gray
    Start-Process 'http://127.0.0.1:5173/login'
    exit 0
}
catch {
    $message = $_.Exception.Message
    Add-Content -Path $Log -Value ("ERRO - " + $message)
    Show-Failure $message 1
}
