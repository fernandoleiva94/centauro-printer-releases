package com.agent.printer.service;

import com.agent.printer.model.ConfigUpdateRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.LinkedHashMap;
import java.util.Map;

@Service
public class ExternalConfigService {

    @Value("${external.config.file:C:/centauro-pos-config/centauro-pos-config.properties}")
    private String externalConfigFile;

    public Map<String, String> loadConfig() throws IOException {
        Path path = Path.of(externalConfigFile);
        if (!Files.exists(path) || !Files.isRegularFile(path)) {
            throw new FileNotFoundException("No se encontro el archivo de configuracion: " + path);
        }

        Map<String, String> config = new LinkedHashMap<>();
        try (BufferedReader reader = Files.newBufferedReader(path, StandardCharsets.UTF_8)) {
            String line;
            int lineNumber = 0;
            while ((line = reader.readLine()) != null) {
                lineNumber++;
                String trimmed = line.trim();
                if (trimmed.isEmpty() || trimmed.startsWith("#") || trimmed.startsWith("!")) {
                    continue;
                }

                int separator = findSeparator(trimmed);
                if (separator < 0) {
                    throw new IllegalArgumentException("Linea invalida en configuracion (" + lineNumber + "): " + line);
                }

                String key = trimmed.substring(0, separator).trim();
                String value = trimmed.substring(separator + 1).trim();
                if (key.isEmpty()) {
                    throw new IllegalArgumentException("Clave vacia en configuracion (" + lineNumber + ")");
                }
                config.put(key, value);
            }
        }
        return config;
    }

    public Map<String, String> saveConfig(ConfigUpdateRequest request) throws IOException {
        Path path = Path.of(externalConfigFile);

        // Si el directorio no existe, lo crea
        if (path.getParent() != null) {
            Files.createDirectories(path.getParent());
        }

        // Carga la config existente para hacer merge
        Map<String, String> config = new LinkedHashMap<>();
        if (Files.exists(path) && Files.isRegularFile(path)) {
            config = loadConfig();
        }

        // Aplica solo los campos no-null (actualización parcial)
        if (request.getPunto_de_venta() != null) {
            config.put("punto_de_venta", request.getPunto_de_venta());
        }
        if (request.getTenant_cuit() != null) {
            config.put("tenant_cuit", request.getTenant_cuit());
        }
        if (request.getTerminal_code() != null) {
            config.put("terminal_code", request.getTerminal_code());
        }

        // Escribe el archivo con formato clave=valor
        try (BufferedWriter writer = Files.newBufferedWriter(path, StandardCharsets.UTF_8)) {
            for (Map.Entry<String, String> entry : config.entrySet()) {
                writer.write(entry.getKey() + "=" + entry.getValue());
                writer.newLine();
            }
        }

        return config;
    }

    private int findSeparator(String line) {
        int colonIndex = line.indexOf(':');
        int equalsIndex = line.indexOf('=');

        if (colonIndex < 0) {
            return equalsIndex;
        }
        if (equalsIndex < 0) {
            return colonIndex;
        }
        return Math.min(colonIndex, equalsIndex);
    }
}
