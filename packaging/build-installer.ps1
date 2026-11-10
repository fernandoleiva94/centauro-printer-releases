<#
.SYNOPSIS
  Arma CentauroPrinter-Setup.exe: JRE mínimo (jlink) + app-image (jpackage) + instalador (Inno Setup).

.PARAMETER Version
  Versión numérica X.Y.Z (sin "v"). Se usa para el jar, jpackage, el instalador y latest.json.

.PARAMETER SkipTests
  No corre los tests de Maven.

.PARAMETER IsccPath
  Ruta a ISCC.exe. Si no se indica, se busca en el PATH y en las ubicaciones habituales.

.PARAMETER DownloadBaseUrl
  URL base desde donde se descarga el instalador; se escribe en latest.json.

.EXAMPLE
  .\packaging\build-installer.ps1 -Version 0.1.0
#>
param(
    [string]$Version = "0.1.0",
    [switch]$SkipTests,
    [string]$IsccPath = "",
    [string]$DownloadBaseUrl = "https://github.com/fernandoleiva94/centauro-printer-releases/releases/latest/download"
)

$ErrorActionPreference = "Stop"

if ($Version -notmatch '^\d+\.\d+\.\d+$') {
    throw "Version debe ser X.Y.Z (recibido: '$Version')"
}

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$work = Join-Path $root "build\installer"
$inputDir = Join-Path $work "input"
$runtimeDir = Join-Path $work "runtime"
$appDir = Join-Path $work "app"
$outDir = Join-Path $work "out"
$exploded = Join-Path $work "exploded"

function Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }

function Find-Tool($name) {
    $cmd = Get-Command $name -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    if ($env:JAVA_HOME) {
        $p = Join-Path $env:JAVA_HOME "bin\$name.exe"
        if (Test-Path $p) { return $p }
    }
    throw "No se encontró '$name'. Hace falta un JDK 21 (JAVA_HOME o PATH)."
}

function Find-Iscc {
    if ($IsccPath) { return $IsccPath }
    $cmd = Get-Command ISCC.exe -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $candidates = @(
        "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
        "$env:ProgramFiles\Inno Setup 6\ISCC.exe",
        "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe"
    )
    foreach ($c in $candidates) { if (Test-Path $c) { return $c } }
    throw "No se encontró ISCC.exe (Inno Setup 6). Instalalo con: winget install JRSoftware.InnoSetup"
}

$jlink = Find-Tool "jlink"
$jpackage = Find-Tool "jpackage"
$jdeps = Find-Tool "jdeps"
$iscc = Find-Iscc

Step "Limpiando $work"
if (Test-Path $work) { Remove-Item $work -Recurse -Force }
New-Item -ItemType Directory -Force $inputDir, $outDir | Out-Null

Step "Compilando el jar ($Version)"
$mvnArgs = @("-q", "package", "-Drevision=$Version")
if ($SkipTests) { $mvnArgs += "-DskipTests" }
& (Join-Path $root "mvnw.cmd") @mvnArgs
if ($LASTEXITCODE -ne 0) { throw "Maven falló" }
Copy-Item (Join-Path $root "target\printer.jar") (Join-Path $inputDir "printer.jar")

Step "Detectando módulos de Java necesarios"
New-Item -ItemType Directory -Force $exploded | Out-Null
Push-Location $exploded
try {
    & (Join-Path (Split-Path $jlink) "jar.exe") xf (Join-Path $inputDir "printer.jar")
    $detected = & $jdeps --multi-release 21 --ignore-missing-deps --print-module-deps `
        --class-path "BOOT-INF/lib/*" "BOOT-INF/classes"
    if ($LASTEXITCODE -ne 0) { throw "jdeps falló" }
} finally {
    Pop-Location
}
# Los que jdeps no ve porque se cargan por reflexión / ServiceLoader
$extra = "java.desktop,java.logging,java.management,java.naming,java.xml,java.sql,java.instrument,jdk.unsupported,jdk.crypto.ec,jdk.zipfs"
$modules = ((($detected -split ",") + ($extra -split ",")) | Where-Object { $_ } | Sort-Object -Unique) -join ","
Write-Host "Módulos: $modules"

Step "Armando el JRE mínimo (jlink)"
& $jlink --add-modules $modules --strip-debug --no-header-files --no-man-pages --compress zip-6 --output $runtimeDir
if ($LASTEXITCODE -ne 0) { throw "jlink falló" }

Step "Armando la app (jpackage app-image)"
& $jpackage --type app-image `
    --name CentauroPrinter `
    --app-version $Version `
    --vendor "Centauro" `
    --description "Agente local de impresion de Centauro POS" `
    --input $inputDir `
    --main-jar printer.jar `
    --main-class org.springframework.boot.loader.launch.JarLauncher `
    --runtime-image $runtimeDir `
    --java-options "-Xmx128m" `
    --java-options "-XX:+UseSerialGC" `
    --java-options "-XX:TieredStopAtLevel=1" `
    --dest $appDir
if ($LASTEXITCODE -ne 0) { throw "jpackage falló" }

Step "Armando el instalador (Inno Setup)"
& $iscc "/DAppVersion=$Version" "/DSourceDir=$(Join-Path $appDir 'CentauroPrinter')" "/DOutputDir=$outDir" (Join-Path $PSScriptRoot "CentauroPrinter.iss")
if ($LASTEXITCODE -ne 0) { throw "ISCC falló" }

$installer = Join-Path $outDir "CentauroPrinter-Setup.exe"
$sha = (Get-FileHash $installer -Algorithm SHA256).Hash.ToLower()

Step "Generando latest.json y sha256"
$latest = [ordered]@{
    version = $Version
    url     = "$DownloadBaseUrl/CentauroPrinter-Setup.exe"
    sha256  = $sha
}
$latest | ConvertTo-Json | Set-Content (Join-Path $outDir "latest.json") -Encoding UTF8
"$sha  CentauroPrinter-Setup.exe" | Set-Content (Join-Path $outDir "CentauroPrinter-Setup.exe.sha256") -Encoding ASCII

Write-Host "`nListo: $installer" -ForegroundColor Green
Write-Host ("Tamaño: {0:N1} MB  sha256: {1}" -f ((Get-Item $installer).Length / 1MB), $sha)
