# Architecture Description for Visualization

Use this document to generate SVG diagrams for the README. Each section describes one diagram.

---

## Diagram 1: System Architecture Overview

### What to visualize

The repo lives on the developer's machine and is symlinked into `~/.claude/`. Claude Code loads everything from `~/.claude/` at session start, making the full configuration available in every project.

### Components

**Source repo (`claude-code-setup/`):**
- `global/CLAUDE.md` — workflow, philosophy, kickoff questions
- `agents/` — 13 agent definitions
- `skills/` — 3 framework knowledge packs (Java, Angular, React)
- `commands/` — 7 slash commands
- `docs/` — single source of truth (coding standards, severity scale)
- `templates/` — task and local override templates

**Target (`~/.claude/` via symlinks):**
- `CLAUDE.md` ← symlink → `global/CLAUDE.md`
- `agents/` ← symlink → `agents/`
- `skills/` ← symlink → `skills/`
- `commands/` ← symlink → `commands/`
- `docs/` ← symlink → `docs/`
- `CLAUDE.local.md` ← copied once from template (never symlinked, never committed)

**Scope Precedence (layered, highest on top):**
1. `CLAUDE.local.md` — private overrides
2. Project `.claude/CLAUDE.md` — project-specific rules
3. `~/.claude/CLAUDE.md` — personal baseline

Higher scope wins on conflict.

### Key relationships
- Editing repo files takes effect immediately (symlinks — no reinstall needed)
- Skills auto-activate by file type (globs match current file being edited)
- All agents and skills reference `docs/` as single source of truth

---

## Diagram 2: Build Workflow (`/build`)

### What to visualize

The full orchestrated development lifecycle triggered by `/build <task>`. The main Claude session is a pure coordinator — it never writes code.

### Flow (show as a vertical swimlane or flowchart)

```
Developer types: /build <task description>
        │
        ▼
┌─────────────────────────────────────────────────────┐
│  orchestrator-main                                   │
│  Phase 0: Clarification (ALWAYS first)               │
│                                                     │
│  Ask all open questions before anything else:        │
│  → What exactly needs to be built?                  │
│  → Tech stack / constraints?                        │
│  → Does this touch existing code or is it greenfield?│
│  → Any non-functional requirements? (perf, scale)   │
│  → Any preferences on approach or patterns?         │
│                                                     │
│  Keep asking until NOTHING is unclear.              │
│  Only proceed when developer has answered fully.    │
└─────────────────────────────────────────────────────┘
        │
        ▼ Phase 1: Complexity Assessment
┌─────────────────────────────────────────────┐
│  Based on clarified requirements:            │
│  → trivial: skip research entirely          │
│  → moderate: spawn 1 researcher             │
│  → complex: spawn 2 researchers             │
│  → highly complex: spawn 3 researchers      │
└─────────────────────────────────────────────┘
        │
        ▼ Phase 2: Research (0–3 agents, based on above)
┌──────────────────────────────────────────────┐
│  1–3 Researcher agents spawn in PARALLEL      │
│  Each independently analyzes the full problem │
│  and proposes a complete solution             │
│                                              │
│  researcher 1 ──┐                            │
│  researcher 2 ──┼──► majority principle      │
│  researcher 3 ──┘    → winning approach      │
└──────────────────────────────────────────────┘
        │
        ▼ Synthesize into tasks/todo.md (orchestrator writes)
        │
        ▼ Phase 3: Architect Review
┌──────────────────────────────────────────────┐
│  reviewer-architect reviews tasks/todo.md     │
│  → concerns and remaining questions surfaced  │
│  → fundamental flaw? re-research             │
│  → STOP: present any remaining questions     │
│  → proceed only when fully resolved          │
│  → branch name determined (feat/fix/etc.)    │
└──────────────────────────────────────────────┘
        │
        ▼ Phase 3: Branch + Implementation Stream
┌──────────────────────────────────────────────────────┐
│  git checkout -b feat/<name>                          │
│                                                      │
│  Max 3 Developer agents running concurrently          │
│  Orchestrator assigns tasks, agents report back       │
│  Orchestrator is sole writer of tasks/todo.md         │
│                                                      │
│  developer A ──► reports done ──► review cycle ──►┐  │
│  developer B ──► reports done ──► review cycle ──►┤  │
│  developer C ──► reports done ──► review cycle ──►┘  │
│                                                      │
│  Per-task cycle (orchestrator coordinates):          │
│  1. Scoped review (only relevant reviewers)          │
│     → quality: always                               │
│     → security: if endpoints/auth/input             │
│     → performance: if DB/loops/rendering            │
│     → architect: if new classes/cross-layer         │
│     → CRITICAL/MAJOR: back to developer to fix      │
│     → MINOR/INFO/NIT: note in tasks/todo.md         │
│  2. Spawn documenter (parallel with next task)       │
│  3. Commit (Conventional Commit, one per task)       │
│  4. Update tasks/todo.md status + Progress           │
│  5. Next unblocked task → fill free slot             │
└──────────────────────────────────────────────────────┘
        │
        ▼ Phase 4: Final Review
┌──────────────────────────────────────────────┐
│  integration-reviewer (cross-cutting)  ──────┤ parallel
│  orchestrator-review (full /review)    ──────┘
│  → security always covered                   │
│  → FAIL: targeted developer fixes            │
│  → PASS: report to developer                 │
│          + merge instructions                │
└──────────────────────────────────────────────┘
        │
        ▼ Phase 5: Self-Improvement
┌──────────────────────────────────────────────┐
│  Any corrections from developer during build  │
│  → written to tasks/lessons.md               │
│  → categorized by language/domain            │
│  → suggest promoting to coding-standards.md  │
└──────────────────────────────────────────────┘
```

