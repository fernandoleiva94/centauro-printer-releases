; Instalador por usuario (sin admin) del agente Centauro Printer.
; Uso: ISCC /DAppVersion=1.2.3 /DSourceDir=<app-image de jpackage> /DOutputDir=<salida> CentauroPrinter.iss

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#ifndef SourceDir
  #error Falta /DSourceDir (carpeta CentauroPrinter generada por jpackage)
#endif
#ifndef OutputDir
  #define OutputDir "out"
#endif

#define AppName "Centauro Printer"
#define AppExe "CentauroPrinter.exe"

[Setup]
; No cambiar el AppId: es lo que permite actualizar sobre una instalación existente.
AppId={{6D2B6F3A-5C1E-4B7B-9F4A-C3A7E1D0B9A2}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher=Centauro
VersionInfoVersion={#AppVersion}
DefaultDirName={localappdata}\Programs\CentauroPrinter
PrivilegesRequired=lowest
DisableWelcomePage=yes
DisableDirPage=yes
DisableProgramGroupPage=yes
DisableReadyPage=yes
DisableReadyMemo=yes
DisableFinishedPage=yes
Compression=lzma2
SolidCompression=yes
OutputDir={#OutputDir}
OutputBaseFilename=CentauroPrinter-Setup
UninstallDisplayName={#AppName}
UninstallDisplayIcon={app}\{#AppExe}
ArchitecturesInstallIn64BitMode=x64compatible
WizardStyle=modern
CloseApplications=no

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Registry]
; Arranque automático al iniciar sesión (por usuario, no requiere admin)
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "CentauroPrinter"; ValueData: """{app}\{#AppExe}"""; Flags: uninsdeletevalue

[Run]
; Arranca el agente al terminar. También en instalaciones silenciosas (auto-update).
Filename: "{app}\{#AppExe}"; Description: "Iniciar {#AppName}"; Flags: nowait

[Code]
// El agente no tiene ventana: hay que cerrarlo a mano para poder reemplazar sus archivos.
procedure StopAgent();
var
  ResultCode: Integer;
begin
  Exec(ExpandConstant('{sys}\taskkill.exe'), '/F /IM {#AppExe}', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  StopAgent();
  Sleep(800);
  Result := '';
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
    StopAgent();
end;
