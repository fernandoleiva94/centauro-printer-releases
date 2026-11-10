@echo off
setlocal

REM Script de utilidad para gestionar el servicio Centauro Printer

set "APP_HOME=%~dp0"
if "%APP_HOME:~-1%"=="\" set "APP_HOME=%APP_HOME:~0,-1%"

set "NSSM_PATH=%APP_HOME%\nssm\nssm.exe"
set "SERVICE_NAME=CentauroPrinter"

if not exist "%NSSM_PATH%" (
    echo [ERROR] NSSM no esta instalado. Ejecuta "install-service.bat" primero.
    pause
    exit /b 1
)

if "%1"=="" (
    echo Uso: manage-service.bat [comando]
    echo.
    echo Comandos disponibles:
    echo   status      - Ver el estado del servicio
    echo   start       - Iniciar el servicio
    echo   stop        - Detener el servicio
    echo   restart     - Reiniciar el servicio
    echo   logs        - Abrir la carpeta de logs
    echo   edit        - Editar la configuracion
    echo.
    pause
    exit /b 0
)

if /I "%1"=="status" (
    "%NSSM_PATH%" status "%SERVICE_NAME%"
    pause
    exit /b 0
)

if /I "%1"=="start" (
    net session >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Se requieren permisos de administrador.
        pause
        exit /b 1
    )
    "%NSSM_PATH%" start "%SERVICE_NAME%"
    pause
    exit /b 0
)

if /I "%1"=="stop" (
    net session >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Se requieren permisos de administrador.
        pause
        exit /b 1
    )
    "%NSSM_PATH%" stop "%SERVICE_NAME%"
    pause
    exit /b 0
)

if /I "%1"=="restart" (
    net session >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Se requieren permisos de administrador.
        pause
        exit /b 1
    )
    "%NSSM_PATH%" restart "%SERVICE_NAME%"
    pause
    exit /b 0
)

if /I "%1"=="logs" (
    if exist "%APP_HOME%\logs" (
        start explorer "%APP_HOME%\logs"
    ) else (
        echo [INFO] Carpeta de logs no existe aun.
        pause
    )
    exit /b 0
)

if /I "%1"=="edit" (
    echo Abriendo editor de servicios...
    start services.msc
    exit /b 0
)

echo [ERROR] Comando desconocido: %1
pause
exit /b 1

