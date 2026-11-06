package com.agent.printer.config;

import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockFilterChain;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class LocalAccessFilterTest {

    private final LocalAccessFilter filter = new LocalAccessFilter(
            new CorsConfig().agentCorsConfiguration("http://localhost:*,https://*.centauropos.com.ar"));

    private MockHttpServletResponse run(String host, String origin) throws Exception {
        var request = new MockHttpServletRequest("GET", "/printers");
        if (host != null) request.addHeader("Host", host);
        if (origin != null) request.addHeader("Origin", origin);
        var response = new MockHttpServletResponse();
        var chain = new MockFilterChain();
        filter.doFilter(request, response, chain);
        return response;
    }

    private boolean passed(String host, String origin) throws Exception {
        var request = new MockHttpServletRequest("GET", "/printers");
        if (host != null) request.addHeader("Host", host);
        if (origin != null) request.addHeader("Origin", origin);
        var chain = new MockFilterChain();
        filter.doFilter(request, new MockHttpServletResponse(), chain);
        return chain.getRequest() != null;
    }

    @Test
    void permiteLocalhostSinOrigin() throws Exception {
        assertTrue(passed("localhost:9710", null));
        assertTrue(passed("127.0.0.1:9710", null));
        assertTrue(passed("[::1]:9710", null));
    }

    @Test
    void permiteOrigenesDeLaLista() throws Exception {
        assertTrue(passed("localhost:9710", "http://localhost:5173"));
        assertTrue(passed("localhost:9710", "https://app.centauropos.com.ar"));
    }

    @Test
    void rechazaOrigenesAjenos() throws Exception {
        assertFalse(passed("localhost:9710", "https://evil.example.com"));
        assertFalse(passed("localhost:9710", "https://centauropos.com.ar.evil.com"));
        assertEquals(403, run("localhost:9710", "https://evil.example.com").getStatus());
    }

    @Test
    void rechazaHostNoLocal() throws Exception {
        assertFalse(passed("192.168.1.20:9710", null));
        assertFalse(passed("rebind.evil.com:9710", "http://localhost:5173"));
        assertFalse(passed(null, null));
        assertEquals(403, run("rebind.evil.com", null).getStatus());
    }

    @Test
    void isLocalHostNormalizaPuertoYMayusculas() {
        assertTrue(LocalAccessFilter.isLocalHost("LOCALHOST"));
        assertTrue(LocalAccessFilter.isLocalHost("localhost:80"));
        assertFalse(LocalAccessFilter.isLocalHost("localhost.evil.com"));
        assertFalse(LocalAccessFilter.isLocalHost(""));
    }

    @Test
    void checkOriginUsaLaMismaConfiguracion() {
        var cfg = new CorsConfig().agentCorsConfiguration("https://*.centauropos.com.ar");
        assertNotNull(cfg.checkOrigin("https://a.centauropos.com.ar"));
        assertNull(cfg.checkOrigin("https://a.centauropos.com"));
    }
}
