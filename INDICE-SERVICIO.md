# GUÍA DE SERVICIO WINDOWS - ÍNDICE COMPLETO

## 📌 RESUMEN EJECUTIVO

Tu aplicación **Centauro Printer** está completamente configurada para instalarse como **servicio de Windows automático**. 

El cliente solo necesita:
1. Recibir la carpeta `dist/`
2. Ejecutar: `checklist-instalacion.bat`
3. ¡Listo! El servicio se ejecuta automáticamente

## 🗂️ ARCHIVOS DISPONIBLES

### En el Proyecto Raíz:

#### Scripts de Compilación
- **`build-dist.bat`** - Compila el proyecto y genera la distribución
  - Genera carpeta `dist/` lista para entregar al cliente
  - Incluye todos los scripts necesarios

#### Scripts de Instalación (para desarrollador)
- **`install-service.bat`** - Instala como servicio
- **`uninstall-service.bat`** - Desinstala el servicio
- **`manage-service.bat`** - Gestiona el servicio
- **`download-nssm.bat`** - Descarga NSSM manualmente
- **`guia-rapida.bat`** - Menú interactivo de ayuda
- **`checklist-instalacion.bat`** - Verificación paso a paso para cliente

#### Scripts de Ejecución
- **`run-printer.bat`** - Ejecuta la app manualmente (sin servicio)

#### Documentación
- **`SERVICE_INSTALL.md`** - Manual completo y detallado
  - Instrucciones paso a paso
  - Solución de problemas
  - Configuración avanzada

- **`README-SERVICIO.md`** - Resumen ejecutivo
  - Guía rápida
  - Comandos principales
  - Información técnica

- **`DEPLOY_WINDOWS.md`** - Guía de distribución (actualizado)
  - Cómo compilar
  - Cómo entregar al cliente
  - Características del servicio

- **`HELP.md`** - Ayuda general del proyecto

### En la Carpeta `dist/` (después de compilar):

#### Aplicación
- **`printer-app.jar`** - Aplicación compilada ejecutable

#### Scripts para Cliente
- **`checklist-instalacion.bat`** - Instalación guiada (COMIENZA AQUÍ)
- **`install-service.bat`** - Instala el servicio
- **`uninstall-service.bat`** - Desinstala el servicio
- **`manage-service.bat`** - Gestiona el servicio
- **`run-printer.bat`** - Ejecución manual (alternativa)
- **`download-nssm.bat`** - Descarga manual de NSSM
- **`guia-rapida.bat`** - Menú interactivo

#### Configuración
- **`config/centauro-pos-config.properties.example`** - Ejemplo de config
- **`java/README.txt`** - Para Java portátil (opcional)

#### Instrucciones
- **`LEEME.txt`** - Instrucciones principales para el cliente

#### Logs (se crean automáticamente)
- **`logs/stdout.log`** - Salida estándar del servicio
- **`logs/stderr.log`** - Errores del servicio

## 🚀 FLUJO DE TRABAJO

### Para el Desarrollador (TÚ):

```bash
# 1. Compilar
build-dist.bat

# 2. Verificar que se generó dist/
# 3. Hacer cambios en el código si es necesario
# 4. Recompilar con: build-dist.bat

# Para probar localmente:
dist\run-printer.bat                    # Ejecución manual
# O
dist\install-service.bat               # Instalar como servicio
```

### Para el Cliente Final:

```bash
# 1. Recibe la carpeta dist/
# 2. Ejecuta:
cd dist
checklist-instalacion.bat               # Verificación guiada
# 3. O si prefiere directo:
install-service.bat                     # Instala el servicio
```

## 📊 MATRIZ DE DECISIÓN

### ¿Quieres ejecutar la app?

```
┌─ ¿Necesitas que sea un servicio?
│
├─ SÍ (Recomendado para Producción)
│  └─ Ejecuta: install-service.bat
│     └─ Se reinicia automáticamente
│     └─ Inicia con Windows
│     └─ Sin ventana visible
│
└─ NO (Para desarrollo/pruebas)
   └─ Ejecuta: run-printer.bat
      └─ Ves la salida en consola
      └─ Se cierra al cerrar ventana
```

### ¿Necesitas gestionar el servicio?

```
┌─ Ver estado: manage-service.bat status
├─ Iniciar: manage-service.bat start
├─ Detener: manage-service.bat stop
├─ Reiniciar: manage-service.bat restart
├─ Ver logs: manage-service.bat logs
├─ Editar: manage-service.bat edit
└─ Desinstalar: uninstall-service.bat
```

## 🎯 QUICK START

### Paso 1: Compilar (en tu máquina)
```bash
cd C:\Users\Fernando\Documents\repositorios\printer
build-dist.bat
```

Espera a que termine. Esto genera `dist/`.

### Paso 2: Entregar (al cliente)
```bash
# Copia la carpeta dist/ a la máquina del cliente
# Por ejemplo: C:\Program Files\CentauroPrinter\
```

### Paso 3: Cliente Instala
```bash
# Como ADMINISTRADOR:
cd C:\Program Files\CentauroPrinter\
checklist-instalacion.bat

# O directamente:
install-service.bat
```

### Paso 4: Verificar
```bash
# En la misma carpeta:
manage-service.bat status

# En el navegador:
http://localhost:9710/actuator/health
```

