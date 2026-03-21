#!/bin/bash
# claude-code-setup — Verify Script (Unix/WSL)
# Checks that all symlinks in ~/.claude/ are intact and point to this repo.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
ERRORS=0

check_link() {
  local link="$1"
  local expected_target="$2"
  local label="$3"

  if [ ! -L "$link" ]; then
    echo "  ✗ $label — not a symlink (missing or regular file)"
    ERRORS=$((ERRORS + 1))
    return
  fi

  local actual_target
  actual_target="$(readlink -f "$link")"
  local resolved_expected
  resolved_expected="$(readlink -f "$expected_target")"

  if [ "$actual_target" != "$resolved_expected" ]; then
    echo "  ✗ $label — points to $actual_target (expected $resolved_expected)"
    ERRORS=$((ERRORS + 1))
    return
  fi

  echo "  ✓ $label"
}

echo "Verifying claude-code-setup symlinks in $CLAUDE_DIR"
echo ""

check_link "$CLAUDE_DIR/CLAUDE.md" "$SCRIPT_DIR/global/CLAUDE.md" "CLAUDE.md"
check_link "$CLAUDE_DIR/agents" "$SCRIPT_DIR/agents" "agents/"
check_link "$CLAUDE_DIR/skills" "$SCRIPT_DIR/skills" "skills/"
check_link "$CLAUDE_DIR/commands" "$SCRIPT_DIR/commands" "commands/"
check_link "$CLAUDE_DIR/docs" "$SCRIPT_DIR/docs" "docs/"

# Check CLAUDE.local.md exists (not a symlink — it's a copy)
if [ -f "$CLAUDE_DIR/CLAUDE.local.md" ]; then
  echo "  ✓ CLAUDE.local.md (exists)"
else
  echo "  · CLAUDE.local.md not found (optional — run install.sh to create from template)"
fi

echo ""
if [ $ERRORS -eq 0 ]; then
  echo "All symlinks healthy."
else
  echo "$ERRORS broken symlink(s) found. Run install.sh to repair."
  exit 1
fi
