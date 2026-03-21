# Architecture Description for Visualization

Use this document to create SVG architecture diagrams for the README.

---

## Diagram 1: System Architecture Overview

### What to visualize

The claude-code-setup is a global configuration repo that lives on the developer's machine and is symlinked into `~/.claude/`. Claude Code automatically loads everything from `~/.claude/` at session start, making the full configuration available in any project without per-project setup.

### Components

**Source (this repo: `claude-code-setup/`):**
- `global/CLAUDE.md` — personal baseline (workflow, philosophy, kickoff questions)
- `agents/` — 9 agent definitions (orchestrator, 4 reviewers, test-writer, documenter, dependency-scanner, upgrader)
- `skills/` — 3 framework knowledge packs (Java/Spring, Angular, React), each with a concise SKILL.md and detailed reference.md
- `commands/` — 6 slash commands (/review, /test, /security, /document, /dependencies, /upgrade)
- `docs/` — single source of truth files (coding-standards.md, review-severity-scale.md)
- `templates/` — CLAUDE.local.md template for private overrides

**Target (`~/.claude/` via symlinks):**
- `CLAUDE.md` ← symlink to `global/CLAUDE.md`
- `agents/` ← symlink to `agents/`
- `skills/` ← symlink to `skills/`
- `commands/` ← symlink to `commands/`
- `docs/` ← symlink to `docs/`
- `CLAUDE.local.md` ← copied once from template (not symlinked, never committed)

**Scope Precedence (show as layered/stacked, highest on top):**
1. `CLAUDE.local.md` — private overrides (highest priority)
2. Project `.claude/CLAUDE.md` — project-specific rules
3. `~/.claude/CLAUDE.md` — personal baseline (lowest priority)

Higher scope wins on conflicts.

### Relationships

- The install script creates symlinks from the repo into `~/.claude/`
- Claude Code loads from `~/.claude/` at every session start
- Since symlinks point back to the repo, editing the repo updates the config immediately
- Skills auto-activate based on file type (globs)
- Agents and docs reference `docs/coding-standards.md` and `docs/review-severity-scale.md` as single sources of truth

---

## Diagram 2: Review Workflow (Multi-Agent)

### What to visualize

When the developer types `/review`, a multi-agent review workflow is triggered.

### Flow

1. **Developer** types `/review` (or `/review src/auth/`)
2. **Command** (`commands/review.md`) triggers the **Orchestrator** agent
3. **Orchestrator** (`orchestrator-review.md`) determines scope (changed files or specified path)
4. **Orchestrator** spawns **4 reviewer agents in parallel**:
   - `reviewer-architect` — SOLID, layering, scalability, design
   - `reviewer-security` — OWASP, injection, secrets, supply chain, IaC
   - `reviewer-quality` — code smells, naming, DRY, complexity
   - `reviewer-performance` — N+1, memory leaks, bundle size, Web Vitals
5. All 4 reviewers are **read-only** (Read, Glob, Grep tools only)
6. All 4 reviewers reference `docs/review-severity-scale.md` for consistent severity ratings
7. All 4 reviewers reference `docs/coding-standards.md` for convention checks
8. **Orchestrator** collects all reports, deduplicates, sorts by severity
9. **Orchestrator** saves the consolidated report to `reviews/<timestamp>-review.md`
10. **Developer** reviews the report and fixes issues with the main Claude session

### Severity Scale (used in report output)
- 🔴 CRITICAL — must fix before merge
- 🟠 MAJOR — should fix before merge
- 🟡 MINOR — recommended fix
- 🔵 INFO — optional suggestion
- ⚪ NIT — purely optional

---

## Diagram 3: Agent Ecosystem

### What to visualize

All 9 agents, their triggers, their tool access, and their relationships.

### Agents grouped by purpose

**Review Agents (on-demand via /review):**
- orchestrator-review — coordinates, spawns others, writes report (Read, Write, Glob, Grep, Agent)
- reviewer-architect — architecture & design (Read, Glob, Grep)
- reviewer-security — security vulnerabilities (Read, Glob, Grep)
- reviewer-quality — code quality (Read, Glob, Grep)
- reviewer-performance — runtime efficiency (Read, Glob, Grep)

**Generation Agents (automatic or on-demand):**
- test-writer — auto-spawns after code completion, writes test files (Read, Write, Glob, Grep)
- documenter — on-demand via /document, writes project docs (Read, Write, Glob, Grep)

