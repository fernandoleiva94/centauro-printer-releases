@echo off
setlocal EnableDelayedExpansion

REM Script para instalar la aplicacion Centauro Printer como servicio de Windows
REM Requiere permisos de administrador

echo.
echo ========================================
echo Instalador de Servicio - Centauro Printer
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

set "JAR_PATH=%APP_HOME%\printer-app.jar"
set "RUN_SCRIPT=%APP_HOME%\run-printer.bat"
set "CMD_EXE=%ComSpec%"
set "RUN_SCRIPT_ARGS=/c \"\"%RUN_SCRIPT%\"\""
set "ROOT_NSSM_PATH=%APP_HOME%\nssm.exe"
set "NSSM_PATH=%APP_HOME%\nssm\nssm.exe"
set "NSSM_DIR=%APP_HOME%\nssm"
set "SERVICE_NAME=CentauroPrinter"
set "SERVICE_DISPLAY=Centauro Printer Service"
set "SERVICE_DESCRIPTION=Servicio de impresion para Centauro POS"
set "SERVICE_ACCOUNT_MODE=localsystem"
set "SERVICE_USERNAME="
set "SERVICE_PASSWORD="

echo [INFO] Ruta de aplicacion: %APP_HOME%

REM Verificar si existen los archivos necesarios
if not exist "%JAR_PATH%" (
    echo [ERROR] No se encontro "%JAR_PATH%".
    echo Por favor, ejecuta "build-dist.bat" primero.
    pause
    exit /b 1
)

if not exist "%RUN_SCRIPT%" (
    echo [ERROR] No se encontro "%RUN_SCRIPT%".
    pause
    exit /b 1
)

REM Descargar NSSM si no existe
if not exist "%NSSM_PATH%" (
    call :ensureNssm
    if !ERRORLEVEL! NEQ 0 (
        pause
        exit /b 1
    )
)

if not exist "%NSSM_PATH%" (
    echo [ERROR] No se encontro NSSM en "%NSSM_PATH%".
    pause
    exit /b 1
)

REM Verificar si el servicio ya existe
"%NSSM_PATH%" status "%SERVICE_NAME%" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [INFO] El servicio "%SERVICE_NAME%" ya existe.
    echo [INFO] Se va a remover primero...
    call :removeServiceWithRetry
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] No se pudo remover completamente el servicio "%SERVICE_NAME%".
        echo Cierra services.msc si esta abierto y vuelve a intentar.
        pause
        exit /b 1
    )
)

call :waitServiceDeleted 10
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Windows aun no termina de eliminar "%SERVICE_NAME%".
    echo Espera unos segundos y vuelve a ejecutar este instalador.
    pause
    exit /b 1
)

REM Instalar el servicio
echo [INFO] Instalando servicio "%SERVICE_DISPLAY%"...
"%NSSM_PATH%" install "%SERVICE_NAME%" "%CMD_EXE%" "%RUN_SCRIPT_ARGS%"
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Fallo la instalacion del servicio.
    pause
    exit /b 1
)

REM Configurar parametros del servicio
echo [INFO] Configurando parametros del servicio...
if not exist "%APP_HOME%\logs" mkdir "%APP_HOME%\logs"
"%NSSM_PATH%" set "%SERVICE_NAME%" DisplayName "%SERVICE_DISPLAY%"
"%NSSM_PATH%" set "%SERVICE_NAME%" Description "%SERVICE_DESCRIPTION%"
"%NSSM_PATH%" set "%SERVICE_NAME%" AppDirectory "%APP_HOME%"
"%NSSM_PATH%" set "%SERVICE_NAME%" AppParameters "%RUN_SCRIPT_ARGS%"
"%NSSM_PATH%" set "%SERVICE_NAME%" AppStdout "%APP_HOME%\logs\stdout.log"
"%NSSM_PATH%" set "%SERVICE_NAME%" AppStderr "%APP_HOME%\logs\stderr.log"
"%NSSM_PATH%" set "%SERVICE_NAME%" AppRotateFiles 1
"%NSSM_PATH%" set "%SERVICE_NAME%" AppRotateOnline 1
"%NSSM_PATH%" set "%SERVICE_NAME%" AppRotateSeconds 3600
"%NSSM_PATH%" set "%SERVICE_NAME%" AppRotateBytes 10485760

echo.
echo [INFO] Cuenta del servicio
echo   1^) LocalSystem ^(recomendado solo si imprime correctamente^)
echo   2^) Usuario de Windows ^(recomendado para impresoras de usuario/red^)
set /p "ACCOUNT_CHOICE=Selecciona opcion [1/2] (default 1): "
if "%ACCOUNT_CHOICE%"=="" set "ACCOUNT_CHOICE=1"

