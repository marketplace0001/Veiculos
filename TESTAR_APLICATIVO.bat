@echo off
setlocal
cd /d "%~dp0"
title AutoMarketplace v1.0 - Testes
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\testar-aplicativo.ps1"
echo.
pause
exit /b %ERRORLEVEL%
