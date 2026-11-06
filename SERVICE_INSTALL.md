# Instalación como Servicio de Windows

## Descripción

La aplicación Centauro Printer puede ejecutarse como un servicio de Windows que se inicia automáticamente al arrancar la máquina. Esto es ideal para ambiente de producción donde quieres que la aplicación se ejecute sin intervención del usuario.

## Requisitos

- Windows 7 o superior
- Permisos de **ADMINISTRADOR** en la máquina
- Java 21 instalado (o portátil dentro de `dist\java\`)

## Pasos de Instalación

### 1. Generar la distribución

Primero, ejecuta el script de compilación desde el proyecto raíz:

```bat
build-dist.bat
```

Esto generará la carpeta `dist/` con:
- `printer-app.jar` - La aplicación
- `run-printer.bat` - Script para ejecutar la app
- `install-service.bat` - Script para instalar el servicio
- `uninstall-service.bat` - Script para desinstalar
- `manage-service.bat` - Script para gestionar el servicio

### 2. Instalar el servicio

**IMPORTANTE: Ejecuta como ADMINISTRADOR**

Abre una terminal como administrador y navega a la carpeta `dist/`:

```cmd
cd ruta\a\dist
install-service.bat
```

El script automáticamente:
1. Descargará NSSM (Non-Sucking Service Manager)
2. Creará el servicio de Windows
3. Lo configurará para inicio automático
4. Creará la carpeta de logs
5. Iniciará el servicio

### 3. Verificar que funciona

Después de la instalación, verifica que el servicio esté corriendo:

```cmd
manage-service.bat status
```

También puedes abrir el Administrador de Servicios de Windows:

```cmd
services.msc
```

Y busca "Centauro Printer Service"

## Comandos de Gestión

Usa `manage-service.bat` para controlar el servicio:

```bat
REM Ver estado
manage-service.bat status

REM Iniciar el servicio
manage-service.bat start

REM Detener el servicio
manage-service.bat stop

REM Reiniciar el servicio
manage-service.bat restart

REM Abrir carpeta de logs
manage-service.bat logs

REM Editar servicio en services.msc
manage-service.bat edit
```

## Archivo de Configuración

El archivo de configuración se crea en:

```
C:\centauro-pos-config\centauro-pos-config.properties
```

Estructura inicial:

```properties
punto_de_venta=1
cuit=20364077034
```

Puedes editarlo directamente y el servicio lo leerá al reiniciarse.

## Logs

Los logs se guardan en:

```
dist\logs\stdout.log    - Salida estándar
dist\logs\stderr.log    - Errores
```

Estos archivos se rotan automáticamente cada hora y cuando alcancen 10MB.

Abre los logs rápidamente con:

```bat
manage-service.bat logs
```

## Desinstalación

**IMPORTANTE: Ejecuta como ADMINISTRADOR**

Para desinstalar el servicio:

```cmd
uninstall-service.bat
```

Te pedirá confirmación. Escribe `SI` para confirmar.

## Verificación

Una vez instalado, puedes verificar el servicio desde:

### Línea de comandos
```cmd
manage-service.bat status
```

### Interfaz gráfica
Abre `services.msc` y busca "Centauro Printer Service"

### Via HTTP
Si está corriendo en la máquina local en puerto 9710:

```
http://localhost:9710/actuator/health
http://localhost:9710/printers
http://localhost:9710/config
```

## Solución de Problemas

### El script dice "Este script requiere permisos de ADMINISTRADOR"

- Abre `cmd.exe` como administrador
- Navega a la carpeta `dist`
- Ejecuta nuevamente el script

### El servicio no inicia

- Abre `manage-service.bat logs` para ver qué error hay
- Verifica que Java 21 esté disponible
- Asegúrate de que el puerto 9710 esté disponible

### El servicio responde por HTTP pero no imprime

La causa **más común** es que el servicio de Windows se instala con la cuenta **Sistema Local** y esa cuenta **no ve las mismas impresoras** que tu usuario de Windows.

Eso pasa mucho cuando la impresora:

- está instalada solo para tu usuario actual,
- es una impresora de red mapeada por usuario,
- es una impresora redirigida por RDP,
- o el driver requiere sesión interactiva.

#### Cómo verificarlo

1. Ejecuta la app manualmente con `run-printer.bat`
2. Consulta:

```cmd
http://localhost:9710/printers
http://localhost:9710/printers/default
http://localhost:9710/diagnostics/printing
```

3. Luego instala/inicia el servicio y vuelve a consultar los mismos endpoints.

Si cambia la lista de impresoras, la impresora default, o el usuario del proceso, el problema está en la **cuenta con la que corre el servicio**.

#### Solución recomendada

Configura el servicio para ejecutarse con un **usuario de Windows que tenga esa impresora instalada**:

1. Abre `services.msc`
2. Busca `Centauro Printer Service`
3. Click derecho → `Propiedades`
4. Pestaña `Iniciar sesión`
5. Selecciona `Esta cuenta`
6. Ingresa el usuario de Windows del cliente
7. Reinicia el servicio

#### Otras validaciones importantes

- Verifica que la impresora exista también en `Dispositivos e impresoras` para esa cuenta.
- Si usas nombre de impresora en `/print/raw`, intenta enviar siempre el nombre exacto en vez de depender de la impresora por defecto.
- Revisa el estado del servicio `Cola de impresión` de Windows.
- Si la impresora es de red, confirma que el usuario del servicio tenga acceso a esa ruta/servidor.
- Revisa `dist\logs\stdout.log` y `dist\logs\stderr.log`.

Ahora también tienes este endpoint para diagnóstico:

```cmd
http://localhost:9710/diagnostics/printing
```

Ese endpoint informa:

- usuario con el que corre Java,
- versión de Java,
- impresora por defecto,
- impresoras visibles para el proceso.

### NSSM no descarga automáticamente

- Descarga NSSM manualmente desde: https://nssm.cc/download
- Extrae el contenido en la carpeta `dist\nssm\`
- Debe quedar `dist\nssm\nssm.exe`
- Ejecuta nuevamente `install-service.bat`

### Cambiar el puerto del servicio

Edita `C:\centauro-pos-config\centauro-pos-config.properties` y agrega:

```properties
server.port=9711
```

Luego reinicia el servicio:

```cmd
manage-service.bat restart
```

## Información del Servicio

- **Nombre**: `CentauroPrinter`
- **Display Name**: `Centauro Printer Service`
- **Descripción**: `Servicio de impresion para Centauro POS`
- **Tipo de inicio**: Automático
- **Cuenta**: Sistema Local

## NSSM (Non-Sucking Service Manager)

El servicio usa NSSM porque:
- Permite ejecutar cualquier aplicación como servicio
- Reinicia automáticamente si la app falla
- Captura stdout/stderr en archivos de log
- Rota automáticamente los logs
- No requiere instalación, es portable

Más info: https://nssm.cc/

## Ejecución Manual vs Servicio

### Como servicio (recomendado para producción)

```bat
install-service.bat
REM El servicio inicia automáticamente
```

### Ejecución manual

```bat
run-printer.bat
REM Ejecuta la app en consola
REM Se cierra si cierras la ventana
```

## Variables de Entorno

El servicio hereda las variables de entorno del sistema. Si quieres usar un Java portátil:

1. Copia Java 21 en `dist\java\`
2. El script automáticamente lo detectará

O configura `JAVA_HOME` en las variables de entorno del sistema.

## Actualización de la Aplicación

Para actualizar la aplicación:

1. Detén el servicio:
   ```bat
   manage-service.bat stop
   ```

2. Compila la nueva versión:
   ```bat
   build-dist.bat
   ```

3. Copia el nuevo `printer-app.jar` a la carpeta `dist`

4. Reinicia el servicio:
   ```bat
   manage-service.bat start
   ```

O simplemente:

```bat
manage-service.bat restart
```

## Distribución al Cliente

Para distribuir al cliente:

1. Ejecuta `build-dist.bat` en tu máquina de desarrollo
2. Entrega la carpeta `dist/` completa al cliente
3. El cliente solo debe ejecutar `install-service.bat` como administrador
4. Listo, el servicio estará corriendo

El cliente **no necesita** tener Visual Studio, Maven, ni nada especial instalado.