if "%ACCOUNT_CHOICE%"=="2" (
    set "SERVICE_ACCOUNT_MODE=user"
    echo.
    echo   A^) Ingresar usuario y contrasena existentes
    echo   B^) Crear usuario dedicado "centauro-svc" automaticamente
    set /p "USER_OPT=Selecciona [A/B] (default A): "
    if "!USER_OPT!"=="" set "USER_OPT=A"

    if /I "!USER_OPT!"=="B" (
        REM Generar clave aleatoria
        for /f %%G in ('powershell -Command "[System.Guid]::NewGuid().ToString().Replace('-','').Substring(0,16) + 'Xx1!'"') do set "SVC_AUTOPSW=%%G"
        set "SERVICE_USERNAME=.\centauro-svc"
        set "SERVICE_PASSWORD=!SVC_AUTOPSW!"

        net user centauro-svc >nul 2>&1
        if !ERRORLEVEL! EQU 0 (
            echo [INFO] Usuario "centauro-svc" ya existe, actualizando contrasena...
            net user centauro-svc "!SVC_AUTOPSW!" >nul 2>&1
        ) else (
            echo [INFO] Creando usuario "centauro-svc"...
            net user centauro-svc "!SVC_AUTOPSW!" /add /comment:"Cuenta de servicio Centauro Printer" >nul 2>&1
            net localgroup "Usuarios" centauro-svc /add >nul 2>&1
        )
        if !ERRORLEVEL! NEQ 0 (
            echo [ERROR] No se pudo crear el usuario centauro-svc.
            pause
            exit /b 1
        )

        REM Otorgar permiso "Iniciar sesion como servicio"
        echo [INFO] Otorgando permiso "Log on as a service" a centauro-svc...
        powershell -Command "& {
            $sidStr = (New-Object System.Security.Principal.NTAccount('centauro-svc')).Translate([System.Security.Principal.SecurityIdentifier]).Value;
            $tmpFile = [System.IO.Path]::GetTempFileName();
            secedit /export /cfg $tmpFile | Out-Null;
            $cfg = Get-Content $tmpFile;
            $svcLine = $cfg | Select-String 'SeServiceLogonRight';
            if ($svcLine) {
                $cfg = $cfg -replace 'SeServiceLogonRight\s*=\s*(.*)', ('SeServiceLogonRight = $1,*' + $sidStr);
            } else {
                $cfg += 'SeServiceLogonRight = *' + $sidStr;
            }
            $cfg | Set-Content $tmpFile;
            secedit /configure /cfg $tmpFile /db secedit.sdb /quiet | Out-Null;
            Remove-Item $tmpFile -ErrorAction SilentlyContinue;
        }" >nul 2>&1

        echo [INFO] Usuario centauro-svc listo.
        echo.
        echo   IMPORTANTE: guarda esta clave, la vas a necesitar si reinstalal el servicio:
        echo   Usuario:    .\centauro-svc
        echo   Contrasena: !SVC_AUTOPSW!
        echo.
        echo   Ademas, necesitas instalar la impresora para este usuario.
        echo   Ingresa con ".\centauro-svc" en Windows e instala la impresora.
        echo.
        pause
    ) else (
        set /p "SERVICE_USERNAME=Usuario (ej: .\fernando o DOMINIO\usuario): "
        if "!SERVICE_USERNAME!"=="" (
            echo [ERROR] Debes indicar un usuario.
            pause
            exit /b 1
        )

        echo [INFO] Nota: si tu contrasena contiene !, puede fallar. Usa la opcion B en ese caso.
        set "SERVICE_PASSWORD="
        set /p "SERVICE_PASSWORD=Contrasena del usuario: "

        if "!SERVICE_PASSWORD!"=="" (
            echo [ERROR] Debes indicar una contrasena.
            pause
            exit /b 1
        )
    )
)

if /I "%SERVICE_ACCOUNT_MODE%"=="localsystem" (
    "%NSSM_PATH%" set "%SERVICE_NAME%" ObjectName LocalSystem
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] No se pudo configurar la cuenta LocalSystem.
        pause
        exit /b 1
    )
) else (
    "%NSSM_PATH%" set "%SERVICE_NAME%" ObjectName "%SERVICE_USERNAME%" "%SERVICE_PASSWORD%"
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] No se pudo configurar la cuenta "%SERVICE_USERNAME%".
        echo Verifica usuario/contrasena y que tenga permiso "Iniciar sesion como servicio".
        pause
        exit /b 1
    )
)


REM Configurar inicio automatico
"%NSSM_PATH%" set "%SERVICE_NAME%" Start SERVICE_AUTO_START

REM Iniciar el servicio
echo [INFO] Iniciando servicio...
"%NSSM_PATH%" start "%SERVICE_NAME%"
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] No se pudo iniciar el servicio.
    echo Intenta lo siguiente:
    echo   - Abre "Servicios" ^(services.msc^)
    echo   - Busca "%SERVICE_DISPLAY%"
    echo   - Haz click derecho y selecciona "Iniciar"
    pause
    exit /b 1
)

