package com.agent.printer.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.nio.file.Path;

/**
 * Resuelve dónde guarda el agente su configuración.
 *
 * Por defecto: %LOCALAPPDATA%\CentauroPrinter (instalación por usuario, sin admin).
 * Se puede forzar con CENTAURO_PRINTER_HOME, EXTERNAL_CONFIG_FILE y SCALE_CONFIG_FILE.
 */
@Component
public class AgentPaths {

    private static final Logger log = LoggerFactory.getLogger(AgentPaths.class);

    private final Path home;
    private final Path configFile;
    private final Path scaleConfigFile;

    public AgentPaths(
            @Value("${agent.home:}") String homeOverride,
            @Value("${external.config.file:}") String configFileOverride,
            @Value("${scale.config.file:}") String scaleConfigFileOverride) {
        this.home = resolveHome(homeOverride);
        this.configFile = isBlank(configFileOverride)
                ? home.resolve("centauro-pos-config.properties")
                : Path.of(configFileOverride);
        this.scaleConfigFile = isBlank(scaleConfigFileOverride)
                ? home.resolve("scale-configs.json")
                : Path.of(scaleConfigFileOverride);
        log.info("Directorio del agente: {}", home);
    }

    public Path home() {
        return home;
    }

    public Path configFile() {
        return configFile;
    }

    public Path scaleConfigFile() {
        return scaleConfigFile;
    }

    private static Path resolveHome(String override) {
        if (!isBlank(override)) {
            return Path.of(override);
        }
        String localAppData = System.getenv("LOCALAPPDATA");
        if (!isBlank(localAppData)) {
            return Path.of(localAppData, "CentauroPrinter");
        }
        return Path.of(System.getProperty("user.home"), ".centauro-printer");
    }

    private static boolean isBlank(String s) {
        return s == null || s.isBlank();
    }
}
