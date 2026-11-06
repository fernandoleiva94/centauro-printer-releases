@echo off
REM Script para descargar NSSM manualmente si falla la descarga automatica

setlocal
set "APP_HOME=%~dp0"
if "%APP_HOME:~-1%"=="\" set "APP_HOME=%APP_HOME:~0,-1%"
set "ROOT_NSSM_PATH=%APP_HOME%\nssm.exe"
set "NSSM_PATH=%APP_HOME%\nssm\nssm.exe"

echo.
echo ========================================
echo Descargador de NSSM
echo ========================================
echo.
echo Este script descargara NSSM desde internet.
echo.

if not exist "%APP_HOME%\nssm" mkdir "%APP_HOME%\nssm"

if exist "%ROOT_NSSM_PATH%" (
    copy /Y "%ROOT_NSSM_PATH%" "%NSSM_PATH%" >nul 2>&1
    if exist "%NSSM_PATH%" (
        echo [INFO] NSSM encontrado en la raiz: %ROOT_NSSM_PATH%
        echo.
        echo ========================================
        echo [EXITO] NSSM instalado correctamente
        echo ========================================
        echo.
        echo Ahora puedes ejecutar:
        echo   install-service.bat
        echo.
        pause
        exit /b 0
    )
)

REM Opciones de descarga
set "URL1=https://nssm.cc/download/nssm-2.24-101-g897c7ad.zip"
set "URL2=https://github.com/nssm-cc/nssm/releases/download/2.24-101-g897c7ad/nssm-2.24-101-g897c7ad.zip"

set "OUTPUT=%APP_HOME%\nssm-download.zip"

echo [INFO] Descargando NSSM desde: %URL1%
echo.

REM Intenta descargar con PowerShell
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $ProgressPreference = 'SilentlyContinue'; try { Invoke-WebRequest -Uri '%URL1%' -OutFile '%OUTPUT%' -ErrorAction Stop; Write-Host '[EXITO] Descarga completada'; exit 0 } catch { Write-Host '[INTENTO 2] Intentando URL alternativa...'; try { Invoke-WebRequest -Uri '%URL2%' -OutFile '%OUTPUT%' -ErrorAction Stop; Write-Host '[EXITO] Descarga completada'; exit 0 } catch { Write-Host '[ERROR] No se pudo descargar'; exit 1 } }}" >nul 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] No se pudo descargar NSSM.
    echo.
    echo Opciones:
    echo 1. Verifica tu conexion a internet
    echo 2. Descargalo manualmente desde:
    echo    %URL1%
    echo 3. Extrae el archivo en: %APP_HOME%\nssm\
    echo 4. Copia nssm.exe a: %APP_HOME%\nssm\nssm.exe
    echo.
    pause
    exit /b 1
)

echo [INFO] Extrayendo archivo...
powershell -Command "& {Expand-Archive -Path '%OUTPUT%' -DestinationPath '%APP_HOME%' -Force}" >nul 2>&1

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] No se pudo extraer el archivo.
    pause
    exit /b 1
)

echo [INFO] Buscando nssm.exe...

REM Buscar y copiar nssm.exe
for /r "%APP_HOME%" %%F in (nssm.exe) do (
    if not "%%~dpF"=="%APP_HOME%\nssm\" (
        echo [INFO] Encontrado: %%F
        copy /Y "%%F" "%APP_HOME%\nssm\nssm.exe" >nul 2>&1
    )
)

REM Limpiar
del "%OUTPUT%" >nul 2>&1

if exist "%APP_HOME%\nssm\nssm.exe" (
    echo.
    echo ========================================
    echo [EXITO] NSSM instalado correctamente
    echo ========================================
    echo.
    echo Ahora puedes ejecutar:
    echo   install-service.bat
    echo.
) else (
    echo [ERROR] No se encontro nssm.exe despues de extraer.
    echo.
    echo Intenta descargar manualmente desde:
    echo %URL1%
    echo.
)

pause
exit /b 0

