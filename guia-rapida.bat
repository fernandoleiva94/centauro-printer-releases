@echo off
REM Guia rapida interactiva para instalar como servicio

setlocal
color 0A

:menu
cls
echo.
echo ================================================
echo      CENTAURO PRINTER - GUIA DE INSTALACION
echo ================================================
echo.
echo Elige una opcion:
echo.
echo [1] Instalar como Servicio de Windows ^(RECOMENDADO^)
echo [2] Ejecutar manualmente
echo [3] Ver instrucciones detalladas
echo [4] Salir
echo.
set /p choice="Selecciona una opcion [1-4]: "

if "%choice%"=="1" goto instalar_servicio
if "%choice%"=="2" goto ejecutar_manual
if "%choice%"=="3" goto instrucciones
if "%choice%"=="4" goto fin
goto menu

:instalar_servicio
cls
echo.
echo ================================================
echo    INSTALACION COMO SERVICIO
echo ================================================
echo.
echo IMPORTANTE: Debes ejecutar esto como ADMINISTRADOR
echo.
echo Abre una terminal como administrador:
echo   1. Click derecho en el escritorio
echo   2. Selecciona "Abrir PowerShell como administrador"
echo   3. Ve a la carpeta dist
echo   4. Ejecuta: install-service.bat
echo.
echo Despues de instalado, usa:
echo   manage-service.bat status    - Ver estado
echo   manage-service.bat start     - Iniciar
echo   manage-service.bat stop      - Detener
echo   manage-service.bat restart   - Reiniciar
echo   manage-service.bat logs      - Ver logs
echo.
pause
goto menu

:ejecutar_manual
cls
echo.
echo ================================================
echo    EJECUCION MANUAL
echo ================================================
echo.
echo Simplemente ejecuta: run-printer.bat
echo.
echo Ventajas:
echo   - No requiere permisos especiales
echo   - Perfecto para pruebas
echo   - Ves la salida en tiempo real
echo.
echo Desventajas:
echo   - No inicia automaticamente
echo   - Si cierras la ventana, se detiene
echo   - Se reinicia manualmente si falla
echo.
echo La configuracion se crea en:
echo   C:\centauro-pos-config\centauro-pos-config.properties
echo.
pause
goto menu

:instrucciones
cls
echo.
echo ================================================
echo    INSTRUCCIONES DETALLADAS
echo ================================================
echo.
echo 1. COMPILAR LA APLICACION:
echo    Ejecuta desde la raiz del proyecto:
echo    ^ ^ build-dist.bat
echo.
echo 2. DISTRIBUIR AL CLIENTE:
echo    Entrega la carpeta "dist" completa
echo.
echo 3. CLIENTE INSTALA EL SERVICIO:
echo    a. Abre cmd como administrador
echo    b. cd C:\ruta\dist
echo    c. install-service.bat
echo.
echo 4. GESTIONAR EL SERVICIO:
echo    manage-service.bat status     - Ver estado
echo    manage-service.bat start      - Iniciar
echo    manage-service.bat stop       - Detener
echo    manage-service.bat restart    - Reiniciar
echo    manage-service.bat logs       - Ver logs
echo    manage-service.bat edit       - Editar en services.msc
echo.
echo 5. DESINSTALAR:
echo    uninstall-service.bat
echo.
echo ARCHIVOS IMPORTANTES:
echo   Configuracion: C:\centauro-pos-config\centauro-pos-config.properties
echo   Logs:          dist\logs\stdout.log
echo   Port:          9710 ^(por defecto^)
echo.
echo VERIFICAR QUE FUNCIONA:
echo   http://localhost:9710/actuator/health
echo   http://localhost:9710/printers
echo   http://localhost:9710/config
echo.
pause
goto menu

:fin
cls
exit /b 0

