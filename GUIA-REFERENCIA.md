# 🎯 GUÍA DE REFERENCIA FINAL

## ¿QUÉ SE CREÓ?

### 📊 Resumen Ejecutivo

Se han creado **14 archivos nuevos** que permiten que tu aplicación Centauro Printer:

- ✅ Se instale como **servicio de Windows automático**
- ✅ Se **reinicie automáticamente** si falla
- ✅ Inicie **automáticamente** al encender Windows
- ✅ Genere **logs automáticos**
- ✅ Se **gestione fácilmente** con comandos simples
- ✅ Sea **distribuible** sin dependencias complejas

---

## 🚀 CÓMO COMENZAR (3 PASOS)

### Paso 1: Compilar (TÚ - Una vez)
```bash
cd C:\Users\Fernando\Documents\repositorios\printer
build-dist.bat
```
**Espera 3-5 minutos**. Se genera la carpeta `dist/` lista.

### Paso 2: Entregar (TÚ)
Copia la carpeta `dist/` al cliente.

### Paso 3: Cliente Instala (CLIENTE - Como ADMINISTRADOR)
```bash
cd dist
checklist-instalacion.bat
```
**¡Listo!** El servicio se ejecuta automáticamente.

---

## 📋 TABLA DE ARCHIVOS

| Archivo | Tipo | Propósito | Quién lo usa | Comando |
|---|---|---|---|---|
| **build-dist.bat** | Script | Compilar y generar dist/ | Tú | `build-dist.bat` |
| **inicio-rapido.bat** | Script | Menú interactivo principal | Tú | `inicio-rapido.bat` |
| **install-service.bat** | Script | Instalar como servicio | Cliente | `install-service.bat` |
| **uninstall-service.bat** | Script | Desinstalar servicio | Cliente | `uninstall-service.bat` |
| **manage-service.bat** | Script | Gestionar servicio | Cliente | `manage-service.bat [status/start/stop/restart/logs]` |
| **checklist-instalacion.bat** | Script | Instalación guiada | Cliente | `checklist-instalacion.bat` |
| **download-nssm.bat** | Script | Descargar NSSM manual | Cliente | `download-nssm.bat` |
| **guia-rapida.bat** | Script | Menú de ayuda | Cliente | `guia-rapida.bat` |
| **run-printer.bat** | Script | Ejecutar manualmente | Cliente | `run-printer.bat` |
| **SERVICE_INSTALL.md** | Doc | Manual detallado | Tú/Cliente | Lectura |
| **README-SERVICIO.md** | Doc | Resumen ejecutivo | Tú | Lectura |
| **INDICE-SERVICIO.md** | Doc | Índice de archivos | Tú | Lectura |
| **QUICK_REFERENCE.md** | Doc | Referencia rápida | Cliente | Lectura |
| **DEPLOY_WINDOWS.md** | Doc | Guía de distribución | Tú | Lectura |

---

## 🎯 MATRIZ DE DECISIÓN

### ¿Qué hago ahora?

```
┌─ ¿Eres DESARROLLADOR?
│  ├─ Compilar      → build-dist.bat
│  ├─ Menú rápido   → inicio-rapido.bat
│  ├─ Información   → SERVICE_INSTALL.md
│  └─ Distribuir    → Copia dist/ al cliente
│
└─ ¿Eres CLIENTE?
   ├─ Instalar          → checklist-instalacion.bat (RECOMENDADO)
   ├─ Ver estado        → manage-service.bat status
   ├─ Ayuda             → LEEME.txt o guia-rapida.bat
   └─ Desinstalar       → uninstall-service.bat
```

---

## 💻 COMANDOS RÁPIDOS

### Para Ti (DESARROLLADOR):

```bash
# Compilar y generar dist/
build-dist.bat

# Menú interactivo (si prefieres seleccionar opciones)
inicio-rapido.bat

# Ver documentación
SERVICE_INSTALL.md        (manual completo)
QUICK_REFERENCE.md        (referencia rápida)
INDICE-SERVICIO.md        (índice)
```

