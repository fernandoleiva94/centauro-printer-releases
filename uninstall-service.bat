@echo off
setlocal

REM Script para desinstalar el servicio de Windows
REM Requiere permisos de administrador

echo.
echo ========================================
echo Desinstalador de Servicio - Centauro Printer
echo ========================================
echo.

REM Verificar permisos de administrador
net session >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Este script requiere permisos de ADMINISTRADOR.
    echo Por favor, ejecuta "cmd" como administrador y vuelve a intentar.
    pause
    exit /b 1
)

set "APP_HOME=%~dp0"
if "%APP_HOME:~-1%"=="\" set "APP_HOME=%APP_HOME:~0,-1%"

set "NSSM_PATH=%APP_HOME%\nssm\nssm.exe"
set "SERVICE_NAME=CentauroPrinter"

echo [INFO] Ruta de aplicacion: %APP_HOME%

if not exist "%NSSM_PATH%" (
    echo [ERROR] No se encontro NSSM en "%NSSM_PATH%".
    pause
    exit /b 1
)

REM Verificar si el servicio existe
"%NSSM_PATH%" status "%SERVICE_NAME%" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] El servicio "%SERVICE_NAME%" no esta instalado.
    pause
    exit /b 1
)

REM Confirmar desinstalacion
echo Se va a desinstalar el servicio "%SERVICE_NAME%".
echo.
set /p confirm="Escriba 'SI' para confirmar: "
if /I not "%confirm%"=="SI" (
    echo Desinstalacion cancelada.
    pause
    exit /b 0
)

REM Detener el servicio
echo [INFO] Deteniendo servicio...
"%NSSM_PATH%" stop "%SERVICE_NAME%" >nul 2>&1

REM Remover el servicio
echo [INFO] Removiendo servicio...
"%NSSM_PATH%" remove "%SERVICE_NAME%" confirm >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Fallo la desinstalacion del servicio.
    pause
    exit /b 1
)

echo.
echo ========================================
echo [EXITO] Servicio desinstalado correctamente
echo ========================================
echo.
pause
exit /b 0

