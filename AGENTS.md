# Centauro Printer

## Propósito

Agente local de Windows que corre en la PC del comercio. El front (centauro-pos-front)
le habla por HTTP en `http://localhost:9710`.

Responsabilidades:
- listar impresoras instaladas en Windows e imprimir bytes ESC/POS crudos
- guardar la config de la terminal (`terminal_code`, `punto_de_venta`, `tenant_cuit`)
- guardar la config de balanzas

NO implementar lógica de negocio del POS. NO hablar con el backend.

## Stack

Java 21, Spring Boot 3.5.5, Maven (wrapper incluido), `javax.print`.
Artefacto `com.agent:printer`, paquete `com.agent.printer`.

## Endpoints

| Ruta | Qué hace |
|---|---|
| `GET /agent/info` | nombre, versión, uptime, ruta de config |
| `GET /actuator/health` | salud (única ruta de actuator expuesta) |
| `GET /printers`, `/printers/default`, `/diagnostics/printing` | impresoras |
| `POST /print/raw`, `POST /print/test` | impresión |
| `GET/PUT /config` | config de terminal |
| `/config/scales` | balanzas |

## Seguridad

- Escucha solo en `127.0.0.1` (`server.address`).
- `LocalAccessFilter` rechaza con 403 un `Host` que no sea localhost/127.0.0.1/[::1]
  (DNS rebinding) y un `Origin` que no esté en `allowed.origins`.
- `allowed.origins` (`ALLOWED_ORIGINS`, separados por coma, admite `https://*.dominio.com`).
  `ALLOWED_ORIGIN` (singular) sigue funcionando por compatibilidad.
  El default incluye `https://*.netlify.app`: ajustarlo cuando el dominio del front sea definitivo.
- `PRINT_TOKEN` es opcional y solo protege `/print/**`. `VITE_PRINT_TOKEN` queda en el bundle
  público: no es un secreto.

## Datos locales

Directorio: `agent.home` = `CENTAURO_PRINTER_HOME` o `%LOCALAPPDATA%\CentauroPrinter`.
Contiene `centauro-pos-config.properties`, `scale-configs.json` y `logs/printer.log`
(rotación diaria, 10 MB, 14 días, tope 100 MB).
`LegacyConfigMigrator` copia, una sola vez, la config de `C:\dist\centauro-pos-config` y
`C:\centauro-pos-config` (convierte `cuit` en `tenant_cuit`) y no borra el origen.

## Ejecución

Puerto `PRINTER_PORT` (default 9710). Si ya está ocupado, el proceso sale con código 10
sin error (ya hay otra instancia).

## Distribución

Los `.bat` y `.md` de NSSM/servicio son el mecanismo anterior y están por reemplazarse por un
instalador por usuario (jlink + jpackage + Inno Setup, autostart HKCU, releases en GitHub).
No agregar nada nuevo sobre NSSM.

## Validación

```
.\mvnw.cmd test
.\mvnw.cmd -DskipTests package
```

Al tocar CORS, filtros o rutas de config, ampliar `LocalAccessFilterTest`,
`AgentEndpointsTest` o `LegacyConfigMigratorTest`.

## Git

`dist.zip`, `nssm.exe`, `nssm/`, `target/` y logs están ignorados. Nada se commitea a `main`:
rama feature, tests, commit y PR.
