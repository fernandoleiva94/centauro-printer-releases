@echo off
REM ===========================================================================
REM INICIO RAPIDO - CENTAURO PRINTER COMO SERVICIO WINDOWS
REM ===========================================================================

setlocal EnableDelayedExpansion
color 0A
title CENTAURO PRINTER - INICIO RAPIDO

cls
echo.
echo ===========================================================================
echo           CENTAURO PRINTER - SERVICIO WINDOWS
echo ===========================================================================
echo.
echo Tu aplicacion esta lista para funcionar como servicio de Windows.
echo.
echo OPCIONES:
echo.
echo   [1] VER DOCUMENTACION
echo   [2] COMPILAR Y GENERAR DISTRIBUCION
echo   [3] INSTALAR COMO SERVICIO (LOCAL)
echo   [4] GESTIONAR SERVICIO
echo   [5] VER QUICK REFERENCE
echo   [6] SALIR
echo.
set /p opcion="Selecciona una opcion [1-6]: "

if "%opcion%"=="1" goto doc
if "%opcion%"=="2" goto compilar
if "%opcion%"=="3" goto instalar
if "%opcion%"=="4" goto gestionar
if "%opcion%"=="5" goto quickref
if "%opcion%"=="6" goto fin
goto menu

:doc
cls
echo.
echo ===========================================================================
echo                      DOCUMENTACION DISPONIBLE
echo ===========================================================================
echo.
echo PARA EMPEZAR:
echo   - COMPLETADO.md                 Resumen visual de todo lo realizado
echo   - QUICK_REFERENCE.md            Referencia rapida de comandos
echo.
echo PARA ENTENDER:
echo   - README-SERVICIO.md            Resumen ejecutivo
echo   - INDICE-SERVICIO.md            Indice completo de archivos
echo.
echo PARA DETALLES:
echo   - SERVICE_INSTALL.md            Manual completo y detallado
echo   - DEPLOY_WINDOWS.md             Guia de distribucion
echo.
echo PARA EL CLIENTE:
echo   - dist/LEEME.txt                Instrucciones finales (se genera con build-dist.bat)
echo.
echo ===========================================================================
echo ARCHIVOS DE SCRIPTS CREADOS:
echo ===========================================================================
echo.
echo INSTALACION/DESINSTALACION:
echo   - install-service.bat           Instalar como servicio
echo   - uninstall-service.bat         Desinstalar servicio
echo   - checklist-instalacion.bat     Instalacion guiada para cliente
echo.
echo GESTION:
echo   - manage-service.bat            Gestionar servicio (status, start, stop, etc)
echo   - download-nssm.bat             Descargar NSSM manualmente
echo.
echo AYUDA:
echo   - guia-rapida.bat               Menu interactivo de ayuda
echo   - inicio-rapido.bat             Este archivo
echo.
echo COMPILACION:
echo   - build-dist.bat                Compilar y generar dist/
echo.
echo EJECUCION:
echo   - run-printer.bat               Ejecutar manualmente (sin servicio)
echo.
pause
goto menu

:compilar
cls
echo.
echo ===========================================================================
echo                    COMPILANDO Y GENERANDO DISTRIBUCION
echo ===========================================================================
echo.
echo Se va a ejecutar: build-dist.bat
echo.
echo Esto:
echo   1. Compilara el proyecto con Maven
echo   2. Generara la carpeta dist/ con:
echo      - printer-app.jar
echo      - Todos los scripts necesarios
echo      - Archivo de ejemplo de configuracion
echo      - Archivo LEEME.txt para el cliente
echo.
echo La carpeta dist/ sera lo que entregaras al cliente.
echo.
pause
call build-dist.bat
echo.
echo ========================================
echo Compilacion completada.
echo Carpeta generada: dist/
echo ========================================
echo.
pause
goto menu

:instalar
cls
echo.
echo ===========================================================================
echo                   INSTALAR COMO SERVICIO (LOCAL)
echo ===========================================================================
echo.

net session >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] No se detectaron permisos de administrador.
    echo.
    echo Por favor, abre una terminal como ADMINISTRADOR y ejecuta:
    echo   checklist-instalacion.bat
    echo.
    pause
    goto menu
)

echo Permisos de administrador: OK
echo.
echo Se va a instalar el servicio localmente para pruebas.
echo.

if not exist "dist\install-service.bat" (
    echo [ERROR] Debe ejecutar primero: build-dist.bat
    echo.
    pause
    goto menu
)

cd dist
checklist-instalacion.bat

cd ..
goto menu

:gestionar
cls
echo.
echo ===========================================================================
echo                   GESTIONAR SERVICIO
echo ===========================================================================
echo.
echo Comandos disponibles:
echo.
echo   manage-service.bat status      Ver estado del servicio
echo   manage-service.bat start       Iniciar el servicio
echo   manage-service.bat stop        Detener el servicio
echo   manage-service.bat restart     Reiniciar el servicio
echo   manage-service.bat logs        Abrir carpeta de logs
echo   manage-service.bat edit        Editar en services.msc
echo.
echo ===========================================================================
echo ESTADO ACTUAL DEL SERVICIO:
echo ===========================================================================
echo.

if not exist "dist\manage-service.bat" (
    echo [AVISO] Debe ejecutar primero: build-dist.bat
    echo.
    pause
    goto menu
)

call dist\manage-service.bat status
pause
goto menu

:quickref
cls
echo.
echo ===========================================================================
echo                   REFERENCIA RAPIDA
echo ===========================================================================
echo.
echo COMPILAR:
echo   build-dist.bat
echo.
echo INSTALAR (CLIENTE):
echo   checklist-instalacion.bat       [Recomendado, con verificacion]
echo   install-service.bat             [Directo]
echo.
echo GESTIONAR:
echo   manage-service.bat status       [Ver estado]
echo   manage-service.bat start        [Iniciar]
echo   manage-service.bat stop         [Detener]
echo   manage-service.bat restart      [Reiniciar]
echo   manage-service.bat logs         [Ver logs]
echo.
echo EJECUTAR MANUAL:
echo   run-printer.bat                 [Sin servicio]
echo.
echo DESINSTALAR:
echo   uninstall-service.bat           [Con confirmacion]
echo.
echo AYUDA:
echo   guia-rapida.bat                 [Menu interactivo]
echo.
echo CONFIGURACION:
echo   C:\centauro-pos-config\centauro-pos-config.properties
echo.
echo VERIFICAR:
echo   http://localhost:9710/actuator/health
echo.
pause
goto menu

:fin
cls
exit /b 0

