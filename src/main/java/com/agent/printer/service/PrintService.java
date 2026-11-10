package com.agent.printer.service;


import com.agent.printer.model.PrinterInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.print.*;
import javax.print.event.PrintJobAdapter;
import javax.print.event.PrintJobEvent;
import java.nio.charset.StandardCharsets;
import java.util.*;

@Service
public class PrintService {

  private static final Logger log = LoggerFactory.getLogger(PrintService.class);

  @Value("${print.default.printer:${PRINT_DEFAULT_PRINTER:}}")
  private String configuredDefaultPrinter;

  public List<PrinterInfo> listPrinters() {
    javax.print.PrintService[] services = javax.print.PrintServiceLookup.lookupPrintServices(null, null);
    javax.print.PrintService def = javax.print.PrintServiceLookup.lookupDefaultPrintService();
    List<PrinterInfo> out = new ArrayList<>();
    for (javax.print.PrintService s : services) {
      out.add(new PrinterInfo(s.getName(), def != null && def.getName().equals(s.getName())));
    }
    return out;
  }

  public PrinterInfo defaultPrinter() {
    javax.print.PrintService def = javax.print.PrintServiceLookup.lookupDefaultPrintService();
    if (def == null) return null;
    return new PrinterInfo(def.getName(), true);
  }

  public void printRaw(String printerName, byte[] data) throws PrintException {
    DocFlavor flavor = DocFlavor.BYTE_ARRAY.AUTOSENSE;
    javax.print.PrintService service = resolveService(printerName);
    String defaultPrinter = Optional.ofNullable(javax.print.PrintServiceLookup.lookupDefaultPrintService())
        .map(javax.print.PrintService::getName)
        .orElse(null);
    List<String> visiblePrinters = listPrinterNames();

    log.info("Solicitud de impresion. usuario={}, impresoraSolicitada={}, impresoraResuelta={}, impresoraDefault={}, impresorasVisibles={}, bytes={}",
        System.getProperty("user.name"),
        printerName,
        service != null ? service.getName() : null,
        defaultPrinter,
        visiblePrinters,
        data != null ? data.length : 0);

    if (service == null) {
      throw new PrintException("Printer not found: " + printerName + ". Visible printers: " + visiblePrinters);
    }

    DocPrintJob job = service.createPrintJob();
    job.addPrintJobListener(new PrintJobAdapter() {
      @Override
      public void printJobCompleted(PrintJobEvent pje) {
        log.info("Trabajo de impresion completado en {}", service.getName());
      }

      @Override
      public void printJobFailed(PrintJobEvent pje) {
        log.error("Trabajo de impresion fallido en {}", service.getName());
      }

      @Override
      public void printJobCanceled(PrintJobEvent pje) {
        log.warn("Trabajo de impresion cancelado en {}", service.getName());
      }

      @Override
      public void printJobNoMoreEvents(PrintJobEvent pje) {
        log.info("Sin mas eventos para el trabajo de impresion en {}", service.getName());
      }
    });
    Doc doc = new SimpleDoc(data, flavor, null);
    job.print(doc, null);
  }

  public Map<String, Object> diagnostics() {
    Map<String, Object> out = new LinkedHashMap<>();
    javax.print.PrintService defaultService = javax.print.PrintServiceLookup.lookupDefaultPrintService();
    out.put("user", System.getProperty("user.name"));
    out.put("javaVersion", System.getProperty("java.version"));
    out.put("configuredDefaultPrinter", isBlank(configuredDefaultPrinter) ? null : configuredDefaultPrinter);
    out.put("defaultPrinter", defaultService != null ? defaultService.getName() : null);
    out.put("visiblePrinters", listPrinterNames());
    out.put("printerCount", listPrinterNames().size());
    return out;
  }

  private javax.print.PrintService resolveService(String printerName) {
    if (printerName == null || printerName.isBlank()) {
      if (!isBlank(configuredDefaultPrinter)) {
        javax.print.PrintService configured = resolveByName(configuredDefaultPrinter);
        if (configured != null) {
          return configured;
        }
        log.warn("No se encontro print.default.printer='{}'. Se usara la impresora default del sistema.", configuredDefaultPrinter);
      }
      return javax.print.PrintServiceLookup.lookupDefaultPrintService();
    }
    return resolveByName(printerName);
  }

  private javax.print.PrintService resolveByName(String printerName) {
    javax.print.PrintService[] services = javax.print.PrintServiceLookup.lookupPrintServices(null, null);
    for (javax.print.PrintService ps : services) {
      if (ps.getName().equalsIgnoreCase(printerName)) return ps;
    }
    return null;
  }

  private boolean isBlank(String value) {
    return value == null || value.isBlank();
  }

  private List<String> listPrinterNames() {
    javax.print.PrintService[] services = javax.print.PrintServiceLookup.lookupPrintServices(null, null);
    List<String> printerNames = new ArrayList<>();
    for (javax.print.PrintService service : services) {
      printerNames.add(service.getName());
    }
    return printerNames;
  }

  // Utilidad de prueba: genera “Hola” con ESC/POS y corte
  public static byte[] sampleEscPos() {
    byte[] init   = new byte[]{0x1B, 0x40};         // ESC @
    byte[] center = new byte[]{0x1B, 0x61, 0x01};   // ESC a 1
    byte[] boldOn = new byte[]{(byte)0x1B, 0x45, 0x01};
    byte[] boldOff= new byte[]{(byte)0x1B, 0x45, 0x00};
    byte[] lf     = new byte[]{0x0A};
    byte[] cut    = new byte[]{0x1D, 0x56, 0x00};   // GS V 0
    byte[] text   = "Hola POS\n".getBytes(StandardCharsets.ISO_8859_1);

    byte[] all = new byte[init.length+center.length+boldOn.length+text.length+boldOff.length+lf.length+cut.length];
    int i=0;
    System.arraycopy(init,0,all,i,init.length); i+=init.length;
    System.arraycopy(center,0,all,i,center.length); i+=center.length;
    System.arraycopy(boldOn,0,all,i,boldOn.length); i+=boldOn.length;
    System.arraycopy(text,0,all,i,text.length); i+=text.length;
    System.arraycopy(boldOff,0,all,i,boldOff.length); i+=boldOff.length;
    System.arraycopy(lf,0,all,i,lf.length); i+=lf.length;
    System.arraycopy(cut,0,all,i,cut.length);
    return all;
  }








}
