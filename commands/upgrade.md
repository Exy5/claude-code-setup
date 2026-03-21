---
description: Upgrade dependencies and handle breaking changes
---

Upgrade project dependencies to their latest versions.

**Target:** $ARGUMENTS

Spawn the `upgrader` agent. It will:
1. Check for outdated dependencies
2. Assess risk per upgrade (patch/minor/major)
3. Present an upgrade plan for approval
4. Apply upgrades one at a time, fixing breaking changes and running tests

If a specific dependency is provided (e.g., `/upgrade angular`), upgrade only that one.
If no argument, analyze all outdated dependencies and propose a full upgrade plan.
