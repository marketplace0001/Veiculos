@echo off
setlocal
cd /d "%~dp0"
title AutoMarketplace v1.0 - Iniciar

echo =============================================
echo AutoMarketplace v1.0 - Inicializacao rapida
echo =============================================
echo.

docker info >nul 2>&1
if errorlevel 1 (
  echo Docker Desktop nao esta pronto.
  echo Abra o Docker Desktop e aguarde o Engine iniciar.
  pause
  exit /b 1
)

docker compose up -d
if errorlevel 1 (
  echo Falha ao iniciar PostgreSQL.
  pause
  exit /b 1
)

start "AutoMarketplace Backend" cmd /k "cd /d ""%~dp0backend"" && mvn spring-boot:run"
timeout /t 10 /nobreak >nul
start "AutoMarketplace Frontend" cmd /k "cd /d ""%~dp0frontend"" && npm run dev"
timeout /t 5 /nobreak >nul
start "" "http://127.0.0.1:5173/login"

echo.
echo Pagina: http://127.0.0.1:5173/login
echo.
pause
