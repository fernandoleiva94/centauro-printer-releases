@echo off
setlocal EnableDelayedExpansion

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
set "DIST=%ROOT%\dist"
set "TARGET=%ROOT%\target"
set "LAUNCHER=%ROOT%\run-printer.bat"
set "JAVA_CMD=%ROOT%\java\bin\java.exe"

if exist "%JAVA_CMD%" goto javaReady

if defined JAVA_HOME if exist "%JAVA_HOME%\bin\java.exe" (
    set "JAVA_CMD=%JAVA_HOME%\bin\java.exe"
    goto javaReady
)

for /f "delims=" %%I in ('where java 2^>nul') do (
    set "JAVA_CMD=%%~fI"
    goto javaReady
)

echo [ERROR] No se encontro Java 21 para compilar el proyecto.
echo Opciones:
echo   1. Configurar JAVA_HOME apuntando a un JDK 21
echo   2. Agregar java al PATH
echo   3. Copiar un JDK portable en "%ROOT%\java"
exit /b 1

:javaReady
for %%I in ("%JAVA_CMD%") do set "JAVA_BIN=%%~dpI"
if "%JAVA_BIN:~-1%"=="\" set "JAVA_BIN=%JAVA_BIN:~0,-1%"
for %%I in ("%JAVA_BIN%\..") do set "JAVA_HOME=%%~fI"

pushd "%ROOT%" >nul

echo [1/4] Generando jar de Spring Boot...
call "%ROOT%\mvnw.cmd" clean package -DskipTests
if errorlevel 1 goto fail

echo [2/4] Preparando carpeta dist...
if exist "%DIST%" rmdir /s /q "%DIST%"
mkdir "%DIST%"
mkdir "%DIST%\nssm"
mkdir "%DIST%\java"
mkdir "%DIST%\config"

set "APP_JAR="
for %%F in ("%TARGET%\*.jar") do (
    set "APP_JAR=%%~fF"
    goto jarFound
)

echo [ERROR] No se encontro ningun jar en "%TARGET%".
goto fail

:jarFound
echo [3/4] Copiando artefactos...
copy /Y "%LAUNCHER%" "%DIST%\run-printer.bat" >nul
copy /Y "!APP_JAR!" "%DIST%\printer-app.jar" >nul
copy /Y "%ROOT%\install-service.bat" "%DIST%\install-service.bat" >nul
copy /Y "%ROOT%\uninstall-service.bat" "%DIST%\uninstall-service.bat" >nul
copy /Y "%ROOT%\manage-service.bat" "%DIST%\manage-service.bat" >nul
copy /Y "%ROOT%\download-nssm.bat" "%DIST%\download-nssm.bat" >nul
copy /Y "%ROOT%\guia-rapida.bat" "%DIST%\guia-rapida.bat" >nul
copy /Y "%ROOT%\checklist-instalacion.bat" "%DIST%\checklist-instalacion.bat" >nul
copy /Y "%ROOT%\inicio-rapido.bat" "%DIST%\inicio-rapido.bat" >nul
if exist "%ROOT%\nssm.exe" copy /Y "%ROOT%\nssm.exe" "%DIST%\nssm\nssm.exe" >nul

> "%DIST%\config\centauro-pos-config.properties.example" echo punto_de_venta=1
>> "%DIST%\config\centauro-pos-config.properties.example" echo cuit=20364077034
> "%DIST%\java\README.txt" echo Copia aqui un runtime de Java 21 si no quieres depender de JAVA_HOME o PATH.
> "%DIST%\LEEME.txt" echo ================================================
>> "%DIST%\LEEME.txt" echo      CENTAURO PRINTER - GUIA DE INSTALACION
>> "%DIST%\LEEME.txt" echo ================================================
>> "%DIST%\LEEME.txt" echo.
>> "%DIST%\LEEME.txt" echo OPCION 1: INSTALACION COMO SERVICIO ^(RECOMENDADO^)
>> "%DIST%\LEEME.txt" echo.
>> "%DIST%\LEEME.txt" echo 1. Abre una terminal como ADMINISTRADOR
>> "%DIST%\LEEME.txt" echo    - Click derecho en la carpeta
>> "%DIST%\LEEME.txt" echo    - Selecciona "Abrir PowerShell como administrador"
>> "%DIST%\LEEME.txt" echo.
>> "%DIST%\LEEME.txt" echo 2. Ejecuta: install-service.bat
>> "%DIST%\LEEME.txt" echo    - Descarga NSSM automaticamente
>> "%DIST%\LEEME.txt" echo    - Crea el servicio "CentauroPrinter"
>> "%DIST%\LEEME.txt" echo    - Lo inicia automaticamente
>> "%DIST%\LEEME.txt" echo.
>> "%DIST%\LEEME.txt" echo 3. Listo^! El servicio esta corriendo
>> "%DIST%\LEEME.txt" echo    - Se reinicia automaticamente al encender
>> "%DIST%\LEEME.txt" echo    - Si falla, se reinicia automaticanamente
>> "%DIST%\LEEME.txt" echo.
>> "%DIST%\LEEME.txt" echo COMANDOS UTILES:
>> "%DIST%\LEEME.txt" echo   manage-service.bat status      Ver estado
>> "%DIST%\LEEME.txt" echo   manage-service.bat start       Iniciar
>> "%DIST%\LEEME.txt" echo   manage-service.bat stop        Detener
>> "%DIST%\LEEME.txt" echo   manage-service.bat restart     Reiniciar
>> "%DIST%\LEEME.txt" echo   manage-service.bat logs        Abrir logs
>> "%DIST%\LEEME.txt" echo   manage-service.bat edit        Editar en services.msc
>> "%DIST%\LEEME.txt" echo   uninstall-service.bat          Desinstalar
>> "%DIST%\LEEME.txt" echo.
>> "%DIST%\LEEME.txt" echo OPCION 2: EJECUCION MANUAL
>> "%DIST%\LEEME.txt" echo.
>> "%DIST%\LEEME.txt" echo Ejecuta simplemente: run-printer.bat
>> "%DIST%\LEEME.txt" echo.
>> "%DIST%\LEEME.txt" echo CONFIGURACION:
>> "%DIST%\LEEME.txt" echo   C:\dist\centauro-pos-config\centauro-pos-config.properties
>> "%DIST%\LEEME.txt" echo.
>> "%DIST%\LEEME.txt" echo VERIFICAR QUE FUNCIONA:
>> "%DIST%\LEEME.txt" echo   http://localhost:9710/actuator/health
>> "%DIST%\LEEME.txt" echo   http://localhost:9710/config
>> "%DIST%\LEEME.txt" echo.
>> "%DIST%\LEEME.txt" echo PARA MAS INFORMACION:
>> "%DIST%\LEEME.txt" echo   Lee el archivo SERVICE_INSTALL.md en la raiz del proyecto
>> "%DIST%\LEEME.txt" echo   O ejecuta: guia-rapida.bat

echo [4/4] Listo.
echo Distribucion generada en: "%DIST%"
echo.
echo Archivos principales:
echo   - dist\printer-app.jar
echo   - dist\run-printer.bat
echo   - dist\config\centauro-pos-config.properties.example
echo.
echo NOTA IMPORTANTE:
if exist "%ROOT%\nssm.exe" (
echo   Se incluye nssm.exe desde la raiz del proyecto.
) else (
echo   Se usa NSSM version: 2.24-101-g897c7ad
)
echo   Si experimentas problemas, consulta: ACTUALIZACION_NSSM.md
echo.
popd >nul
exit /b 0

:fail
echo.
echo [ERROR] No se pudo generar la distribucion.
popd >nul
exit /b 1


