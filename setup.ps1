# dotclaude setup — bootstrap the three-layer MCP stack (Windows PowerShell)
# Usage: .\setup.ps1

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectRoot

function Info($msg)  { Write-Host "[dotclaude] $msg" -ForegroundColor Green }
function Warn($msg)  { Write-Host "[dotclaude] $msg" -ForegroundColor Yellow }
function Fail($msg)  { Write-Host "[dotclaude] $msg" -ForegroundColor Red; exit 1 }

Write-Host ""
Write-Host "  dotclaude setup"
Write-Host "  ==============="
Write-Host ""

# Step 1: Check prerequisites
Info "Checking prerequisites..."
$missing = @()
if (-not (Get-Command memelord -ErrorAction SilentlyContinue))  { $missing += "memelord" }
if (-not (Get-Command codemogger -ErrorAction SilentlyContinue)) { $missing += "codemogger" }
if (-not (Get-Command npx -ErrorAction SilentlyContinue))        { $missing += "npx (Node.js)" }

if ($missing.Count -gt 0) {
    Fail "Missing: $($missing -join ', '). Install: npm install -g memelord codemogger"
}
Info "All prerequisites found."

# Step 2: Initialize memelord
if (Test-Path ".memelord") {
    Info "memelord already initialized"
} else {
    Info "Initializing memelord..."
    memelord init
    Info "memelord initialized."
}

# Step 3: Build codemogger index
Info "Building codemogger index..."
try { codemogger index . --verbose } catch { Warn "codemogger index failed — re-run manually" }
Info "codemogger index built."

# Step 4: Create CLAUDE.local.md
if (-not (Test-Path "CLAUDE.local.md")) {
    Copy-Item "CLAUDE.local.md.example" "CLAUDE.local.md" -ErrorAction SilentlyContinue
    Info "Created CLAUDE.local.md from example."
} else {
    Info "CLAUDE.local.md already exists"
}

# Step 5: Ensure .gitignore entries
$gitignore = Join-Path $ProjectRoot ".gitignore"
$entries = @("CLAUDE.local.md", ".memelord/", ".codemogger/", ".cachebro/")
foreach ($entry in $entries) {
    if (-not (Select-String -Path $gitignore -Pattern ([regex]::Escape($entry)) -Quiet -ErrorAction SilentlyContinue)) {
        Add-Content -Path $gitignore -Value $entry
    }
}
Info ".gitignore updated."

# Done
Write-Host ""
Info "Setup complete. Three-layer MCP stack ready."
Write-Host ""
Write-Host "  Layer 1 - cachebro    Token optimization (passive)"
Write-Host "  Layer 2 - codemogger  Code intelligence (semantic search)"
Write-Host "  Layer 3 - memelord    Persistent memory (automatic)"
Write-Host ""
