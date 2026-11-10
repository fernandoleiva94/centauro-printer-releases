# REFERENCIA RÁPIDA - SERVICIO WINDOWS

## ⚡ COMANDOS ESENCIALES

### Compilar
```bash
build-dist.bat
```

### Instalar Servicio
```bash
checklist-instalacion.bat     # Con verificación (recomendado)
install-service.bat           # Directo
```

### Gestionar
```bash
manage-service.bat status     # Ver estado
manage-service.bat start      # Iniciar
manage-service.bat stop       # Detener
manage-service.bat restart    # Reiniciar
manage-service.bat logs       # Ver logs
manage-service.bat edit       # Editar servicio
```

### Ejecutar Manual
```bash
run-printer.bat               # Sin servicio
```

### Desinstalar
```bash
uninstall-service.bat         # Con confirmación
```

---

## 📁 ARCHIVO DE CONFIGURACIÓN

**Ubicación:**
```
C:\centauro-pos-config\centauro-pos-config.properties
```

**Contenido Inicial:**
```properties
punto_de_venta=1
cuit=20364077034
```

**Para cambiar puerto:**
```properties
server.port=9711
```

---

## 🔗 ENDPOINTS

```
http://localhost:9710/actuator/health    # Health check
http://localhost:9710/config             # Configuración
http://localhost:9710/printers           # Impresoras
```

---

## 📂 ESTRUCTURA DIST

```
dist/
├── printer-app.jar
├── checklist-instalacion.bat
├── install-service.bat
├── uninstall-service.bat
├── manage-service.bat
├── run-printer.bat
├── guia-rapida.bat
├── download-nssm.bat
├── LEEME.txt
├── config/
├── java/
└── logs/
```

---

## 🆘 PROBLEMAS COMUNES

| Problema | Solución |
|---|---|
| Permisos insuficientes | Ejecuta como ADMINISTRADOR |
| Java no se encuentra | Instala Java 21 o copia en `dist\java\` |
| NSSM no descarga | Ejecuta `download-nssm.bat` |
| Servicio no inicia | Revisa `manage-service.bat logs` |
| Puerto ocupado | Cambia puerto en properties y reinicia |

---

## 📊 INFORMACIÓN DEL SERVICIO

```
Nombre:     CentauroPrinter
Display:    Centauro Printer Service
Descripción Servicio de impresion para Centauro POS
Tipo:       Automático
Cuenta:     Sistema Local
Puerto:     9710
Java:       21
NSSM:       Descargado automáticamente
```

---

## ✅ CHECKLIST INSTALACIÓN

- [ ] Ejecutar como ADMINISTRADOR
- [ ] `checklist-instalacion.bat`
- [ ] Responder preguntas
- [ ] Ver: "Instalación completada"
- [ ] Verificar: `manage-service.bat status`
- [ ] Probar: `http://localhost:9710/actuator/health`

---

## 📖 DOCUMENTACIÓN

| Documento | Propósito |
|---|---|
| SERVICE_INSTALL.md | Manual completo |
| README-SERVICIO.md | Resumen ejecutivo |
| INDICE-SERVICIO.md | Índice de archivos |
| DEPLOY_WINDOWS.md | Guía de distribución |
| RESUMEN_FINAL.md | Resumen visual |
| LEEME.txt (dist/) | Para cliente |

---

## 🚀 FLUJO TÍPICO

```
1. Compilar:    build-dist.bat
2. Entregar:    Copia dist/ al cliente
3. Instalar:    Cliente ejecuta checklist-instalacion.bat
4. Usar:        manage-service.bat [comando]
5. Monitoreo:   manage-service.bat logs
6. Actualizar:  build-dist.bat → copiar jar → restart
```

---

## 💾 LOCALIZACIÓN DE ARCHIVOS IMPORTANTES

```
Aplicación:     dist/printer-app.jar
Configuración:  C:\centauro-pos-config\
Logs:           dist/logs/
NSSM:           dist/nssm/nssm.exe
Java:           dist/java/ (opcional)
```

---

## 🔐 CREDENCIALES Y ACCESO

```
Cuenta de Servicio:     SISTEMA LOCAL
Permisos Requeridos:    ADMINISTRADOR (solo instalación)
Acceso HTTP:            http://localhost:9710
Puerto:                 9710 (configurable)
```

---

## ⏰ TIEMPOS TÍPICOS

```
Compilación:        3-5 minutos (primera vez)
Compilación:        30 segundos (cambios pequeños)
Instalación:        1-2 minutos
Reinicio:           5 segundos
```

---

## 🎯 PUNTOS CLAVE

✅ **Para Desarrollador**: `build-dist.bat` (todo automático)
✅ **Para Cliente**: `checklist-instalacion.bat` (todo automático)
✅ **Confiabilidad**: Reinicio automático
✅ **Logs**: Automáticos y rotados
✅ **Documentación**: Completa en español

---

## 🔄 ACTUALIZAR LA APLICACIÓN

```bash
# 1. Cambios en código
# 2. build-dist.bat
# 3. copy target\*.jar dist\printer-app.jar
# 4. manage-service.bat restart
```

---

## 📞 SOPORTE

- Ver logs: `manage-service.bat logs`
- Manual: `SERVICE_INSTALL.md`
- Índice: `INDICE-SERVICIO.md`
- Resumen: `README-SERVICIO.md`

---

## 🌍 VARIABLES DE ENTORNO

```
JAVA_HOME       Java location (opcional)
PATH            Debe incluir java (opcional)
```

---

**Última actualización**: 2026-04-13
**Versión**: 1.0
**Estado**: ✅ Producción lista

