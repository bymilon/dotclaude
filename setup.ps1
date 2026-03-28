# dotclaude setup — bootstrap the three-layer MCP stack (Windows PowerShell)
# Mirror of setup.sh — keep both scripts in sync
# Usage: .\setup.ps1 [-DryRun]

param(
    [switch]$DryRun,
    [switch]$Help
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ProjectRoot

function Info($msg)  { Write-Host "[dotclaude] $msg" -ForegroundColor Green }
function Warn($msg)  { Write-Host "[dotclaude] $msg" -ForegroundColor Yellow }
function Fail($msg)  { Write-Host "[dotclaude] $msg" -ForegroundColor Red; exit 1 }

function Run-Command {
    param([scriptblock]$Command, [string]$Description)
    if ($DryRun) {
        Write-Host "  [dry-run] would run: $Description" -ForegroundColor Yellow
    } else {
        & $Command
    }
}

if ($Help) {
    Write-Host "Usage: .\setup.ps1 [-DryRun]"
    Write-Host "  -DryRun  Preview actions without executing them"
    exit 0
}

Write-Host ""
Write-Host "  dotclaude setup"
Write-Host "  ==============="
if ($DryRun) {
    Write-Host "  (dry-run mode — no changes will be made)"
}
Write-Host ""

# Step 1: Check prerequisites
Info "Checking prerequisites..."

$missing = @()
$optionalMissing = @()

if (-not (Get-Command npx -ErrorAction SilentlyContinue)) { $missing += "npx (Node.js)" }
if (-not (Get-Command memelord -ErrorAction SilentlyContinue)) { $optionalMissing += "memelord" }
if (-not (Get-Command codemogger -ErrorAction SilentlyContinue)) { $optionalMissing += "codemogger" }

if ($missing.Count -gt 0) {
    Fail "Missing required: $($missing -join ', '). Install Node.js first."
}

if ($optionalMissing.Count -gt 0) {
    Warn "Optional tools not found: $($optionalMissing -join ', ')"
    Warn "Install with: npm install -g $($optionalMissing -join ' ')"
    Warn "Continuing without them — the template still works, MCP features will be limited."
}

Info "Prerequisites checked."

# Step 2: Initialize memelord
if (Get-Command memelord -ErrorAction SilentlyContinue) {
    if (Test-Path ".memelord") {
        Info "memelord already initialized — skipping"
    } else {
        Info "Initializing memelord (per-project vector memory)..."
        Run-Command { memelord init } "memelord init"
        Info "memelord initialized."
    }
} else {
    Info "memelord not installed — skipping (memory features unavailable)"
}

# Step 3: Build codemogger index
if (Get-Command codemogger -ErrorAction SilentlyContinue) {
    if (Test-Path ".codemogger") {
        Info "codemogger index exists — rebuilding..."
    } else {
        Info "Building codemogger index (tree-sitter + vector search)..."
    }

    $fileCount = (Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\(\.git|\.memelord|\.codemogger|\.cachebro|node_modules|vendor)\\' }).Count

    if ($fileCount -gt 10000) {
        Warn "Large repo ($fileCount files) — indexing may take a moment..."
    }

    try {
        Run-Command { codemogger index . --verbose } "codemogger index . --verbose"
    } catch {
        Warn "codemogger index failed — you can re-run manually"
    }
    Info "codemogger index built."
} else {
    Info "codemogger not installed — skipping (code intelligence unavailable)"
}

# Step 4: Create CLAUDE.local.md
if (Test-Path "CLAUDE.local.md") {
    Info "CLAUDE.local.md already exists — skipping"
} else {
    if ($DryRun) {
        Write-Host "  [dry-run] would copy CLAUDE.local.md.example -> CLAUDE.local.md" -ForegroundColor Yellow
    } else {
        Copy-Item "CLAUDE.local.md.example" "CLAUDE.local.md" -ErrorAction SilentlyContinue
    }
    Info "Created CLAUDE.local.md from example."
}

# Step 5: Ensure .gitignore entries
$gitignore = Join-Path $ProjectRoot ".gitignore"
$entries = @("CLAUDE.local.md", ".memelord/", ".codemogger/", ".cachebro/")
foreach ($entry in $entries) {
    if (-not (Select-String -Path $gitignore -Pattern ([regex]::Escape($entry)) -Quiet -ErrorAction SilentlyContinue)) {
        if ($DryRun) {
            Write-Host "  [dry-run] would append '$entry' to .gitignore" -ForegroundColor Yellow
        } else {
            Add-Content -Path $gitignore -Value $entry
        }
    }
}
Info ".gitignore verified."

# Step 6: Set hook permissions (Windows — mark as not read-only)
$hookDir = Join-Path $ProjectRoot ".claude\hooks"
if (Test-Path $hookDir) {
    if ($DryRun) {
        Write-Host "  [dry-run] would remove read-only from .claude\hooks\*.sh" -ForegroundColor Yellow
    } else {
        Get-ChildItem "$hookDir\*.sh" -ErrorAction SilentlyContinue | ForEach-Object {
            $_.IsReadOnly = $false
        }
    }
}
Info "Hook scripts configured."

# Done
Write-Host ""
Info "Setup complete. Your three-layer MCP stack is ready:"
Write-Host ""
Write-Host "  Layer 1 — cachebro    Token optimization (passive, always on)"
Write-Host "  Layer 2 — codemogger  Code intelligence (semantic search)"
Write-Host "  Layer 3 — memelord    Persistent memory (automatic via hooks)"
Write-Host ""
Write-Host "  Commands available:"
Write-Host "    /onboard   — discover this project"
Write-Host "    /kickoff   — start a new feature"
Write-Host "    /ship      — lint, test, commit, push"
Write-Host "    /review    — code review pipeline"
Write-Host "    /status    — health dashboard"
Write-Host ""

if ($optionalMissing.Count -gt 0) {
    Warn "Reminder: install optional tools for full functionality:"
    Warn "  npm install -g $($optionalMissing -join ' ')"
    Write-Host ""
}
