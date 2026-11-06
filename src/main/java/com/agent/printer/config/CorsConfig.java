package com.agent.printer.config;


import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.web.cors.*;
import org.springframework.web.filter.CorsFilter;

import java.util.List;

@Configuration
public class CorsConfig {
    @Value("${allowed.origin:*}")
    private String allowedOrigin;

    @Bean
    public CorsFilter corsFilter() {
        var source = new UrlBasedCorsConfigurationSource();
        var cfg = new CorsConfiguration();
        if ("*".equals(allowedOrigin)) {
            cfg.addAllowedOriginPattern("*");
        } else {
            cfg.setAllowedOrigins(List.of(allowedOrigin));
        }
        cfg.setAllowedMethods(List.of("GET","POST","PUT","DELETE","OPTIONS"));
        cfg.setAllowedHeaders(List.of("*"));
        cfg.setAllowCredentials(false);
        cfg.setMaxAge(3600L);
        source.registerCorsConfiguration("/**", cfg);
        return new CorsFilter(source);
    }


}
