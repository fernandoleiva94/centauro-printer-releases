@echo off
setlocal

set "APP_HOME=%~dp0"
if "%APP_HOME:~-1%"=="\" set "APP_HOME=%APP_HOME:~0,-1%"

set "JAR_PATH=%APP_HOME%\printer-app.jar"
set "CONFIG_DIR=C:\dist\centauro-pos-config"
set "CONFIG_FILE=%CONFIG_DIR%\centauro-pos-config.properties"

if not "%~1"=="" set "CONFIG_FILE=%~1"
for %%I in ("%CONFIG_FILE%") do set "CONFIG_DIR=%%~dpI"
if "%CONFIG_DIR:~-1%"=="\" set "CONFIG_DIR=%CONFIG_DIR:~0,-1%"

set "JAVA_CMD=%APP_HOME%\java\bin\java.exe"
if exist "%JAVA_CMD%" goto run

if defined JAVA_HOME if exist "%JAVA_HOME%\bin\java.exe" set "JAVA_CMD=%JAVA_HOME%\bin\java.exe"
if exist "%JAVA_CMD%" goto run

where java >nul 2>nul
if %ERRORLEVEL% EQU 0 set "JAVA_CMD=java"

:run
if not exist "%JAR_PATH%" (
    echo [ERROR] No se encontro "%JAR_PATH%".
    echo Copia este archivo junto al jar generado y renombral o a "printer-app.jar".
    exit /b 1
)

if /I not "%JAVA_CMD%"=="java" if not exist "%JAVA_CMD%" (
    echo [ERROR] No se encontro Java 21.
    echo Opciones:
    echo   1. Copiar un runtime en "%APP_HOME%\java"
    echo   2. Configurar JAVA_HOME
    echo   3. Agregar java al PATH
    exit /b 1
)

if not exist "%CONFIG_DIR%" mkdir "%CONFIG_DIR%" >nul 2>nul
if not exist "%CONFIG_FILE%" (
    > "%CONFIG_FILE%" echo punto_de_venta=1
    >> "%CONFIG_FILE%" echo cuit=201234567891
    echo [INFO] Se creo el archivo de configuracion inicial en "%CONFIG_FILE%".
)

set "EXTERNAL_CONFIG_FILE=%CONFIG_FILE%"

echo [INFO] Iniciando Centauro Printer...
echo [INFO] Java: %JAVA_CMD%
echo [INFO] Jar: %JAR_PATH%
echo [INFO] Configuracion: %CONFIG_FILE%
echo [INFO] URL salud: http://localhost:9710/actuator/health
echo.

"%JAVA_CMD%" -jar "%JAR_PATH%"
set "EXIT_CODE=%ERRORLEVEL%"

echo.
echo [INFO] La aplicacion finalizo con codigo %EXIT_CODE%.
pause
exit /b %EXIT_CODE%

