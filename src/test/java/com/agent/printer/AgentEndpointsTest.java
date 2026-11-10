package com.agent.printer;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;

import java.nio.file.Path;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.options;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class AgentEndpointsTest {

    @TempDir
    static Path home;

    @DynamicPropertySource
    static void props(DynamicPropertyRegistry registry) {
        registry.add("agent.home", () -> home.toString());
        registry.add("allowed.origins", () -> "http://localhost:*,https://app.centauropos.com.ar");
    }

    @Autowired
    MockMvc mvc;

    @Test
    void agentInfoExponeVersion() throws Exception {
        mvc.perform(get("/agent/info").header("Host", "localhost:9710"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("centauro-printer"))
                .andExpect(jsonPath("$.version").isNotEmpty());
    }

    @Test
    void preflightDeOrigenPermitidoResponde() throws Exception {
        mvc.perform(options("/config")
                        .header("Host", "localhost:9710")
                        .header("Origin", "https://app.centauropos.com.ar")
                        .header("Access-Control-Request-Method", "PUT")
                        .header("Access-Control-Request-Private-Network", "true"))
                .andExpect(status().isOk())
                .andExpect(header().string("Access-Control-Allow-Origin", "https://app.centauropos.com.ar"))
                .andExpect(header().string("Access-Control-Allow-Private-Network", "true"));
    }

    @Test
    void origenAjenoRecibe403() throws Exception {
        mvc.perform(get("/printers")
                        .header("Host", "localhost:9710")
                        .header("Origin", "https://evil.example.com"))
                .andExpect(status().isForbidden());
    }

    @Test
    void hostNoLocalRecibe403() throws Exception {
        mvc.perform(get("/agent/info").header("Host", "192.168.1.50:9710"))
                .andExpect(status().isForbidden());
    }
}