### Para Cliente (USUARIO FINAL):

```bash
# OPCIÓN 1: Instalación guiada (recomendado)
checklist-instalacion.bat

# OPCIÓN 2: Instalación directa
install-service.bat

# Después de instalar:
manage-service.bat status           # Ver estado
manage-service.bat logs             # Ver logs
manage-service.bat restart          # Reiniciar
manage-service.bat stop             # Detener
manage-service.bat start            # Iniciar
uninstall-service.bat               # Desinstalar

# Ayuda
guia-rapida.bat                      # Menú interactivo
LEEME.txt                            # Instrucciones
```

---

## 📊 CARACTERÍSTICAS IMPLEMENTADAS

| Característica | Implementado | Automático |
|---|---|---|
| Instalación como servicio | ✅ | ✅ |
| Descarga de NSSM | ✅ | ✅ |
| Configuración del servicio | ✅ | ✅ |
| Inicio automático con Windows | ✅ | ✅ |
| Reinicio si falla | ✅ | ✅ |
| Logs en archivos | ✅ | ✅ |
| Rotación de logs | ✅ | ✅ |
| Creación de carpeta de config | ✅ | ✅ |
| Verificación de Java | ✅ | ❌ (solo checklist) |
| Gestión desde línea de comandos | ✅ | N/A |
| Desinstalación fácil | ✅ | ❌ (requiere confirmación) |
| Documentación | ✅ | N/A |
| Menú interactivo | ✅ | N/A |

---

## 🔍 FLUJO VISUAL

```
DESARROLLADOR                        CLIENTE
┌─────────────┐                     ┌─────────────┐
│   Código    │                     │   Carpeta   │
└──────┬──────┘                     │   dist/     │
       │                            └──────┬──────┘
       │                                   │
       ↓                                   ↓
┌─────────────────────────┐    ┌──────────────────────────┐
│   build-dist.bat        │    │  checklist-instalacion   │
│  - Compila              │    │  - Verifica permisos     │
│  - Genera dist/         │    │  - Verifica Java         │
│  - Copia scripts        │    │  - Descarga NSSM         │
│  - Crea LEEME.txt       │    │  - Crea servicio         │
└──────┬──────────────────┘    │  - Lo inicia             │
       │                       └──────┬───────────────────┘
       │                              │
       ↓                              ↓
    dist/                    Servicio instalado
  (lista para                  (corriendo)
   cliente)
```

---

## ⏱️ TIEMPOS TÍPICOS

| Actividad | Tiempo | Primera vez |
|---|---|---|
| Compilación (build-dist.bat) | 3-5 min | Sí (descarga deps) |
| Compilación (cambios pequeños) | 30 seg | No |
| Instalación cliente (checklist) | 2-3 min | Sí (descarga NSSM) |
| Instalación cliente (directo) | 1-2 min | No (NSSM existe) |
| Reinicio del servicio | 5 seg | N/A |
| Ver estado | < 1 seg | N/A |

---

## 🎓 EJEMPLOS DE USO

### Ejemplo 1: Desarrollo Local

```bash
# 1. Compilar
build-dist.bat

# 2. Probar manualmente
cd dist
run-printer.bat
# Presionar Ctrl+C para detener

# 3. Probar como servicio
checklist-instalacion.bat

# 4. Verificar
manage-service.bat status
# Debe mostrar "Running"

# 5. Desinstalar después de prueba
uninstall-service.bat
```

### Ejemplo 2: Distribución al Cliente

```bash
# TÚ (en tu máquina):
build-dist.bat
# Se genera dist/

# CLIENTE (en su máquina):
# 1. Recibe carpeta dist/
# 2. Como ADMINISTRADOR:
cd dist
checklist-instalacion.bat
# El script se encarga de todo

# 3. Verificar que funciona:
manage-service.bat status
http://localhost:9710/actuator/health

# 4. Cliente puede:
# - Reiniciar: manage-service.bat restart
# - Ver logs: manage-service.bat logs
# - Detener: manage-service.bat stop (si necesita)
```

