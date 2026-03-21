---
description: Scan dependencies for vulnerabilities, unused packages, and problems
---

Scan the project's dependencies for issues.

**Scope:** $ARGUMENTS

Spawn the `dependency-scanner` agent. It will:
1. Identify the dependency ecosystem (npm, Maven, Gradle, pip, etc.)
2. Run available audit tools
3. Check for vulnerabilities, unused packages, duplicates, and unpinned versions
4. Produce a severity-sorted report with recommendations

If arguments are provided, focus on that specific dependency or manifest file.
