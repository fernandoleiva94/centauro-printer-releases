package com.agent.printer.config;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class LegacyConfigMigratorTest {

    @TempDir
    Path tmp;

    private AgentPaths paths() {
        return new AgentPaths(tmp.resolve("new").toString(), "", "");
    }

    @Test
    void migraConfigYBalanzasYNormalizaCuit() throws Exception {
        Path legacy = Files.createDirectories(tmp.resolve("legacy"));
        Files.writeString(legacy.resolve("centauro-pos-config.properties"),
                "punto_de_venta=3\ncuit=20111111112\nterminal_code=T1\n", StandardCharsets.UTF_8);
        Files.writeString(legacy.resolve("scale-configs.json"), "[]", StandardCharsets.UTF_8);

        AgentPaths paths = paths();
        new LegacyConfigMigrator(paths).migrate(List.of(legacy));

        String migrated = Files.readString(paths.configFile());
        assertTrue(migrated.contains("tenant_cuit=20111111112"));
        assertFalse(migrated.contains("\ncuit=") || migrated.startsWith("cuit="));
        assertTrue(migrated.contains("terminal_code=T1"));
        assertEquals("[]", Files.readString(paths.scaleConfigFile()));
        assertTrue(Files.exists(legacy.resolve("centauro-pos-config.properties")), "no borra el origen");
    }

    @Test
    void noPisaUnaConfigExistente() throws Exception {
        Path legacy = Files.createDirectories(tmp.resolve("legacy"));
        Files.writeString(legacy.resolve("centauro-pos-config.properties"), "terminal_code=VIEJA\n");

        AgentPaths paths = paths();
        Files.createDirectories(paths.configFile().getParent());
        Files.writeString(paths.configFile(), "terminal_code=NUEVA\n");

        new LegacyConfigMigrator(paths).migrate(List.of(legacy));

        assertEquals("terminal_code=NUEVA\n", Files.readString(paths.configFile()));
    }

    @Test
    void sinOrigenNoHaceNada() throws Exception {
        AgentPaths paths = paths();
        new LegacyConfigMigrator(paths).migrate(List.of(tmp.resolve("no-existe")));
        assertFalse(Files.exists(paths.configFile()));
    }
}
