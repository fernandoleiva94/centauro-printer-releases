package com.agent.printer.controller;

import com.agent.printer.model.ScaleConfig;
import com.agent.printer.service.ScaleConfigService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/config/scales")
public class ScaleConfigController {

    private final ScaleConfigService scaleConfigService;

    public ScaleConfigController(ScaleConfigService scaleConfigService) {
        this.scaleConfigService = scaleConfigService;
    }

    /** GET /config/scales — lista todas las configuraciones */
    @GetMapping
    public ResponseEntity<?> getAll() {
        try {
            List<ScaleConfig> list = scaleConfigService.findAll();
            return ResponseEntity.ok(list);
        } catch (IOException e) {
            return error(e);
        }
    }

    /** GET /config/scales/{id} — obtiene una configuración por id */
    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable String id) {
        try {
            ScaleConfig config = scaleConfigService.findById(id);
            if (config == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(Map.of("error", "No se encontro configuracion de balanza con id: " + id));
            }
            return ResponseEntity.ok(config);
        } catch (IOException e) {
            return error(e);
        }
    }

    /** POST /config/scales — crea una nueva configuración */
    @PostMapping
    public ResponseEntity<?> create(@RequestBody ScaleConfig config) {
        try {
            ScaleConfig saved = scaleConfigService.save(config);
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", e.getMessage()));
        } catch (IOException e) {
            return error(e);
        }
    }

    /** PUT /config/scales/{id} — actualiza una configuración existente */
    @PutMapping("/{id}")
    public ResponseEntity<?> update(@PathVariable String id, @RequestBody ScaleConfig config) {
        try {
            config.setId(id);
            ScaleConfig saved = scaleConfigService.save(config);
            return ResponseEntity.ok(saved);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("error", e.getMessage()));
        } catch (IOException e) {
            return error(e);
        }
    }

    /** DELETE /config/scales/{id} — elimina una configuración */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable String id) {
        try {
            boolean removed = scaleConfigService.delete(id);
            if (!removed) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(Map.of("error", "No se encontro configuracion de balanza con id: " + id));
            }
            return ResponseEntity.ok(Map.of("message", "Configuracion eliminada: " + id));
        } catch (IOException e) {
            return error(e);
        }
    }

    private ResponseEntity<Map<String, String>> error(IOException e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", e.getMessage()));
    }
}

