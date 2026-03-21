# claude-code-setup — Verify Script (Windows PowerShell)
# Checks that all symlinks/junctions in ~/.claude/ are intact.

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$Errors = 0

function Test-Symlink {
    param([string]$Link, [string]$ExpectedTarget, [string]$Label)

    if (-not (Test-Path $Link)) {
        Write-Host "  x $Label - missing"
        $script:Errors++
        return
    }

    $item = Get-Item $Link -Force
    $isLink = ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)

    if (-not $isLink) {
        Write-Host "  x $Label - not a symlink/junction"
        $script:Errors++
        return
    }

    Write-Host "  + $Label"
}

Write-Host "Verifying claude-code-setup symlinks in $ClaudeDir"
Write-Host ""

Test-Symlink -Link (Join-Path $ClaudeDir "CLAUDE.md") -ExpectedTarget (Join-Path $ScriptDir "global\CLAUDE.md") -Label "CLAUDE.md"
Test-Symlink -Link (Join-Path $ClaudeDir "agents") -ExpectedTarget (Join-Path $ScriptDir "agents") -Label "agents/"
Test-Symlink -Link (Join-Path $ClaudeDir "skills") -ExpectedTarget (Join-Path $ScriptDir "skills") -Label "skills/"
Test-Symlink -Link (Join-Path $ClaudeDir "commands") -ExpectedTarget (Join-Path $ScriptDir "commands") -Label "commands/"
Test-Symlink -Link (Join-Path $ClaudeDir "docs") -ExpectedTarget (Join-Path $ScriptDir "docs") -Label "docs/"

$LocalMd = Join-Path $ClaudeDir "CLAUDE.local.md"
if (Test-Path $LocalMd) {
    Write-Host "  + CLAUDE.local.md (exists)"
} else {
    Write-Host "  . CLAUDE.local.md not found (optional - run install.ps1 to create from template)"
}

Write-Host ""
if ($Errors -eq 0) {
    Write-Host "All symlinks healthy."
} else {
    Write-Host "$Errors broken symlink(s) found. Run install.ps1 to repair."
    exit 1
}
