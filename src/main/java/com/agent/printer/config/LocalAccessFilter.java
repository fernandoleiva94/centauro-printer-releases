package com.agent.printer.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Set;

/**
 * Protege el agente de páginas web que no son el POS.
 *
 * - Host: solo localhost / 127.0.0.1 / [::1] (evita DNS rebinding).
 * - Origin: si el navegador manda uno, tiene que estar en la lista permitida. Aplica también a
 *   requests "simples" (POST text/plain) que no pasan por preflight.
 *
 * Los requests sin Origin (curl, scripts, el mismo equipo) pasan.
 */
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class LocalAccessFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(LocalAccessFilter.class);
    private static final Set<String> LOCAL_HOSTS = Set.of("localhost", "127.0.0.1", "[::1]");

    private final CorsConfiguration corsConfiguration;

    public LocalAccessFilter(CorsConfiguration agentCorsConfiguration) {
        this.corsConfiguration = agentCorsConfiguration;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        if (!isLocalHost(request.getHeader("Host"))) {
            log.warn("Request rechazado por Host no local: {}", request.getHeader("Host"));
            reject(response, "Host no permitido");
            return;
        }
        String origin = request.getHeader("Origin");
        if (origin != null && corsConfiguration.checkOrigin(origin) == null) {
            log.warn("Request rechazado por Origin no permitido: {}", origin);
            reject(response, "Origin no permitido");
            return;
        }
        chain.doFilter(request, response);
    }

    static boolean isLocalHost(String hostHeader) {
        if (hostHeader == null || hostHeader.isBlank()) {
            return false;
        }
        String host = hostHeader.trim().toLowerCase();
        if (host.startsWith("[")) {
            int end = host.indexOf(']');
            host = end > 0 ? host.substring(0, end + 1) : host;
        } else {
            int colon = host.indexOf(':');
            host = colon >= 0 ? host.substring(0, colon) : host;
        }
        return LOCAL_HOSTS.contains(host);
    }

    private static void reject(HttpServletResponse response, String message) throws IOException {
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        response.setContentType("application/json");
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.getWriter().write("{\"error\":\"" + message + "\"}");
    }
}