**Maintenance Agents (on-demand):**
- dependency-scanner — on-demand via /dependencies, scans for issues (Read, Glob, Grep, Bash)
- upgrader — on-demand via /upgrade, bumps versions and fixes breaking changes (Read, Write, Glob, Grep, Bash)

### Access levels
- **Read-only:** All 4 reviewers (cannot modify code)
- **Read + Write:** test-writer, documenter, upgrader, orchestrator (can create/modify files)
- **Bash access:** dependency-scanner, upgrader (can run CLI tools like npm audit, mvn)

---

## Diagram 4: Skills Activation

### What to visualize

Skills auto-activate based on which files are being worked on. In a mixed-stack project, multiple skills can be active.

### Skills and their triggers

**java-conventions:**
- Activates for: `*.java`, `pom.xml`, `build.gradle`, `build.gradle.kts`
- Teaches: Spring Bean lifecycle, @Transactional behavior, JPA pitfalls, exception handling, testing annotations
- References `docs/coding-standards.md` for Java conventions

**angular-conventions:**
- Activates for: `*.component.ts`, `*.service.ts`, `*.module.ts`, `*.directive.ts`, `*.pipe.ts`, `angular.json`
- Teaches: Component lifecycle, signals vs RxJS, change detection, routing, RxJS operator selection
- References `docs/coding-standards.md` for Angular/TypeScript conventions

**react-conventions:**
- Activates for: `*.tsx`, `*.jsx`, `next.config.*`, `vite.config.*`
- Teaches: Hooks rules, rendering behavior, Server Components, React Query, common pitfalls
- References `docs/coding-standards.md` for React/TypeScript conventions

### Skill structure (each skill has two files)
- `SKILL.md` — concise, auto-loaded when file context matches
- `reference.md` — detailed patterns and code examples, read on demand

---

## Diagram 5: Single Source of Truth

### What to visualize

How conventions and definitions flow from centralized docs to all consumers. The key point: change once, applies everywhere.

### Sources
- `docs/coding-standards.md` — all coding conventions (Java, TypeScript, Angular, React)
- `docs/review-severity-scale.md` — severity definitions and examples

### Consumers of coding-standards.md
- `skills/java-conventions/SKILL.md` — references for Java conventions
- `skills/angular-conventions/SKILL.md` — references for Angular/TS conventions
- `skills/react-conventions/SKILL.md` — references for React/TS conventions
- `agents/reviewer-quality.md` — references for naming/convention checks
- `agents/reviewer-architect.md` — references for architectural conventions
- `agents/reviewer-security.md` — references for secure coding patterns
- `agents/reviewer-performance.md` — references for performance conventions

### Consumers of review-severity-scale.md
- `agents/orchestrator-review.md`
- `agents/reviewer-architect.md`
- `agents/reviewer-security.md`
- `agents/reviewer-quality.md`
- `agents/reviewer-performance.md`
- `agents/dependency-scanner.md`

---

## Diagram 6: Developer Workflow (Daily Usage)

### What to visualize

The typical daily workflow from starting a session to committing code.

### Flow

1. **Start session** — `cd ~/projects/my-app && claude`
   - Claude loads `~/.claude/CLAUDE.md` (global baseline)
   - Claude loads project `.claude/CLAUDE.md` (project context, if exists)
   - Claude loads `CLAUDE.local.md` (private overrides, if exists)

2. **New project?** (no `.claude/CLAUDE.md` exists)
   - Claude asks kickoff questions (purpose, stack, scale, lifespan, NFRs, deployment)
   - Writes answers to `.claude/CLAUDE.md`

3. **Work** — developer and Claude collaborate
   - Skills auto-activate based on file context
   - Claude follows ask → plan → implement sequence for non-trivial tasks

4. **Test** — after each logical unit of code is completed
   - test-writer agent auto-spawns
   - Generates tests targeting 90%+ coverage
   - Uses project-appropriate framework (JUnit, Jest, Jasmine)

5. **Review** — developer types `/review`
   - Orchestrator spawns 4 reviewers in parallel
   - Consolidated severity-sorted report saved to `reviews/`
   - Developer fixes issues with main Claude session

6. **Document** — developer types `/document` (for significant changes)
   - Documenter analyzes codebase
   - Updates `.claude/CLAUDE.md` and `.claude/docs/architecture.md`

7. **Commit** — Conventional Commits (feat:, fix:, refactor:, etc.)
