@echo off
setlocal
title AutoMarketplace - Verificacao da Instalacao

echo ======================================================
echo  AutoMarketplace - Verificacao de Dependencias
 echo ======================================================
echo.

for %%C in (java mvn node npm docker) do (
  where %%C >nul 2>nul
  if errorlevel 1 (
    echo [FALTA] %%C
  ) else (
    echo [OK]    %%C
  )
)

echo.
echo ---- Versoes detectadas ----
java -version 2>&1 | findstr /i "version" 2>nul
mvn -version 2>nul | findstr /i "Apache Maven" 2>nul
node --version 2>nul
npm --version 2>nul
docker --version 2>nul

echo.
echo Se todos aparecerem como [OK], execute INSTALAR_E_INICIAR.bat.
echo.
pause
