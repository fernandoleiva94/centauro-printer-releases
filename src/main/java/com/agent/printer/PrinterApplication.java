package com.agent.printer;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.io.IOException;
import java.net.InetAddress;
import java.net.ServerSocket;

@SpringBootApplication
public class PrinterApplication {

	private static final Logger log = LoggerFactory.getLogger(PrinterApplication.class);

	/** Código de salida cuando ya hay otra instancia del agente corriendo. */
	static final int EXIT_ALREADY_RUNNING = 10;

	public static void main(String[] args) {
		int port = configuredPort();
		if (isPortInUse(port)) {
			log.info("El puerto {} ya está en uso: probablemente el agente ya está corriendo. Saliendo.", port);
			System.exit(EXIT_ALREADY_RUNNING);
		}
		SpringApplication.run(PrinterApplication.class, args);
	}

	private static int configuredPort() {
		String env = System.getenv("PRINTER_PORT");
		if (env != null && !env.isBlank()) {
			try {
				return Integer.parseInt(env.trim());
			} catch (NumberFormatException ignored) {
				// Spring va a fallar con un mensaje claro al arrancar
			}
		}
		return 9710;
	}

	static boolean isPortInUse(int port) {
		try (ServerSocket socket = new ServerSocket(port, 1, InetAddress.getLoopbackAddress())) {
			return false;
		} catch (IOException e) {
			return true;
		}
	}

}
