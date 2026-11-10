@echo off
REM ===========================================================================
REM CHECKLIST DE INSTALACION PARA CLIENTE FINAL
REM ===========================================================================

setlocal EnableDelayedExpansion
color 0A
title CHECKLIST - Instalacion de Centauro Printer

:inicio
cls
echo.
echo ===========================================================================
echo       CENTAURO PRINTER - CHECKLIST DE INSTALACION
echo ===========================================================================
echo.
echo IMPORTANTE: Este script debe ejecutarse como ADMINISTRADOR
echo.

net session >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] No se detectaron permisos de administrador.
    echo.
    echo Pasos para ejecutar como administrador:
    echo   1. Presiona Win + R
    echo   2. Escribe: cmd
    echo   3. Presiona Ctrl + Shift + Enter
    echo   4. Navega a la carpeta donde estan los scripts
    echo   5. Ejecuta este script nuevamente
    echo.
    pause
    exit /b 1
)

echo ✓ Permisos de administrador detectados
echo.
echo ===========================================================================
echo PASO 1: Verificar archivos necesarios
echo ===========================================================================
echo.

set "MISSING=0"

if not exist "printer-app.jar" (
    echo   ✗ FALTA: printer-app.jar
    set "MISSING=1"
) else (
    echo   ✓ printer-app.jar encontrado
)

if not exist "install-service.bat" (
    echo   ✗ FALTA: install-service.bat
    set "MISSING=1"
) else (
    echo   ✓ install-service.bat encontrado
)

if not exist "manage-service.bat" (
    echo   ✗ FALTA: manage-service.bat
    set "MISSING=1"
) else (
    echo   ✓ manage-service.bat encontrado
)

if %MISSING% EQU 1 (
    echo.
    echo [ERROR] Faltan archivos necesarios.
    echo Asegurate de estar en la carpeta "dist" correcta.
    echo.
    pause
    exit /b 1
)

echo.
echo ===========================================================================
echo PASO 2: Verificar Java
echo ===========================================================================
echo.

set "JAVA_FOUND=0"

if exist "java\bin\java.exe" (
    echo   ✓ Java portable encontrado en: java\bin\java.exe
    set "JAVA_FOUND=1"
    goto java_ok
)

if defined JAVA_HOME (
    if exist "%JAVA_HOME%\bin\java.exe" (
        echo   ✓ Java encontrado en JAVA_HOME: %JAVA_HOME%
        set "JAVA_FOUND=1"
        goto java_ok
    )
)

where java >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo   ✓ Java encontrado en PATH
    set "JAVA_FOUND=1"
    goto java_ok
)

:java_notfound
echo   ✗ ADVERTENCIA: Java 21 no se detecto
echo.
echo Opciones:
echo   1. Instala Java 21 desde: https://www.oracle.com/java/technologies/downloads/
echo   2. O copia un runtime de Java 21 en: java\
echo   3. O configura JAVA_HOME en Variables de Entorno
echo.
pause

:java_ok
echo.
echo ===========================================================================
echo PASO 3: Verificar conexion a Internet
echo ===========================================================================
echo.

REM Intentar conectar a un servidor
powershell -Command "try { $result = Invoke-WebRequest -Uri 'https://www.google.com' -TimeoutSec 5 -ErrorAction Stop; Write-Host '   ✓ Conexion a internet OK'; exit 0 } catch { Write-Host '   ✗ ADVERTENCIA: Sin conexion a internet'; exit 1 }" >nul 2>nul

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ADVERTENCIA: Sin conexion a internet detectada.
    echo El script necesita descargar NSSM. Opciones:
    echo   1. Conectate a internet y reintenta
    echo   2. Descarga NSSM manualmente desde: https://nssm.cc/download
    echo      y coloca nssm.exe en: nssm\nssm.exe
    echo.
)

echo.
echo ===========================================================================
echo PASO 4: Preparado para Instalacion
echo ===========================================================================
echo.
echo Todo esta listo para instalar el servicio.
echo.
echo El siguiente paso:
echo   - Ejecutara: install-service.bat
echo   - Descargara NSSM (si no existe)
echo   - Creara el servicio "CentauroPrinter"
echo   - Lo configurara para inicio automatico
echo   - Lo iniciara inmediatamente
echo.
echo El servicio se ejecutara automaticamente cada vez que enciendas Windows.
echo.

set /p continue="Continuar con la instalacion? [S/N]: "

if /I not "%continue%"=="S" (
    echo Instalacion cancelada.
    echo.
    pause
    exit /b 0
)

echo.
echo ===========================================================================
echo INSTALANDO SERVICIO...
echo ===========================================================================
echo.

call install-service.bat

echo.
echo ===========================================================================
echo INSTALACION COMPLETADA
echo ===========================================================================
echo.
echo Ahora puedes usar los siguientes comandos:
echo.
echo   manage-service.bat status      Ver estado del servicio
echo   manage-service.bat start       Iniciar el servicio
echo   manage-service.bat stop        Detener el servicio
echo   manage-service.bat restart     Reiniciar el servicio
echo   manage-service.bat logs        Ver archivo de logs
echo.
echo Para desinstalar el servicio:
echo   uninstall-service.bat
echo.
echo Archivo de configuracion:
echo   C:\centauro-pos-config\centauro-pos-config.properties
echo.
echo Verificar que funciona:
echo   http://localhost:9710/actuator/health
echo   http://localhost:9710/config
echo.

pause
exit /b 0

