# CENTAURO PRINTER - SERVICIO DE WINDOWS

## Resumen Rápido

Para instalar la aplicación como servicio de Windows:

1. **Compilar el proyecto:**
   ```bat
   build-dist.bat
   ```

2. **Entregar al cliente:** La carpeta `dist/` completa

3. **Cliente ejecuta como ADMINISTRADOR:**
   ```bat
   cd dist
   install-service.bat
   ```

4. **Listo:** El servicio está corriendo automáticamente

## Archivos Principales

### Scripts de Instalación
- **`install-service.bat`** - Instala el servicio (requiere admin)
- **`uninstall-service.bat`** - Desinstala el servicio (requiere admin)
- **`manage-service.bat`** - Gestiona el servicio (status, start, stop, etc.)
- **`download-nssm.bat`** - Descarga NSSM manualmente si falla

### Scripts de Ejecución
- **`run-printer.bat`** - Ejecuta la aplicación manualmente
- **`guia-rapida.bat`** - Menú interactivo de ayuda

### Distribución
- **`build-dist.bat`** - Genera la carpeta `dist/` con todo necesario

### Documentación
- **`SERVICE_INSTALL.md`** - Documentación detallada
- **`DEPLOY_WINDOWS.md`** - Guía de distribución
- **`LEEME.txt`** (en dist) - Instrucciones para el cliente

## Flujo de Trabajo

### Desarrollo
```bash
# Compilar y probar localmente
build-dist.bat

# Ejecutar manualmente
run-printer.bat

# Probar como servicio
cd dist
install-service.bat
manage-service.bat status
```

### Distribución
```
1. Ejecuta: build-dist.bat
2. Entrega: carpeta dist/
3. Cliente ejecuta: install-service.bat
4. Listo
```

## Gestión del Servicio

```bat
# Ver estado
manage-service.bat status

# Iniciar
manage-service.bat start

# Detener
manage-service.bat stop

# Reiniciar
manage-service.bat restart

# Ver logs
manage-service.bat logs

# Editar en services.msc
manage-service.bat edit

# Desinstalar
uninstall-service.bat
```

## Configuración

Ubicación: `C:\centauro-pos-config\centauro-pos-config.properties`

```properties
punto_de_venta=1
cuit=20364077034
```

Se recarga al reiniciar el servicio.

## Logs

```
dist\logs\stdout.log   - Salida estándar
dist\logs\stderr.log   - Errores
```

Se rotan automáticamente cada hora y al alcanzar 10MB.

## Verificación

```
http://localhost:9710/actuator/health
http://localhost:9710/config
http://localhost:9710/printers
```

## Soporte Técnico

### Si no arranca
1. Verifica los logs: `manage-service.bat logs`
2. Abre `services.msc` y busca "Centauro Printer Service"
3. Verifica que Java 21 esté disponible

### Si NSSM no descarga
Ejecuta manualmente: `download-nssm.bat`

### Cambiar puerto
En `C:\centauro-pos-config\centauro-pos-config.properties` agrega:
```properties
server.port=9711
```

Luego: `manage-service.bat restart`

## Actualización

```bat
# Detener
manage-service.bat stop

# Recompilar
build-dist.bat

# Copiar nuevo jar a dist
copy target\*.jar dist\printer-app.jar

# Reiniciar
manage-service.bat start
```

## Comparación: Manual vs Servicio

| | Manual | Servicio |
|-|--------|---------|
| Inicio automático | ❌ | ✅ |
| Reinicio automático | ❌ | ✅ |
| Logs automáticos | ❌ | ✅ |
| Requiere ventana abierta | ✅ | ❌ |
| Mejor para desarrollo | ✅ | ❌ |
| Mejor para producción | ❌ | ✅ |

## Tecnología

- **NSSM** (Non-Sucking Service Manager) - Envolvente de servicio
- **Spring Boot 3.5.5** - Framework Java
- **Java 21** - Runtime

## Requisitos

- Windows 7+
- Permisos de administrador (para instalar/desinstalar)
- Java 21 (o portátil en `dist\java\`)

## Para el Cliente Final

1. Recibe carpeta `dist/`
2. Click derecho en carpeta → "Abrir PowerShell como administrador"
3. Ejecuta: `install-service.bat`
4. El servicio se reinicia automáticamente cada vez que inicia Windows
5. Gestiona con: `manage-service.bat`

**No requiere Visual Studio, Maven, Git ni conocimientos técnicos.**

## Información del Servicio

- **Nombre interno:** `CentauroPrinter`
- **Nombre visible:** `Centauro Printer Service`
- **Descripción:** `Servicio de impresion para Centauro POS`
- **Tipo de inicio:** Automático
- **Cuenta:** Sistema Local
- **Puerto:** 9710 (configurable)

## Reinicio Automático

Si la aplicación se detiene por cualquier razón, NSSM la reiniciará automáticamente cada 1500 milisegundos (~1.5 segundos).

## Para Más Información

Ver archivos:
- `SERVICE_INSTALL.md`
- `DEPLOY_WINDOWS.md`
- O ejecuta: `guia-rapida.bat`

