---
description: Full parallel build workflow — research, plan, implement with parallel agents, review
---

Trigger the full orchestrated development workflow for a non-trivial task.

**Task:** $ARGUMENTS

Spawn the `orchestrator-main` agent. It will:

1. **Complexity assessment** — decides how many Researchers to spawn (0–3) based on task scope
2. **Research phase** — 1–3 Researcher agents in parallel, each proposing a complete solution. Majority principle picks the approach. Skipped for trivial tasks.
3. **Plan phase** — synthesize findings into `tasks/todo.md`, architect reviews the plan, all open questions answered before any code is written
4. **Branch** — creates a feature branch (`feat/`, `fix/`, `refactor/`, `chore/`) before any implementation
5. **Implementation stream** — up to 3 Developer agents run concurrently. As soon as a task is done and its dependents are unblocked, a new agent starts immediately. Orchestrator is the sole writer of `tasks/todo.md` — track progress there.
6. **Per-task cycle** — scoped review (only relevant reviewers) → fixes → documenter → commit → next task
7. **Final review** — integration-reviewer + full `/review` (security always included) across the full changeset
8. **Corrections** — any developer corrections captured into `tasks/lessons.md` automatically

The main Claude session acts as coordinator only. All implementation is done by Developer agents.

Use `/build` for features, services, or any task complex enough to benefit from parallel execution and structured planning.

For small tasks (single file, single concern), just ask directly — no need for the full workflow.
