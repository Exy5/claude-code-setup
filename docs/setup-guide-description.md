# Setup Guide Description for Visualization

Use this document to create an SVG setup/installation guide diagram for the README.

---

## Setup Flow (Step-by-Step)

### What to visualize

A linear flow diagram showing how to go from zero to a fully working setup. 6 steps, each with a clear action and result.

### Steps

**Step 1: Clone the repo**
- Action: `git clone` the repo to a permanent location (e.g., `~/claude-code-setup`)
- Result: Repo with all config files exists on the machine
- Note: Location must be permanent — symlinks will point here

**Step 2: Run install script**
- Action: `./install.sh` (Unix/WSL) or `.\install.ps1` (Windows as Admin)
- What happens internally:
  - Creates `~/.claude/` directory if it doesn't exist
  - Backs up any existing files in `~/.claude/` to `~/.claude/.backup/<timestamp>/`
  - Creates symlinks:
    - `global/CLAUDE.md` → `~/.claude/CLAUDE.md`
    - `agents/` → `~/.claude/agents/`
    - `skills/` → `~/.claude/skills/`
    - `commands/` → `~/.claude/commands/`
    - `docs/` → `~/.claude/docs/`
  - Copies `templates/CLAUDE.local.md` → `~/.claude/CLAUDE.local.md` (only if not present)
- Result: `~/.claude/` is fully populated with symlinks back to the repo

**Step 3: Verify**
- Action: `./verify.sh` or `.\verify.ps1`
- What happens: Checks each symlink exists and points to the correct target
- Result: All green checkmarks = ready to go

**Step 4: (Optional) Edit private overrides**
- Action: Edit `~/.claude/CLAUDE.local.md`
- Purpose: Add API keys, internal paths, company-specific conventions
- Note: This file is never committed (gitignored)

**Step 5: Use in any project**
- Action: `cd ~/projects/any-project && claude`
- What happens: Claude auto-loads everything from `~/.claude/`
- Result: Full configuration active — agents, skills, commands, coding standards all available
- No per-project setup needed

**Step 6: Update configuration**
- Action: Edit files in the `claude-code-setup/` repo
- What happens: Changes apply immediately via symlinks — no reinstall needed
- Note: `git pull` to get updates if using the repo on multiple machines

### Key visual elements

- Show the **symlink relationship** between the repo and `~/.claude/`
- Show that `~/.claude/` is the **bridge** — the repo is the source, Claude Code is the consumer
- Show that **any project directory** benefits from the setup without its own configuration
- Show the **backup mechanism** — existing files are saved, not destroyed