echo.
echo ========================================
echo [EXITO] Servicio instalado correctamente
echo ========================================
echo.
echo Informacion del servicio:
echo   Nombre: %SERVICE_NAME%
echo   Descripcion: %SERVICE_DISPLAY%
echo   Estado: En ejecucion
echo   Inicio: Automatico
if /I "%SERVICE_ACCOUNT_MODE%"=="localsystem" (
echo   Cuenta: LocalSystem
) else (
echo   Cuenta: %SERVICE_USERNAME%
)
echo.
echo Logs:
echo   %APP_HOME%\logs\stdout.log
echo   %APP_HOME%\logs\stderr.log
echo.
echo IMPORTANTE SOBRE IMPRESORAS:
echo   El servicio se instala por defecto con la cuenta del sistema.
echo   Si responde por HTTP pero no imprime, probablemente esa cuenta no ve
echo   las mismas impresoras que tu usuario.
echo   Solucion habitual:
echo     services.msc ^> %SERVICE_DISPLAY% ^> Propiedades ^> Iniciar sesion
echo     Selecciona "Esta cuenta" con un usuario que tenga la impresora instalada.
echo.
echo Comandos utiles:
echo   Ver estado:     "%NSSM_PATH%" status "%SERVICE_NAME%"
echo   Detener:        "%NSSM_PATH%" stop "%SERVICE_NAME%"
echo   Iniciar:        "%NSSM_PATH%" start "%SERVICE_NAME%"
echo   Restart:        "%NSSM_PATH%" restart "%SERVICE_NAME%"
echo.
echo O abre "servicios" ^(services.msc^) para gestionar el servicio graficamente.
echo.
pause
exit /b 0

:removeServiceWithRetry
set "REMOVE_ATTEMPT=0"
:removeRetry
set /a REMOVE_ATTEMPT+=1
echo [INFO] Removiendo servicio (intento !REMOVE_ATTEMPT!/3)...
"%NSSM_PATH%" stop "%SERVICE_NAME%" >nul 2>&1
"%NSSM_PATH%" remove "%SERVICE_NAME%" confirm >nul 2>&1

call :waitServiceDeleted 20
if !ERRORLEVEL! EQU 0 exit /b 0

if !REMOVE_ATTEMPT! GEQ 3 exit /b 1
call :sleepSeconds 3
goto removeRetry

:waitServiceDeleted
set "WAIT_SECONDS=%~1"
if "%WAIT_SECONDS%"=="" set "WAIT_SECONDS=15"
set "WAIT_COUNTER=0"
:waitDeleteLoop
sc query "%SERVICE_NAME%" >nul 2>&1
if !ERRORLEVEL! EQU 1060 exit /b 0
if !WAIT_COUNTER! EQU 0 echo [INFO] Esperando a que Windows termine de eliminar el servicio...
if !WAIT_COUNTER! GEQ !WAIT_SECONDS! exit /b 1
call :sleepSeconds 1
set /a WAIT_COUNTER+=1
goto waitDeleteLoop

:sleepSeconds
set "SLEEP_FOR=%~1"
if "%SLEEP_FOR%"=="" set "SLEEP_FOR=1"
timeout /t %SLEEP_FOR% /nobreak >nul
exit /b 0

:ensureNssm
set "NSSM_URL1=https://nssm.cc/download/nssm-2.24-101-g897c7ad.zip"
set "NSSM_URL2=https://github.com/nssm-cc/nssm/releases/download/2.24-101-g897c7ad/nssm-2.24-101-g897c7ad.zip"
set "NSSM_ZIP=%APP_HOME%\nssm-download.zip"
set "NSSM_EXTRACT=%TEMP%\centauro-nssm-%RANDOM%-%RANDOM%"
set "LOCAL_NSSM_ZIP="
set "FOUND_NSSM="

if not exist "%NSSM_DIR%" mkdir "%NSSM_DIR%"

if exist "%ROOT_NSSM_PATH%" (
    copy /Y "%ROOT_NSSM_PATH%" "%NSSM_PATH%" >nul 2>&1
    if exist "%NSSM_PATH%" (
        echo [INFO] NSSM encontrado en la raiz: %ROOT_NSSM_PATH%
        exit /b 0
    )
)

call :locateNssm "%APP_HOME%"
if defined FOUND_NSSM (
    copy /Y "%FOUND_NSSM%" "%NSSM_PATH%" >nul 2>&1
    if exist "%NSSM_PATH%" (
        echo [INFO] NSSM encontrado localmente en: %FOUND_NSSM%
        exit /b 0
    )
)

for %%F in ("%APP_HOME%\nssm*.zip") do (
    if exist "%%~fF" if not defined LOCAL_NSSM_ZIP set "LOCAL_NSSM_ZIP=%%~fF"
)