## 📋 CHECKLIST ANTES DE ENTREGAR

- [ ] Ejecutaste `build-dist.bat`
- [ ] Verificaste que se creó la carpeta `dist/`
- [ ] Probaste localmente: `dist\run-printer.bat`
- [ ] Probaste como servicio: `dist\install-service.bat`
- [ ] Verificaste `http://localhost:9710/actuator/health`
- [ ] Desinstalaste para pruebas: `dist\uninstall-service.bat`
- [ ] Copias la carpeta `dist/` completa al cliente
- [ ] El cliente ejecuta: `checklist-instalacion.bat`

## 🔧 CONFIGURACIÓN

### Cliente
El archivo se crea automáticamente en:
```
C:\centauro-pos-config\centauro-pos-config.properties
```

Contenido:
```properties
punto_de_venta=1
cuit=20364077034
```

El cliente puede editarlo y el servicio lo leerá al reiniciarse.

### Cambiar Puerto
En el archivo de configuración:
```properties
server.port=9711
```

Luego reiniciar el servicio.

## 🐛 SOLUCIÓN DE PROBLEMAS

### "El servicio no inicia"
```bash
manage-service.bat logs
# Abre los archivos stdout.log y stderr.log
```

### "Java no se encuentra"
```bash
# Opción 1: Instalar Java 21 globalmente
# Opción 2: Copiar Java portable en: dist\java\
# Opción 3: Configurar JAVA_HOME
```

### "NSSM no descarga"
```bash
download-nssm.bat
# O descargar manualmente desde https://nssm.cc/download
```

### "Permisos insuficientes"
```bash
# Abre PowerShell como ADMINISTRADOR
# Navega a la carpeta dist
# Ejecuta los scripts nuevamente
```

## 📞 DOCUMENTACIÓN POR TEMA

### Quiero instalar el servicio
→ Lee: `SERVICE_INSTALL.md`

### Necesito un resumen rápido
→ Lee: `README-SERVICIO.md`

### Voy a distribuir al cliente
→ Lee: `DEPLOY_WINDOWS.md`

### Busco referencias rápidas
→ Consulta: `HELP.md`

### Soy el cliente y necesito ayuda
→ Lee: `LEEME.txt` (en dist/)

## 💡 TIPS Y TRUCOS

### Para ejecutar en desarrollo
```bash
run-printer.bat
# O pasar un archivo de config personalizado:
run-printer.bat C:\mi-config.properties
```

### Para ejecutar como servicio en desarrollo
```bash
install-service.bat
manage-service.bat status
manage-service.bat logs
manage-service.bat restart
```

### Para actualizar la aplicación
```bash
# 1. Hacer cambios en el código
# 2. Compilar: build-dist.bat
# 3. Copiar nuevo jar a dist/: copy target\*.jar dist\printer-app.jar
# 4. Reiniciar: manage-service.bat restart
```

### Para ver logs en tiempo real
```bash
manage-service.bat logs
# Se abre la carpeta de logs
# Abre stdout.log con un editor
```

### Para cambiar Java
```bash
# Opción 1: Copia Java 21 portable en: dist\java\bin\java.exe
# Opción 2: Configura JAVA_HOME en variables de entorno
# Opción 3: Agrega java al PATH
```

## 🌐 PUERTOS Y ENDPOINTS

### Puerto por defecto
```
9710
```

### Health Check
```
http://localhost:9710/actuator/health
```

### Config
```
http://localhost:9710/config
```

### Printers
```
http://localhost:9710/printers
```

## 🎓 PARA EL CLIENTE FINAL

### El cliente NO necesita:
- ❌ Visual Studio
- ❌ Maven
- ❌ Git
- ❌ Conocimientos técnicos
- ❌ Dejar ventana abierta

### El cliente SOLO necesita:
- ✅ La carpeta `dist/`
- ✅ Ejecutar `checklist-instalacion.bat` como ADMINISTRADOR
- ✅ Responder las preguntas (o ejecutar `install-service.bat` directamente)

## 🔐 INFORMACIÓN DEL SERVICIO

```
Nombre: CentauroPrinter
Display Name: Centauro Printer Service
Descripción: Servicio de impresion para Centauro POS
Tipo: Automático
Cuenta: Sistema Local
Puerto: 9710 (configurable)
```

## 📈 ESTADÍSTICAS

- Archivos creados: 7 scripts + 4 documentos
- Líneas de código: ~500 líneas de scripts
- Archivos de configuración: 1 (properties)
- Dependencia externa: NSSM (descargado automáticamente)
- Tiempo de instalación: <5 minutos

## ✨ CARACTERÍSTICAS

✅ Instalación automática de NSSM
✅ Descarga automática de dependencias
✅ Logs automáticos con rotación
✅ Reinicio automático si falla
✅ Inicio automático con Windows
✅ Fácil desinstalación
✅ Menú interactivo
✅ Documentación completa
✅ Soporte para Java portátil
✅ Compatible Windows 7+

---

**¡Tu aplicación está lista para ser un servicio profesional de Windows!**

Para comenzar: `build-dist.bat`
Para entregar: carpeta `dist/`
Para instalar: `checklist-instalacion.bat` (cliente)

