@echo off
setlocal
cd /d "%~dp0"
title AutoMarketplace v1.0 - Instalador Automatico v4

echo ======================================================
echo  AutoMarketplace v1.0 - Instalador Automatico v4
echo ======================================================
echo.
echo Esta versao valida o codigo antes de abrir a plataforma.
echo.
echo Verifica/instala:
echo - Java 21
echo - Apache Maven 3.9.16
echo - Node.js LTS
echo - WSL 2
echo - Docker Desktop
echo - PostgreSQL via Docker
echo.
echo Depois executa automaticamente:
echo - npm run build ^(frontend^)
echo - mvn test ^(backend^)
echo - teste do proxy /api
echo - teste de login

echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\instalar-e-iniciar.ps1"
set "ERR=%ERRORLEVEL%"

echo.
if not "%ERR%"=="0" (
  echo O processo parou com codigo %ERR%.
  echo Leia a mensagem acima antes de tentar novamente.
) else (
  echo AutoMarketplace iniciado e validado.
)
echo.
pause
exit /b %ERR%
