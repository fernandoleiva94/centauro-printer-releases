package com.agent.printer.config;



import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import java.io.IOException;

@Component
public class TokenFilter implements Filter {

    @Value("${print.security.token:}")
    private String token;

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest r = (HttpServletRequest) req;
        HttpServletResponse w = (HttpServletResponse) res;

        // Si no hay token configurado, pasa directo
        if (token == null || token.isBlank()) {
            chain.doFilter(req, res);
            return;
        }

        // Proteger sólo /print/**
        String path = r.getRequestURI();
        if (!path.startsWith("/print/")) {
            chain.doFilter(req, res);
            return;
        }

        String provided = r.getHeader("X-Print-Token");
        if (provided == null || !provided.equals(token)) {
            w.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            w.getWriter().write("Missing or invalid X-Print-Token");
            return;
        }
        chain.doFilter(req, res);
    }
}
