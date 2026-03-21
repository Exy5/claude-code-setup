---
description: Analyze the project and generate architecture documentation
---

Analyze the current project and generate persistent documentation for future sessions.

**Scope:** $ARGUMENTS

Spawn the `documenter` agent. It will:
1. Analyze the project structure, architecture, and patterns
2. Write/update `.claude/CLAUDE.md` with a concise project overview
3. Create `.claude/docs/architecture.md` with detailed architecture documentation
4. Surface inconsistencies, concerns, and suggestions

If arguments are provided, focus the documentation on that specific area.
If no arguments, document the entire project.
