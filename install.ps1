# claude-code-setup — Install Script (Windows PowerShell)
# Creates symlinks from this repo into ~/.claude/ for global availability.
# Backs up existing files/folders before overwriting.
# Must be run as Administrator (symlinks require elevated privileges on Windows).

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$BackupDir = Join-Path $ClaudeDir ".backup\$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$BackedUp = $false

if (-not (Test-Path $ClaudeDir)) {
    New-Item -ItemType Directory -Path $ClaudeDir | Out-Null
}

Write-Host "Installing claude-code-setup from: $ScriptDir"
Write-Host "Target: $ClaudeDir"
Write-Host ""

# Backup helper: moves existing non-symlink file/folder to backup dir
function Backup-IfExists {
    param([string]$Target, [string]$Label)

    if (Test-Path $Target) {
        $item = Get-Item $Target -Force
        $isLink = ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)

        if (-not $isLink) {
            if (-not $script:BackedUp) {
                New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
                $script:BackedUp = $true
            }
            Move-Item $Target $BackupDir -Force
            Write-Host "  > Backed up existing $Label to $BackupDir"
        } else {
            Remove-Item $Target -Force -Recurse
        }
    }
}

# Helper: create symlink
function New-Symlink {
    param([string]$Link, [string]$Target, [string]$Type)

    if ($Type -eq "Directory") {
        New-Item -ItemType Junction -Path $Link -Target $Target | Out-Null
    } else {
        New-Item -ItemType SymbolicLink -Path $Link -Target $Target | Out-Null
    }
}

# Global CLAUDE.md
Backup-IfExists -Target (Join-Path $ClaudeDir "CLAUDE.md") -Label "CLAUDE.md"
New-Symlink -Link (Join-Path $ClaudeDir "CLAUDE.md") -Target (Join-Path $ScriptDir "global\CLAUDE.md") -Type "File"
Write-Host "  + CLAUDE.md"

# Agents
Backup-IfExists -Target (Join-Path $ClaudeDir "agents") -Label "agents/"
New-Symlink -Link (Join-Path $ClaudeDir "agents") -Target (Join-Path $ScriptDir "agents") -Type "Directory"
Write-Host "  + agents/"

# Skills
Backup-IfExists -Target (Join-Path $ClaudeDir "skills") -Label "skills/"
New-Symlink -Link (Join-Path $ClaudeDir "skills") -Target (Join-Path $ScriptDir "skills") -Type "Directory"
Write-Host "  + skills/"

# Commands
Backup-IfExists -Target (Join-Path $ClaudeDir "commands") -Label "commands/"
New-Symlink -Link (Join-Path $ClaudeDir "commands") -Target (Join-Path $ScriptDir "commands") -Type "Directory"
Write-Host "  + commands/"

# Docs
Backup-IfExists -Target (Join-Path $ClaudeDir "docs") -Label "docs/"
New-Symlink -Link (Join-Path $ClaudeDir "docs") -Target (Join-Path $ScriptDir "docs") -Type "Directory"
Write-Host "  + docs/"

# CLAUDE.local.md — copy template if not present (never overwrite)
$LocalMd = Join-Path $ClaudeDir "CLAUDE.local.md"
if (-not (Test-Path $LocalMd)) {
    Copy-Item (Join-Path $ScriptDir "templates\CLAUDE.local.md") $LocalMd
    Write-Host "  + CLAUDE.local.md (created from template - edit for private settings)"
} else {
    Write-Host "  . CLAUDE.local.md already exists (skipped)"
}

Write-Host ""
if ($BackedUp) {
    Write-Host "Backups saved to: $BackupDir"
}
Write-Host "Done. All symlinks created in $ClaudeDir"
Write-Host "Run 'verify.ps1' to check symlink health."
