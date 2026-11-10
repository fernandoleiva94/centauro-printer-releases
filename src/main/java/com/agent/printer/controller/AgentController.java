package com.agent.printer.controller;

import com.agent.printer.config.AgentPaths;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.boot.info.BuildProperties;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.lang.management.ManagementFactory;
import java.util.LinkedHashMap;
import java.util.Map;

/** Información del agente para que el front muestre versión y estado. */
@RestController
public class AgentController {

    private final String version;
    private final String buildTime;
    private final AgentPaths paths;

    public AgentController(ObjectProvider<BuildProperties> buildProperties, AgentPaths paths) {
        BuildProperties build = buildProperties.getIfAvailable();
        this.version = build != null ? build.getVersion() : "dev";
        this.buildTime = build != null && build.getTime() != null ? build.getTime().toString() : null;
        this.paths = paths;
    }

    @GetMapping("/agent/info")
    public Map<String, Object> info() {
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("name", "centauro-printer");
        out.put("version", version);
        out.put("buildTime", buildTime);
        out.put("os", System.getProperty("os.name"));
        out.put("javaVersion", System.getProperty("java.version"));
        out.put("uptimeSeconds", ManagementFactory.getRuntimeMXBean().getUptime() / 1000);
        out.put("configFile", paths.configFile().toString());
        return out;
    }
}
