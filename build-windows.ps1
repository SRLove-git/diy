<#
  build-windows.ps1 - Think Origin local build script (Windows / PowerShell)

  Builds server (NestJS) + admin (Vue3 + Vite) locally, optionally builds Docker images.

  Usage (run from the diy-main project root):
    powershell -ExecutionPolicy Bypass -File build-windows.ps1              # install deps + build server & admin
    powershell -ExecutionPolicy Bypass -File build-windows.ps1 -SkipInstall # skip npm install (node_modules exists)
    powershell -ExecutionPolicy Bypass -File build-windows.ps1 -Docker      # also build docker-server / docker-admin
    powershell -ExecutionPolicy Bypass -File build-windows.ps1 -SkipServer  # build admin only
    powershell -ExecutionPolicy Bypass -File build-windows.ps1 -SkipAdmin   # build server only
    powershell -ExecutionPolicy Bypass -File build-windows.ps1 -Help        # show usage

  Requirements:
    - Node.js >= 20 (22 LTS recommended) with npm.
    - Docker Desktop, only when -Docker is used.
#>

[CmdletBinding()]
param(
  [switch]$SkipInstall,   # skip npm install / npm ci
  [switch]$SkipServer,    # do not build server
  [switch]$SkipAdmin,     # do not build admin
  [switch]$Docker,        # additionally build docker-server / docker-admin images
  [switch]$Help           # show help
)

$ErrorActionPreference = 'Stop'

if ($Help) {
  Get-Content -LiteralPath $MyInvocation.MyCommand.Path | Select-Object -First 40 | Where-Object { $_ -match '^  ' }
  exit 0
}

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$serverDir = Join-Path $root 'server'
$adminDir  = Join-Path $root 'admin'

function Write-Step([string]$msg) {
  Write-Host "`n===== $msg =====" -ForegroundColor Cyan
}

function Test-Tool([string]$name, [string]$hint) {
  $cmd = Get-Command $name -ErrorAction SilentlyContinue
  if (-not $cmd) {
    Write-Host "[ERROR] '$name' not found - $hint" -ForegroundColor Red
    exit 1
  }
  return $cmd
}

function Invoke-NpmBuild([string]$dir, [string]$scriptName, [string]$label) {
  Write-Step "Building $label"
  if (-not (Test-Path -LiteralPath $dir)) {
    Write-Host "[ERROR] Directory not found: $dir" -ForegroundColor Red
    exit 1
  }
  Push-Location $dir
  try {
    if (-not $SkipInstall) {
      Write-Host "Installing dependencies (npm ci, falls back to npm install)..."
      if (Test-Path -LiteralPath (Join-Path $dir 'package-lock.json')) {
        npm ci --no-audit --no-fund
        if ($LASTEXITCODE -ne 0) {
          Write-Host "npm ci failed, falling back to npm install ..." -ForegroundColor Yellow
          npm install --no-audit --no-fund
        }
      } else {
        npm install --no-audit --no-fund
      }
      if ($LASTEXITCODE -ne 0) { throw "Dependency install failed: $label" }
    }
    npm run $scriptName
    if ($LASTEXITCODE -ne 0) { throw "npm run $scriptName failed: $label" }
  } finally {
    Pop-Location
  }
}

function Show-DistInfo([string]$dir, [string]$label) {
  $dist = Join-Path $dir 'dist'
  if (Test-Path -LiteralPath $dist) {
    $size = (Get-ChildItem -LiteralPath $dist -Recurse -File | Measure-Object -Property Length -Sum).Sum
    Write-Host ("[OK] {0} output: {1} ({2:N1} MB)" -f $label, $dist, ($size / 1MB)) -ForegroundColor Green
  } else {
    Write-Host "[WARN] $label did not produce a dist folder - check the build log above" -ForegroundColor Yellow
  }
}

Write-Host "Think Origin local build (Windows)" -ForegroundColor Magenta
Write-Host "Project root: $root"

# 0) environment check
Test-Tool 'node' 'Install Node.js from https://nodejs.org (22 LTS recommended)' | Out-Null
Test-Tool 'npm'  'npm is bundled with Node.js' | Out-Null
$nodeMajor = [int]((node --version) -replace '^v(\d+).*', '$1')
if ($nodeMajor -lt 20) {
  Write-Host "[ERROR] Node.js version too old (v$nodeMajor), need >= 20" -ForegroundColor Red
  exit 1
}
Write-Host "Node $(node --version) / npm $(npm --version)"

# 1) server: install deps + nest build
if (-not $SkipServer) {
  Invoke-NpmBuild -dir $serverDir -scriptName 'build' -label 'server (NestJS)'
  Show-DistInfo -dir $serverDir -label 'server'
}

# 2) admin: install deps + vue-tsc && vite build
if (-not $SkipAdmin) {
  Invoke-NpmBuild -dir $adminDir -scriptName 'build' -label 'admin (Vue3 + Vite)'
  Show-DistInfo -dir $adminDir -label 'admin'
}

# 3) optional: create server/.env from .env.example when missing
$envExample = Join-Path $serverDir '.env.example'
$envFile    = Join-Path $serverDir '.env'
if (-not (Test-Path -LiteralPath $envFile) -and (Test-Path -LiteralPath $envExample)) {
  Copy-Item -LiteralPath $envExample -Destination $envFile
  Write-Host "[INFO] Created server/.env from .env.example - adjust DB credentials if needed" -ForegroundColor Yellow
}

# 4) optional: build docker images
if ($Docker) {
  Test-Tool 'docker' 'Docker Desktop is required to build images' | Out-Null
  Write-Step "docker compose build (server + admin)"
  docker compose -f (Join-Path $root 'docker/compose.prod.yml') build
  if ($LASTEXITCODE -ne 0) { throw 'docker compose build failed' }
  Write-Host "[OK] docker-server / docker-admin images built" -ForegroundColor Green
}

# 5) summary
Write-Step "Build finished"
Write-Host "Start options:"
Write-Host "  - run server locally: npm --prefix $serverDir run start:prod"
Write-Host "  - preview admin locally: npm --prefix $adminDir run preview"
Write-Host "  - full stack with Docker: docker compose -f docker/compose.prod.yml up -d --build"
