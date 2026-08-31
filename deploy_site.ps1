# ==============================================================================
# Belgian Interhub FHIR IG - One-Click Build & Deploy Script
# ==============================================================================
param(
    [switch]$NoTx = $true,
    [int]$Port = 8080,
    [switch]$NoBrowser = $false
)

$ErrorActionPreference = "Stop"
$WorkspaceRoot = $PSScriptRoot
Set-Location $WorkspaceRoot

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " Belgian Interhub FHIR IG - One-Click Build & Launch" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

# ------------------------------------------------------------------------------
# 1. Locate Java (JDK 17+)
# ------------------------------------------------------------------------------
Write-Host "`n[1/6] Checking Java environment..." -ForegroundColor Yellow
$JavaCandidates = @(
    "$env:USERPROFILE\.jdks\ms-21.0.10\bin\java.exe",
    "$env:USERPROFILE\.jdks\*\bin\java.exe",
    "C:\Program Files\JetBrains\IntelliJ IDEA 2026.1.4\jbr\bin\java.exe",
    "C:\Program Files\Eclipse Adoptium\jdk-21*\bin\java.exe",
    "C:\Program Files\Java\jdk-21*\bin\java.exe",
    "C:\Program Files\Java\jdk-17*\bin\java.exe",
    (Get-Command java -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue)
)

$JavaExe = $null
foreach ($cand in $JavaCandidates) {
    if ($cand -and (Test-Path $cand)) {
        $resolved = (Resolve-Path $cand)[0].Path
        $JavaExe = $resolved
        break
    }
}

if (-not $JavaExe) {
    Write-Error "Java 17+ could not be found. Please ensure JDK 17+ or IntelliJ JBR is installed."
}
Write-Host "Using Java: $JavaExe" -ForegroundColor Green

# ------------------------------------------------------------------------------
# 2. Locate Ruby / Jekyll
# ------------------------------------------------------------------------------
Write-Host "`n[2/6] Checking Ruby & Jekyll..." -ForegroundColor Yellow
if (Test-Path "C:\Ruby33-x64\bin") {
    $env:PATH = "C:\Ruby33-x64\bin;" + $env:PATH
}

$JekyllCmd = Get-Command jekyll -ErrorAction SilentlyContinue
if (-not $JekyllCmd) {
    Write-Host "Jekyll not in PATH. Checking Ruby..." -ForegroundColor Yellow
    $GemCmd = Get-Command gem -ErrorAction SilentlyContinue
    if ($GemCmd) {
        Write-Host "Installing Jekyll via gem..." -ForegroundColor Yellow
        & gem install jekyll --no-document
    } else {
        Write-Error "Ruby/Jekyll not found. Please install Ruby with DevKit."
    }
}
Write-Host "Jekyll is ready." -ForegroundColor Green

# ------------------------------------------------------------------------------
# 3. Ensure Publisher JAR Exists
# ------------------------------------------------------------------------------
Write-Host "`n[3/6] Checking FHIR IG Publisher JAR..." -ForegroundColor Yellow
$InputCache = Join-Path $WorkspaceRoot "input-cache"
if (-not (Test-Path $InputCache)) {
    New-Item -ItemType Directory -Path $InputCache | Out-Null
}

$PublisherJar = Join-Path $InputCache "publisher.jar"
if (-not (Test-Path $PublisherJar)) {
    Write-Host "Downloading publisher.jar (~220MB)..." -ForegroundColor Yellow
    $url = "https://github.com/HL7/fhir-ig-publisher/releases/latest/download/publisher.jar"
    curl.exe -L -o $PublisherJar $url
}
Write-Host "Publisher JAR is present." -ForegroundColor Green

# ------------------------------------------------------------------------------
# 4. Run SUSHI
# ------------------------------------------------------------------------------
Write-Host "`n[4/6] Compiling FHIR Shorthand with SUSHI..." -ForegroundColor Yellow
sushi .
if ($LASTEXITCODE -ne 0) {
    Write-Error "SUSHI compilation failed."
}

# ------------------------------------------------------------------------------
# 5. Run Official FHIR IG Publisher
# ------------------------------------------------------------------------------
Write-Host "`n[5/6] Building official IG website with IG Publisher..." -ForegroundColor Yellow
$txArg = if ($NoTx) { "-tx n/a" } else { "" }
& $JavaExe -Xmx4096m "-Dfile.encoding=UTF-8" -jar $PublisherJar -ig . $txArg -no-sushi
if ($LASTEXITCODE -ne 0) {
    Write-Error "FHIR IG Publisher build failed (exit code $LASTEXITCODE)."
}

# ------------------------------------------------------------------------------
# 6. Stop Old Server, Start serve.js & Open Browser
# ------------------------------------------------------------------------------
Write-Host "`n[6/6] Launching local server on port $Port..." -ForegroundColor Yellow
Get-Process -Name node -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 1

Start-Process node -ArgumentList "serve.js" -WindowStyle Hidden
Start-Sleep -Seconds 2

$targetUrl = "http://localhost:$Port/en/index.html"
Write-Host "`n=================================================================" -ForegroundColor Green
Write-Host " IG successfully built and running at:" -ForegroundColor Green
Write-Host " $targetUrl" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Green

if (-not $NoBrowser) {
    Start-Process $targetUrl
}
