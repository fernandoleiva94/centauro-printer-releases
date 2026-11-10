package com.agent.printer.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Copia la configuración de las instalaciones anteriores (C:\dist\centauro-pos-config y
 * C:\centauro-pos-config) al directorio nuevo, solo si todavía no existe allí.
 * No borra nada del origen.
 */
@Component
public class LegacyConfigMigrator implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(LegacyConfigMigrator.class);

    private static final List<Path> LEGACY_DIRS = List.of(
            Path.of("C:/dist/centauro-pos-config"),
            Path.of("C:/centauro-pos-config"));

    private final AgentPaths paths;

    public LegacyConfigMigrator(AgentPaths paths) {
        this.paths = paths;
    }

    @Override
    public void run(ApplicationArguments args) {
        try {
            migrate(LEGACY_DIRS);
        } catch (IOException | RuntimeException e) {
            log.warn("No se pudo migrar la configuración anterior: {}", e.getMessage());
        }
    }

    void migrate(List<Path> legacyDirs) throws IOException {
        for (Path dir : legacyDirs) {
            migrateFile(dir.resolve("centauro-pos-config.properties"), paths.configFile(), true);
            migrateFile(dir.resolve("scale-configs.json"), paths.scaleConfigFile(), false);
        }
    }

    private void migrateFile(Path legacy, Path target, boolean properties) throws IOException {
        if (Files.exists(target) || !Files.isRegularFile(legacy)) {
            return;
        }
        if (target.getParent() != null) {
            Files.createDirectories(target.getParent());
        }
        if (properties) {
            writeNormalizedProperties(legacy, target);
        } else {
            Files.copy(legacy, target);
        }
        log.info("Configuración migrada: {} -> {}", legacy, target);
    }

    /** El script viejo escribía "cuit"; el agente y el front usan "tenant_cuit". */
    private void writeNormalizedProperties(Path legacy, Path target) throws IOException {
        Map<String, String> values = new LinkedHashMap<>();
        try (InputStream in = Files.newInputStream(legacy)) {
            for (String line : new String(in.readAllBytes(), StandardCharsets.UTF_8).split("\\R")) {
                String trimmed = line.trim();
                if (trimmed.isEmpty() || trimmed.startsWith("#") || trimmed.startsWith("!")) {
                    continue;
                }
                int idx = separatorIndex(trimmed);
                if (idx > 0) {
                    values.put(trimmed.substring(0, idx).trim(), trimmed.substring(idx + 1).trim());
                }
            }
        }
        String legacyCuit = values.remove("cuit");
        if (legacyCuit != null && !values.containsKey("tenant_cuit")) {
            values.put("tenant_cuit", legacyCuit);
        }
        StringBuilder sb = new StringBuilder();
        values.forEach((k, v) -> sb.append(k).append('=').append(v).append(System.lineSeparator()));
        Files.writeString(target, sb.toString(), StandardCharsets.UTF_8);
    }

    private static int separatorIndex(String line) {
        int colon = line.indexOf(':');
        int equals = line.indexOf('=');
        if (colon < 0) return equals;
        if (equals < 0) return colon;
        return Math.min(colon, equals);
    }
}
