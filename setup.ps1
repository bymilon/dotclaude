# dotclaude setup — bootstrap the MCP stack (Windows PowerShell)
# Mirror of setup.sh — keep both scripts in sync
# Usage: .\setup.ps1 [-DryRun]

[CmdletBinding()]
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
if ($DryRun) { Write-Host "  (dry-run mode — no changes will be made)" }
Write-Host ""

# ─── Step 1: Check prerequisites ────────────────────────────────

Info "Checking prerequisites..."

$missing = @()
$optionalMissing = @()

if (-not (Get-Command bun -ErrorAction SilentlyContinue))       { $missing += "bun (https://bun.sh)" }
if (-not (Get-Command bash -ErrorAction SilentlyContinue)) {
    Warn "bash not found — hooks require Git Bash. Install Git for Windows: https://git-scm.com"
}
if (-not (Get-Command memelord  -ErrorAction SilentlyContinue)) { $optionalMissing += "memelord" }
if (-not (Get-Command codemogger -ErrorAction SilentlyContinue)){ $optionalMissing += "codemogger" }

if ($missing.Count -gt 0) {
    Fail "Missing required: $($missing -join ', '). Install bun first: https://bun.sh"
}

if ($optionalMissing.Count -gt 0) {
    Warn "Optional tools not found: $($optionalMissing -join ', ')"
    Warn "Install with: bun add -g $($optionalMissing -join ' ')"
    Warn "Continuing without them — the template still works, MCP features will be limited."
}

Info "Prerequisites checked."

# ─── Step 2: Initialize memelord ────────────────────────────────

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

# ─── Step 3: Build codemogger index ─────────────────────────────