### Key design points to highlight
- Dynamic researcher count (0–3) based on complexity — no wasted tokens on trivial tasks
- Orchestrator is the sole writer of `tasks/todo.md` — no race conditions
- Implementation is a stream — finished task unblocks dependents immediately, no batch waiting
- Scoped reviews per task — only relevant reviewers spawned
- Full `/review` always runs at the end — security is never skipped
- Feature branch always created — clean rollback path, Conventional Commit naming
- Progress visible in `tasks/todo.md` — developer can track without interrupting the workflow
- Corrections captured into `tasks/lessons.md` automatically

---

## Diagram 3: Agent Ecosystem

### What to visualize

All 13 agents, grouped by purpose, with their tool access level and trigger mechanism.

### Build Workflow Agents (triggered by `/build`)
- **orchestrator-main** — master coordinator. Tools: Read, Write, Glob, Grep, Agent. Never writes code.
- **researcher** — full-problem analysis. 3 spawned in parallel. Tools: Read-only.
- **developer** — implements one task + writes tests. Tools: Read, Write, Glob, Grep, Bash.
- **integration-reviewer** — post-build cross-cutting check. Tools: Read-only + Bash (for compile checks).

### Review Agents (triggered by `/review`)
- **orchestrator-review** — coordinates reviewers, saves report. Tools: Read, Write, Glob, Grep, Agent.
- **reviewer-architect** — SOLID, layering, scalability. Tools: Read-only.
- **reviewer-security** — OWASP, secrets, auth, supply chain, IaC. Tools: Read-only.
- **reviewer-quality** — code smells, naming, DRY. Tools: Read-only.
- **reviewer-performance** — N+1, leaks, bundle size, Web Vitals. Tools: Read-only.

### Utility Agents
- **documenter** — auto after each build task + on-demand via `/document`. Tools: Read, Write, Glob, Grep.
- **test-writer** — manual only via `/test` for existing code. Tools: Read, Write, Glob, Grep.
- **dependency-scanner** — on-demand via `/dependencies`. Tools: Read-only + Bash.
- **upgrader** — on-demand via `/upgrade`. Tools: Read, Write, Glob, Grep, Bash.

### Access level grouping (for visual legend)
- **Read-only:** researcher, reviewer-architect, reviewer-security, reviewer-quality, reviewer-performance, integration-reviewer (+ Bash)
- **Read + Write:** orchestrator-main, orchestrator-review, documenter, test-writer
- **Read + Write + Bash:** developer, upgrader, dependency-scanner (read + Bash)

---

## Diagram 4: Review Workflow (`/review`)

### What to visualize

The focused multi-agent code review triggered manually by the developer.

### Flow

1. Developer types `/review` (or `/review src/auth/`)
2. `commands/review.md` triggers `orchestrator-review`
3. Orchestrator determines scope (recent changes or specified path)
4. Orchestrator spawns all 4 reviewers **in parallel**:
   - `reviewer-architect` — reads `docs/coding-standards.md` + `docs/review-severity-scale.md`
   - `reviewer-security` — reads `docs/review-severity-scale.md`
   - `reviewer-quality` — reads `docs/coding-standards.md` + `docs/review-severity-scale.md`
   - `reviewer-performance` — reads `docs/review-severity-scale.md`
