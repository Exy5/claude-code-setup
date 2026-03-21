---
description: Quick security-focused review of a specific file or path
---

Run a focused security review on the specified target.

**Target:** $ARGUMENTS

Spawn the `reviewer-security` agent directly (without the full orchestrator) to check for:
- OWASP Top 10 vulnerabilities
- Hardcoded credentials or secrets
- SQL injection / command injection
- Authentication and authorization gaps
- Input validation issues
- XSS risks

Output a severity-sorted report with concrete fix recommendations.
