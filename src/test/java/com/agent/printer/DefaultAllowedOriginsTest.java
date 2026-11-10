package com.agent.printer;

import org.junit.jupiter.api.io.TempDir;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;

import java.nio.file.Path;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/** Con la configuración por defecto (sin ALLOWED_ORIGINS) los sitios de Centauro tienen que poder usar el agente. */
@SpringBootTest
@AutoConfigureMockMvc
class DefaultAllowedOriginsTest {

    @TempDir
    static Path home;

    @DynamicPropertySource
    static void props(DynamicPropertyRegistry registry) {
        registry.add("agent.home", () -> home.toString());
    }

    @Autowired
    MockMvc mvc;

    @ParameterizedTest
    @ValueSource(strings = {
            "https://app.centauropos.com",
            "https://centauropos.com",
            "https://app.centauropos.com.ar",
            "http://localhost:5173"
    })
    void sitiosDeCentauroPuedenUsarElAgente(String origin) throws Exception {
        mvc.perform(get("/agent/info").header("Host", "localhost:9710").header("Origin", origin))
                .andExpect(status().isOk())
                .andExpect(header().string("Access-Control-Allow-Origin", origin));
    }

    @ParameterizedTest
    @ValueSource(strings = {"https://evil.example.com", "https://centauropos.com.evil.com"})
    void otrosSitiosSonRechazados(String origin) throws Exception {
        mvc.perform(get("/agent/info").header("Host", "localhost:9710").header("Origin", origin))
                .andExpect(status().isForbidden());
    }
}
