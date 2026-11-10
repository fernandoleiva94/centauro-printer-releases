package com.agent.printer.controller;

import com.agent.printer.model.ConfigUpdateRequest;
import com.agent.printer.service.ExternalConfigService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Map;

@RestController
public class ConfigController {

    private final ExternalConfigService externalConfigService;

    public ConfigController(ExternalConfigService externalConfigService) {
        this.externalConfigService = externalConfigService;
    }

    @GetMapping("/config")
    public ResponseEntity<?> getConfig() {
        try {
            return ResponseEntity.ok(externalConfigService.loadConfig());
        } catch (FileNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("error", e.getMessage()));
        } catch (IllegalArgumentException | IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("error", e.getMessage()));
        }
    }

    @PutMapping("/config")
    public ResponseEntity<?> updateConfig(@RequestBody ConfigUpdateRequest request) {
        try {
            Map<String, String> updated = externalConfigService.saveConfig(request);
            return ResponseEntity.ok(updated);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", e.getMessage()));
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("error", e.getMessage()));
        }
    }
}

