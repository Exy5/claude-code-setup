#!/bin/bash
# claude-code-setup — Install Script (Unix/WSL)
# Symlinks configuration into ~/.claude/ for global availability.
# Backs up existing files/folders before overwriting.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/.backup/$(date +%Y%m%d-%H%M%S)"
BACKED_UP=false

mkdir -p "$CLAUDE_DIR"

echo "Installing claude-code-setup from: $SCRIPT_DIR"
echo "Target: $CLAUDE_DIR"
echo ""

# Backup helper: moves existing non-symlink file/folder to backup dir
backup_if_exists() {
  local target="$1"
  local label="$2"

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    if [ "$BACKED_UP" = false ]; then
      mkdir -p "$BACKUP_DIR"
      BACKED_UP=true
    fi
    mv "$target" "$BACKUP_DIR/"
    echo "  ↗ Backed up existing $label to $BACKUP_DIR/"
  elif [ -L "$target" ]; then
    rm "$target"
  fi
}

# Global CLAUDE.md
backup_if_exists "$CLAUDE_DIR/CLAUDE.md" "CLAUDE.md"
ln -sf "$SCRIPT_DIR/global/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
echo "  ✓ CLAUDE.md"

# Agents
backup_if_exists "$CLAUDE_DIR/agents" "agents/"
ln -sf "$SCRIPT_DIR/agents" "$CLAUDE_DIR/agents"
echo "  ✓ agents/"

# Skills
backup_if_exists "$CLAUDE_DIR/skills" "skills/"
ln -sf "$SCRIPT_DIR/skills" "$CLAUDE_DIR/skills"
echo "  ✓ skills/"

# Commands
backup_if_exists "$CLAUDE_DIR/commands" "commands/"
ln -sf "$SCRIPT_DIR/commands" "$CLAUDE_DIR/commands"
echo "  ✓ commands/"

# Docs
backup_if_exists "$CLAUDE_DIR/docs" "docs/"
ln -sf "$SCRIPT_DIR/docs" "$CLAUDE_DIR/docs"
echo "  ✓ docs/"

# CLAUDE.local.md — copy template if not present (never overwrite)
if [ ! -f "$CLAUDE_DIR/CLAUDE.local.md" ]; then
  cp "$SCRIPT_DIR/templates/CLAUDE.local.md" "$CLAUDE_DIR/CLAUDE.local.md"
  echo "  ✓ CLAUDE.local.md (created from template — edit for private settings)"
else
  echo "  · CLAUDE.local.md already exists (skipped)"
fi

echo ""
if [ "$BACKED_UP" = true ]; then
  echo "Backups saved to: $BACKUP_DIR"
fi
echo "Done. All symlinks created in $CLAUDE_DIR"
echo "Run 'verify.sh' to check symlink health."