5. All reviewers are read-only — cannot modify code
6. Orchestrator collects all reports, deduplicates, sorts by severity (CRITICAL first)
7. Orchestrator saves consolidated report to `reviews/<timestamp>-review.md`
8. Developer reads report, fixes issues with main Claude session

### Severity levels in report output
- 🔴 CRITICAL — must fix before merge
- 🟠 MAJOR — should fix before merge
- 🟡 MINOR — recommended fix
- 🔵 INFO — optional suggestion
- ⚪ NIT — purely optional

---

## Diagram 5: Skills Activation

### What to visualize

Skills auto-activate based on which file type is currently being worked on. Multiple skills can be active simultaneously in mixed-stack projects.

### Skills and their file triggers

**java-conventions:**
- Activates for: `*.java`, `pom.xml`, `build.gradle`, `build.gradle.kts`
- Framework knowledge: Spring Bean lifecycle, @Transactional rules, JPA pitfalls, exception hierarchy patterns
- References `docs/coding-standards.md` for Java naming and pattern conventions

**angular-conventions:**
- Activates for: `*.component.ts`, `*.service.ts`, `*.module.ts`, `*.directive.ts`, `*.pipe.ts`, `angular.json`
- Framework knowledge: signals vs RxJS, OnPush change detection, component lifecycle, routing, takeUntilDestroyed
- References `docs/coding-standards.md` for Angular/TypeScript conventions

**react-conventions:**
- Activates for: `*.tsx`, `*.jsx`, `next.config.*`, `vite.config.*`
- Framework knowledge: hooks rules, rendering behavior, Server vs Client Components, React Query, memoization
- References `docs/coding-standards.md` for React/TypeScript conventions

### Skill structure (per skill folder)
- `SKILL.md` — concise knowledge, auto-loaded when file type matches
- `reference.md` — detailed patterns and code examples, read on demand

---

## Diagram 6: Developer Workflow (Daily Usage)

### What to visualize

Two parallel paths: the simple direct path for small tasks, and the `/build` orchestrated path for complex ones.

### Simple task flow
1. `cd ~/projects/my-app && claude`
2. Claude loads: `~/.claude/CLAUDE.md` → project `.claude/CLAUDE.md` → `CLAUDE.local.md`
3. **New project?** Claude asks kickoff questions → writes `.claude/CLAUDE.md`
4. Developer asks Claude directly — ask → plan → implement
5. Skills activate by file type
6. `/review` before committing
7. Developer writes Conventional Commit

### Complex task flow (`/build`)
1. Developer types `/build <task description>`
2. Full orchestrated workflow runs (see Diagram 2)
3. Commits happen automatically per task
4. Integration review runs at the end
5. Developer reviews summary report

### On-demand commands (anytime)
- `/review` — full code review before a PR
- `/security <file>` — focused security check
- `/document` — update project architecture docs
- `/dependencies` — scan dependency health
- `/upgrade` — upgrade deps with breaking change handling
- `/test <file>` — generate tests for existing code

---

## Diagram 7: Single Source of Truth

### What to visualize

How conventions and definitions flow from two centralized docs to all consumers. The point: change once, applies everywhere.

### Source files
- `docs/coding-standards.md` — all coding conventions (Java, TypeScript, Angular, React)
- `docs/review-severity-scale.md` — severity definitions used by all reviewers

### Consumers of `docs/coding-standards.md`
- `skills/java-conventions/SKILL.md`
- `skills/angular-conventions/SKILL.md`
- `skills/react-conventions/SKILL.md`
- `agents/developer.md` — follows standards when implementing
- `agents/reviewer-quality.md` — checks naming, patterns, anti-patterns
- `agents/reviewer-architect.md` — checks architectural conventions
- `agents/reviewer-security.md` — checks secure coding patterns
- `agents/reviewer-performance.md` — checks performance conventions

### Consumers of `docs/review-severity-scale.md`
- `agents/orchestrator-review.md`
- `agents/orchestrator-main.md` (for per-task review cycles)
- `agents/reviewer-architect.md`
- `agents/reviewer-security.md`
- `agents/reviewer-quality.md`
- `agents/reviewer-performance.md`
- `agents/integration-reviewer.md`
- `agents/dependency-scanner.md`
