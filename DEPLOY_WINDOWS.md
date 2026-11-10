# Distribución Windows con `.bat`

## Archivos agregados
- `build-dist.bat`: compila el proyecto y genera la carpeta `dist/`
- `run-printer.bat`: inicia la aplicación manualmente
- `install-service.bat`: instala la app como servicio de Windows
- `uninstall-service.bat`: desinstala el servicio
- `manage-service.bat`: gestiona el servicio (start, stop, status, etc.)
- `download-nssm.bat`: descarga NSSM si falla la descarga automática

## Qué genera `build-dist.bat`
La carpeta `dist/` con:
- `printer-app.jar`
- `run-printer.bat`
- `install-service.bat`
- `uninstall-service.bat`
- `manage-service.bat`
- `config/centauro-pos-config.properties.example`
- `java/README.txt` (para runtime portátil)

## Compilación
Desde la raíz del proyecto:

```bat
build-dist.bat
```

Luego entregar al cliente la carpeta `dist/`.

## Ejecución Manual
`run-printer.bat` busca Java en este orden:
1. `dist\java\bin\java.exe` (si existe)
2. `JAVA_HOME\bin\java.exe`
3. `java` disponible en `PATH`

```bat
run-printer.bat
REM o con ruta de config personalizada:
run-printer.bat C:\ruta\mi-config.properties
```

## Instalación como Servicio de Windows (RECOMENDADO PARA PRODUCCION)

### Paso 1: Instalar
Ejecuta como **ADMINISTRADOR**:

```bat
install-service.bat
```

Esto:
1. Descarga NSSM automáticamente
2. Crea el servicio "CentauroPrinter"
3. Lo configura para inicio automático
4. Inicia el servicio

### Paso 2: Gestionar
```bat
manage-service.bat status      REM Ver estado
manage-service.bat start       REM Iniciar
manage-service.bat stop        REM Detener
manage-service.bat restart     REM Reiniciar
manage-service.bat logs        REM Abrir logs
manage-service.bat edit        REM Editar en services.msc
```

### Paso 3: Desinstalar (cuando sea necesario)
Ejecuta como **ADMINISTRADOR**:

```bat
uninstall-service.bat
```

## Configuración
El archivo de configuración se crea automáticamente en:

```text
C:\centauro-pos-config\centauro-pos-config.properties
```

Contenido inicial:

```properties
punto_de_venta=1
cuit=20364077034
```

Puedes editarlo en cualquier momento. Se recarga al reiniciar el servicio.

## Java Portátil
Si no quieres depender de una instalación global de Java, copia un runtime de Java 21 en:

```text
dist\java\bin\java.exe
```

Ambos scripts (`run-printer.bat` e `install-service.bat`) lo detectarán automáticamente.

## Logs
Si instalas como servicio, los logs se guardan en:

```
dist\logs\stdout.log    REM Salida estándar
dist\logs\stderr.log    REM Errores
```

Se rotan automáticamente cada hora o cuando alcanzan 10MB.

Para ver los logs rápidamente:

```bat
manage-service.bat logs
```

## Verificación

### Vía HTTP
```
http://localhost:9710/actuator/health
http://localhost:9710/printers
http://localhost:9710/config
```

### Línea de comandos
```bat
manage-service.bat status
```

### Interfaz gráfica
Abre `services.msc` y busca "Centauro Printer Service"

## Comparación: Manual vs Servicio

| Característica | Manual | Servicio |
|---|---|---|
| Inicio automático | ❌ | ✅ |
| Reinicio automático si falla | ❌ | ✅ |
| Logs automáticos | ❌ | ✅ |
| Requiere ventana abierta | ✅ | ❌ |
| Ideal para desarrollo | ✅ | ❌ |
| Ideal para producción | ❌ | ✅ |

## Solución de Problemas

### NSSM no descarga automáticamente
Ejecuta manualmente:
```bat
download-nssm.bat
```

O descarga desde: https://nssm.cc/download

### "Este script requiere permisos de ADMINISTRADOR"
- Abre `cmd` como administrador
- Navega a la carpeta `dist`
- Ejecuta el script nuevamente

### El servicio no inicia
Verifica los logs:
```bat
manage-service.bat logs
```

### Cambiar el puerto
Edita `C:\centauro-pos-config\centauro-pos-config.properties` y agrega:
```properties
server.port=9711
```

Luego:
```bat
manage-service.bat restart
```

## Para el Cliente Final

1. Recibe la carpeta `dist/` completa
2. Ejecuta como administrador: `install-service.bat`
3. Listo, el servicio está corriendo
4. El servicio se reinicia automáticamente cada vez que encienda la máquina
5. Gestiona con `manage-service.bat` según sea necesario

No necesita:
- Visual Studio
- Maven
- Git
- Conocimientos técnicos
- Ventana abierta permanentemente

