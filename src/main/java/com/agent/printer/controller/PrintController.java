package com.agent.printer.controller;


import com.agent.printer.model.PrintRawRequest;
import com.agent.printer.model.PrinterInfo;
import com.agent.printer.service.PrintService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.print.PrintException;
import java.util.*;

@RestController
public class PrintController {

  private final PrintService printService;

  public PrintController(PrintService printService) {
    this.printService = printService;
  }

  @GetMapping("/printers")
  public List<PrinterInfo> printers() {
    return printService.listPrinters();
  }

  @GetMapping("/printers/default")
  public ResponseEntity<PrinterInfo> defaultPrinter() {
    PrinterInfo p = printService.defaultPrinter();
    return (p == null) ? ResponseEntity.noContent().build() : ResponseEntity.ok(p);
  }

  @GetMapping("/diagnostics/printing")
  public Map<String, Object> printingDiagnostics() {
    return printService.diagnostics();
  }

  @PostMapping("/print/raw")
  public ResponseEntity<?> printRaw(@RequestBody PrintRawRequest req) {
    if (req == null || req.dataBase64() == null || req.dataBase64().isBlank()) {
      return ResponseEntity.badRequest().body("dataBase64 is required");
    }
    try {
      byte[] data = Base64.getDecoder().decode(req.dataBase64());
      printService.printRaw(req.printerName(), data);
      return ResponseEntity.noContent().build();
    } catch (IllegalArgumentException e) {
      return ResponseEntity.badRequest().body("Invalid base64");
    } catch (PrintException e) {
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
    }
  }

  // Probar sin frontend
  @PostMapping("/print/test")
  public ResponseEntity<?> printTest(@RequestParam(required=false) String printer) throws PrintException {
    printService.printRaw(printer, PrintService.sampleEscPos());
    return ResponseEntity.noContent().build();
  }
}