if (Get-Command codemogger -ErrorAction SilentlyContinue) {
    if (Test-Path ".codemogger") {
        Info "codemogger index exists — rebuilding..."
    } else {
        Info "Building codemogger index (tree-sitter + vector search)..."
    }

    $fileCount = (Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\(\.git|\.memelord|\.codemogger|\.cachebro|node_modules|vendor|opensrc|rust-src)\\' }).Count

    if ($fileCount -gt 10000) {
        Warn "Large repo ($fileCount files) — indexing may take a moment..."
    }

    try {
        Run-Command { codemogger index . --verbose } "codemogger index . --verbose"
    } catch {
        try {
            Run-Command { codemogger index . } "codemogger index ."
        } catch {
            Warn "codemogger index failed — you can re-run manually"
        }
    }
    Info "codemogger index built."
} else {
    Info "codemogger not installed — skipping (code intelligence unavailable)"
}

# ─── Step 4: TypeScript — opensrc (exact-version npm source) ────

if (Test-Path "package.json") {
    Info "Fetching npm package source for AI agent context (opensrc)..."

    $tsPackages = @("hono", "zod", "drizzle-orm", "@sveltejs/kit", "@hono/zod-validator", "vite", "vitest")
    $packageJson = Get-Content "package.json" -Raw -ErrorAction SilentlyContinue
    $fetched = @()

    foreach ($pkg in $tsPackages) {
        $pkgEscaped = [regex]::Escape("`"$pkg`"")
        if ($packageJson -match $pkgEscaped) {
            $pkgShort = $pkg -replace '^@[^/]+/', ''
            if (Test-Path "opensrc\$pkgShort") {
                Info "  opensrc\$pkgShort already exists — skipping"
            } else {
                Info "  Fetching $pkg source..."
                try {
                    Run-Command { bunx opensrc $pkg } "bunx opensrc $pkg"
                    $fetched += $pkg
                } catch {
                    Warn "  opensrc $pkg failed — skipping (install manually: bunx opensrc $pkg)"
                }
            }
        }
    }

    if ($fetched.Count -gt 0) {
        Info "Fetched source for: $($fetched -join ', ')"
        Info "codemogger will index opensrc\ on next file change."
    } else {
        Info "No matching packages found in package.json — skipping opensrc."
    }
} else {
    Info "No package.json found — skipping opensrc (TypeScript step)."
}

# ─── Step 5: Rust — framework source for codemogger indexing ────

if (Test-Path "Cargo.toml") {
    Info "Fetching Rust framework source for codemogger indexing..."

    $rustCrates = @("gpui", "dioxus", "leptos", "tauri", "axum", "actix-web")
    $cargoToml  = Get-Content "Cargo.toml" -Raw -ErrorAction SilentlyContinue
    $rustFetched = @()
    $rustSrcDir  = "rust-src"

    # Ensure crates are in local registry
    try {
        Run-Command { cargo fetch --quiet } "cargo fetch --quiet"
    } catch {
        Warn "cargo fetch failed — registry may be incomplete"
    }

    if (-not (Test-Path $rustSrcDir)) {
        New-Item -ItemType Directory -Path $rustSrcDir | Out-Null
    }

    $cargoRegistryBase = "$env:USERPROFILE\.cargo\registry\src"

    foreach ($crate in $rustCrates) {
        $pattern = "`"$crate`"|$crate\s*="
        if ($cargoToml -match $pattern) {
            if (Test-Path "$rustSrcDir\$crate") {
                Info "  rust-src\$crate already exists — skipping"
            } else {
                # Find exact version in cargo registry cache
                $src = Get-ChildItem -Path $cargoRegistryBase -Recurse -Directory `
                    -Filter "$crate-*" -ErrorAction SilentlyContinue |
                    Sort-Object Name | Select-Object -Last 1

                if ($src) {
                    Run-Command {
                        Copy-Item -Path $src.FullName -Destination "$rustSrcDir\$crate" -Recurse
                    } "Copy-Item $($src.FullName) -> rust-src\$crate"
                    $rustFetched += $crate
                    Info "  Fetched $crate -> rust-src\$crate\"
                } else {
                    Warn "  $crate not found in cargo registry — run 'cargo fetch' first"
                }
            }
        }
    }

    if ($rustFetched.Count -gt 0) {
        Info "Rust source fetched: $($rustFetched -join ', ')"
        if (Get-Command codemogger -ErrorAction SilentlyContinue) {
            Info "Re-indexing codemogger to include rust-src\..."
            try {
                Run-Command { codemogger index . --quiet } "codemogger index ."
            } catch {
                Warn "codemogger reindex failed"
            }
        }
    } else {
        Info "No matching Rust framework crates found in Cargo.toml — skipping."
        $isEmpty = -not (Get-ChildItem $rustSrcDir -ErrorAction SilentlyContinue)
        if ($isEmpty -and (Test-Path $rustSrcDir)) { Remove-Item $rustSrcDir }
    }
} else {
    Info "No Cargo.toml found — skipping Rust source fetch."
}

# ─── Step 6: Create CLAUDE.local.md ─────────────────────────────

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

# ─── Step 7: Ensure .gitignore entries ──────────────────────────

$gitignore = Join-Path $ProjectRoot ".gitignore"
$entries = @("CLAUDE.local.md", ".memelord/", ".codemogger/", ".cachebro/", "opensrc/", "rust-src/")

foreach ($entry in $entries) {
    $escaped = [regex]::Escape($entry)
    if (-not (Select-String -Path $gitignore -Pattern $escaped -Quiet -ErrorAction SilentlyContinue)) {
        if ($DryRun) {
            Write-Host "  [dry-run] would append '$entry' to .gitignore" -ForegroundColor Yellow
        } else {
            Add-Content -Path $gitignore -Value $entry
        }
    }
}
Info ".gitignore verified."

# ─── Step 8: Set hook permissions (Windows) ─────────────────────

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

# ─── Done ────────────────────────────────────────────────────────

Write-Host ""
Info "Setup complete. Your MCP stack is ready:"
Write-Host ""
Write-Host "  Layer 1 — cachebro    Token optimization (passive, always on)"
Write-Host "  Layer 2 — codemogger  Code intelligence (semantic + FTS search)"
Write-Host "  Layer 3 — memelord    Persistent memory (automatic via hooks)"
Write-Host "  Layer 4 — context-mode  Context window management (active)"
Write-Host ""
Write-Host "  Source context:"
Write-Host "    opensrc\   npm package source at exact locked versions (TypeScript)"
Write-Host "    rust-src\  Rust framework source indexed by codemogger"
Write-Host ""
Write-Host "  Commands available:"
Write-Host "    /onboard   — discover this project"
Write-Host "    /kickoff   — start a new feature"
Write-Host "    /feature   — implement a vertical slice"
Write-Host "    /fix       — diagnose and fix a bug"
Write-Host "    /debug     — systematic fault isolation"
Write-Host "    /ship      — lint, test, commit, push"
Write-Host "    /deploy    — environment-first deployment"
Write-Host "    /review    — parallel 3-agent code review"
Write-Host "    /debate    — red/blue adversarial design review"
Write-Host "    /consensus      — stochastic ensemble for architecture decisions"
Write-Host "    /status         — health dashboard"
Write-Host "    /memory-review  — audit and prune both memory layers"
Write-Host ""

if ($optionalMissing.Count -gt 0) {
    Warn "Reminder: install optional tools for full functionality:"
    Warn "  bun add -g $($optionalMissing -join ' ')"
    Write-Host ""
}
