package com.agent.printer.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.Arrays;
import java.util.List;

/**
 * CORS del agente. Los orígenes permitidos salen de {@code allowed.origins}
 * (ALLOWED_ORIGINS, separados por coma, admiten comodines tipo {@code https://*.dominio.com}).
 * {@link LocalAccessFilter} reutiliza esta misma configuración para rechazar orígenes no permitidos.
 */
@Configuration
public class CorsConfig {

    @Bean
    public CorsConfiguration agentCorsConfiguration(@Value("${allowed.origins}") String allowedOrigins) {
        var cfg = new CorsConfiguration();
        cfg.setAllowedOriginPatterns(parse(allowedOrigins));
        cfg.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        cfg.setAllowedHeaders(List.of("*"));
        cfg.setAllowCredentials(false);
        // Chrome pregunta esto en el preflight cuando una página pública le pega a localhost
        cfg.setAllowPrivateNetwork(true);
        cfg.setMaxAge(3600L);
        return cfg;
    }

    @Bean
    public CorsFilter corsFilter(CorsConfiguration agentCorsConfiguration) {
        var source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", agentCorsConfiguration);
        return new CorsFilter(source);
    }

    static List<String> parse(String raw) {
        return Arrays.stream(raw.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .toList();
    }
}
