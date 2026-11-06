package com.agent.printer.service;

import com.agent.printer.model.ScaleConfig;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

@Service
public class ScaleConfigService {

    private final ObjectMapper mapper;

    @Value("${scale.config.file:C:/dist/centauro-pos-config/scale-configs.json}")
    private String scaleConfigFile;

    public ScaleConfigService() {
        this.mapper = new ObjectMapper();
        this.mapper.enable(SerializationFeature.INDENT_OUTPUT);
    }

    // -------------------------------------------------------------------------
    // Lectura
    // -------------------------------------------------------------------------

    public List<ScaleConfig> findAll() throws IOException {
        Path path = Path.of(scaleConfigFile);
        if (!Files.exists(path)) {
            return new ArrayList<>();
        }
        return mapper.readValue(path.toFile(), new TypeReference<List<ScaleConfig>>() {});
    }

    public ScaleConfig findById(String id) throws IOException {
        return findAll().stream()
                .filter(s -> id.equals(s.getId()))
                .findFirst()
                .orElse(null);
    }

    // -------------------------------------------------------------------------
    // Escritura
    // -------------------------------------------------------------------------

    public ScaleConfig save(ScaleConfig config) throws IOException {
        if (config.getId() == null || config.getId().isBlank()) {
            throw new IllegalArgumentException("El campo 'id' es obligatorio");
        }

        List<ScaleConfig> all = findAll();
        boolean updated = false;

        for (int i = 0; i < all.size(); i++) {
            if (config.getId().equals(all.get(i).getId())) {
                all.set(i, config);
                updated = true;
                break;
            }
        }

        if (!updated) {
            all.add(config);
        }

        persist(all);
        return config;
    }

    public boolean delete(String id) throws IOException {
        List<ScaleConfig> all = findAll();
        boolean removed = all.removeIf(s -> id.equals(s.getId()));
        if (removed) {
            persist(all);
        }
        return removed;
    }

    // -------------------------------------------------------------------------
    // Internos
    // -------------------------------------------------------------------------

    private void persist(List<ScaleConfig> configs) throws IOException {
        Path path = Path.of(scaleConfigFile);
        if (path.getParent() != null) {
            Files.createDirectories(path.getParent());
        }
        mapper.writeValue(path.toFile(), configs);
    }
}