if exist "%NSSM_ZIP%" del /f /q "%NSSM_ZIP%" >nul 2>&1
if exist "%NSSM_EXTRACT%" rmdir /s /q "%NSSM_EXTRACT%" >nul 2>&1
mkdir "%NSSM_EXTRACT%" >nul 2>&1

if defined LOCAL_NSSM_ZIP (
    echo [INFO] Usando ZIP local de NSSM: %LOCAL_NSSM_ZIP%
    copy /Y "%LOCAL_NSSM_ZIP%" "%NSSM_ZIP%" >nul 2>&1
) else (
    echo [INFO] Descargando NSSM...
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $ProgressPreference = 'SilentlyContinue'; try { Invoke-WebRequest -UseBasicParsing -Uri '%NSSM_URL1%' -OutFile '%NSSM_ZIP%' -ErrorAction Stop; exit 0 } catch { try { Invoke-WebRequest -UseBasicParsing -Uri '%NSSM_URL2%' -OutFile '%NSSM_ZIP%' -ErrorAction Stop; exit 0 } catch { exit 1 } }}" >nul 2>&1
    if !ERRORLEVEL! NEQ 0 (
        where curl.exe >nul 2>nul
        if !ERRORLEVEL! EQU 0 (
            curl.exe -L "%NSSM_URL1%" -o "%NSSM_ZIP%" >nul 2>&1
            if not exist "%NSSM_ZIP%" curl.exe -L "%NSSM_URL2%" -o "%NSSM_ZIP%" >nul 2>&1
        )
    )
    if not exist "%NSSM_ZIP%" (
        echo [ERROR] No se pudo descargar NSSM automaticamente.
        echo URL principal: %NSSM_URL1%
        echo URL alternativa: %NSSM_URL2%
        echo.
        echo Opciones manuales:
        echo   1. Copia un archivo ZIP de NSSM en esta carpeta: %APP_HOME%
        echo   2. O copia directamente nssm.exe en: %NSSM_PATH%
        exit /b 1
    )
)

if not exist "%NSSM_ZIP%" (
    echo [ERROR] La descarga de NSSM no genero el archivo ZIP esperado.
    exit /b 1
)

for %%I in ("%NSSM_ZIP%") do set "NSSM_ZIP_SIZE=%%~zI"
if "%NSSM_ZIP_SIZE%"=="0" (
    echo [ERROR] El ZIP descargado de NSSM esta vacio.
    exit /b 1
)

echo [INFO] Descomprimiendo NSSM...
powershell -Command "& {Expand-Archive -Path '%NSSM_ZIP%' -DestinationPath '%NSSM_EXTRACT%' -Force}" >nul 2>&1
if !ERRORLEVEL! NEQ 0 (
    echo [ERROR] No se pudo descomprimir NSSM.
    echo ZIP: %NSSM_ZIP%
    exit /b 1
)

call :locateNssm "%NSSM_EXTRACT%"
if not defined FOUND_NSSM (
    call :locateNssm "%APP_HOME%"
)

if not defined FOUND_NSSM (
    echo [ERROR] No se encontro nssm.exe despues de extraer.
    echo Carpeta temporal: %NSSM_EXTRACT%
    echo Copia manualmente el archivo en: %NSSM_PATH%
    exit /b 1
)

copy /Y "%FOUND_NSSM%" "%NSSM_PATH%" >nul 2>&1
if !ERRORLEVEL! NEQ 0 (
    echo [ERROR] Se encontro NSSM pero no se pudo copiar.
    echo Origen: %FOUND_NSSM%
    echo Destino: %NSSM_PATH%
    exit /b 1
)

if exist "%NSSM_ZIP%" del /f /q "%NSSM_ZIP%" >nul 2>&1
if exist "%NSSM_EXTRACT%" rmdir /s /q "%NSSM_EXTRACT%" >nul 2>&1
echo [INFO] NSSM listo en: %NSSM_PATH%
exit /b 0

:locateNssm
if not defined FOUND_NSSM (
    for /f "delims=" %%F in ('dir /b /s "%~1\win64\nssm.exe" 2^>nul') do (
        if not defined FOUND_NSSM set "FOUND_NSSM=%%F"
    )
)
if not defined FOUND_NSSM (
    for /f "delims=" %%F in ('dir /b /s "%~1\win32\nssm.exe" 2^>nul') do (
        if not defined FOUND_NSSM set "FOUND_NSSM=%%F"
    )
)
if not defined FOUND_NSSM (
    for /f "delims=" %%F in ('dir /b /s "%~1\nssm.exe" 2^>nul') do (
        if not defined FOUND_NSSM if /I not "%%~fF"=="%NSSM_PATH%" set "FOUND_NSSM=%%F"
    )
)
exit /b 0

