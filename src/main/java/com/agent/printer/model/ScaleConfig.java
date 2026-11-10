package com.agent.printer.model;

import lombok.Data;

@Data
public class ScaleConfig {

    /** Identificador único de la configuración (ej: "epelsa", "toledo") */
    private String id;

    /** Nombre descriptivo */
    private String name;

    /** Si está activa */
    private boolean enabled = true;

    /** Longitud total esperada del código de barras (ej: 13 para EAN-13) */
    private int barcodeLength;

    /**
     * Prefijos válidos separados por coma. Soporta rangos: "20-29,21"
     * El parser verificará que el código empiece con alguno de estos prefijos.
     */
    private String prefixes;

    /** Posición 1-based donde empieza el PLU */
    private int pluStart;

    /** Cantidad de dígitos del PLU */
    private int pluLen;

    /** Posición 1-based donde empieza el valor (peso o precio) */
    private int valueStart;

    /** Cantidad de dígitos del valor */
    private int valueLen;

    /**
     * Tipo de valor: "WEIGHT" o "PRICE"
     */
    private String valueType;

    /**
     * Cantidad de decimales implícitos del valor.
     * Ej: decimals=3 → valor leído 00750 → 0.750 kg
     * Ej: decimals=2 → valor leído 01250 → 12.50
     */
    private int decimals;

    /** Si debe validar checksum EAN-13 */
    private boolean checksum = false;
}