### Ejemplo 3: Actualización

```bash
# TÚ (cambios en código):
# 1. Haces los cambios
# 2. build-dist.bat
# 3. copy target\*.jar dist\printer-app.jar

# CLIENTE:
# manage-service.bat restart
```

---

## 🔐 REQUISITOS

### Para Desarrollador:
- Java 21 (para compilar)
- Maven (mvnw incluido)
- PowerShell o CMD

### Para Cliente:
- Windows 7 o superior
- Permisos de **ADMINISTRADOR** (solo para instalar)
- Internet (primera vez para descargar NSSM)
- Java 21 (o portátil en dist/java/)

---

## ✅ CHECKLIST PRE-ENTREGA

Antes de entregar al cliente:

- [ ] Compilaste: `build-dist.bat`
- [ ] Se creó carpeta `dist/`
- [ ] Probaste: `dist\run-printer.bat`
- [ ] Probaste como servicio: `dist\checklist-instalacion.bat`
- [ ] Verificaste: `manage-service.bat status` muestra "Running"
- [ ] Verificaste: `http://localhost:9710/actuator/health` responde OK
- [ ] Desinstalaste: `dist\uninstall-service.bat` (para limpiar)
- [ ] Copiaste carpeta `dist/` completa (no falta nada)

---

## 📞 SOPORTE RÁPIDO

### Problema: Permisos insuficientes
```bash
# Solución: Ejecuta como ADMINISTRADOR
# - Click derecho → "Ejecutar como administrador"
# - O: Win + X → PowerShell (Admin)
```

### Problema: Java no se encuentra
```bash
# Solución 1: Instalar Java 21
# Solución 2: Copiar Java portátil en dist\java\
# Solución 3: Configurar JAVA_HOME
```

### Problema: NSSM no descarga
```bash
# Solución: Ejecutar download-nssm.bat
# O: Descargar manualmente de https://nssm.cc/download
```

### Problema: Servicio no inicia
```bash
# Solución: Ver logs
manage-service.bat logs
# Abre dist/logs/stdout.log y stderr.log
```

---

## 🌐 ENDPOINTS HTTP

```
http://localhost:9710/actuator/health    # Health check
http://localhost:9710/config             # Configuración
http://localhost:9710/printers           # Impresoras
```

---

## 📁 UBICACIÓN DE ARCHIVOS IMPORTANTES

```
Aplicación:        dist/printer-app.jar
Configuración:     C:\centauro-pos-config\centauro-pos-config.properties
Logs:              dist/logs/stdout.log y stderr.log
NSSM:              dist/nssm/nssm.exe
Java (opcional):   dist/java/bin/java.exe
```

---

## 🎯 RESUMEN FINAL

| Aspecto | Descripción |
|---|---|
| **Archivos creados** | 14 (8 scripts + 6 documentos) |
| **Para ti (dev)** | `build-dist.bat` |
| **Para cliente** | `checklist-instalacion.bat` |
| **Instalación cliente** | ~3 minutos |
| **Complejidad cliente** | Mínima (1 comando) |
| **Mantenimiento** | Automático |
| **Confiabilidad** | Profesional |
| **Documentación** | Completa en español |

---

## 🚀 COMIENZA AHORA

```bash
# Opción 1: Menú interactivo (fácil)
inicio-rapido.bat

# Opción 2: Directo (rápido)
build-dist.bat

# Después:
# 1. Entrega dist/ al cliente
# 2. Cliente ejecuta: checklist-instalacion.bat
# 3. ¡Listo!
```

---

**¡Tu aplicación está lista para producción! 🎉**

Para más información: Consulta los archivos `.md` o ejecuta `inicio-rapido.bat`


