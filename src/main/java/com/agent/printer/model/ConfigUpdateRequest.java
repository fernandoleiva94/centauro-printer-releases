package com.agent.printer.model;

public class ConfigUpdateRequest {

    private String punto_de_venta;
    private String tenant_cuit;
    private String terminal_code;

    public String getPunto_de_venta() { return punto_de_venta; }
    public void setPunto_de_venta(String punto_de_venta) { this.punto_de_venta = punto_de_venta; }

    public String getTenant_cuit() { return tenant_cuit; }
    public void setTenant_cuit(String tenant_cuit) { this.tenant_cuit = tenant_cuit; }

    public String getTerminal_code() { return terminal_code; }
    public void setTerminal_code(String terminal_code) { this.terminal_code = terminal_code; }
}

