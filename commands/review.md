---
description: Trigger a full code review with all 4 reviewer agents in parallel
---

Run a comprehensive code review by spawning the `orchestrator-review` agent.

**Scope:** $ARGUMENTS

If no arguments are provided, review all recently changed files (staged + unstaged).
If a path is provided, review only that path.

Spawn the `orchestrator-review` agent with the scope above. It will coordinate all 4 reviewers (architect, security, quality, performance) in parallel and produce a consolidated, severity-sorted report.
