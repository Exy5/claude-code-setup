# Review Severity Scale

Single source of truth for severity definitions. Referenced by all reviewer agents.

## Scale

| Level    | Symbol | Meaning                                          | Action                |
|----------|--------|--------------------------------------------------|-----------------------|
| CRITICAL | 🔴     | Security hole, data loss risk, production crash   | Must fix before merge |
| MAJOR    | 🟠     | SOLID violation, significant perf issue, bad design | Should fix before merge |
| MINOR    | 🟡     | Small smell, minor inefficiency                   | Recommended fix       |
| INFO     | 🔵     | Observation, suggestion, nice-to-have             | Optional              |
| NIT      | ⚪     | Nitpick — style preference, formatting            | Purely optional       |

## When To Use Each Level

### CRITICAL 🔴

**Security:**
- SQL injection, command injection, RCE
- Hardcoded secrets or credentials in source code
- Missing authentication on sensitive endpoint
- SSRF with user-controlled URLs (especially with cloud metadata access)
- Insecure deserialization of untrusted data (Jackson `enableDefaultTyping`, `pickle.loads()`)
- JWT `alg: none` accepted, HMAC/RSA confusion, missing signature verification
- BOLA/IDOR allowing access to other users' data
- Dependency confusion (unscoped internal packages on public registry)
- Path traversal / zip-slip with user-controlled paths
- Prototype pollution with user input flowing into deep merge
- ReDoS on user-facing input with catastrophic backtracking regex

**Stability:**
- Resource leak that will crash production (unclosed connections in a loop)
- Data corruption risk (race condition on shared mutable state)
- Unhandled null/undefined on critical path causing runtime crash
- Memory leak in a long-running service

### MAJOR 🟠

**Architecture:**
- Controller directly accessing Repository (skipping Service layer)
- Circular dependency between modules
- SOLID violation with tangible impact (God class, broken SRP)

**Performance:**
- N+1 query on a high-traffic endpoint
- Missing pagination on unbounded query
- Observable/Promise leak (missing unsubscribe, missing cleanup)

**Security:**
- Missing authorization check on a non-critical endpoint
- XSS vulnerability in low-traffic area
- Sensitive data in logs
- Mass assignment vulnerability
- Overly permissive CORS (especially with `Allow-Credentials: true`)
- GraphQL without query depth/complexity limits
- Docker container running as root, secrets in Dockerfile
- CI/CD injection via unsanitized event data in workflows

**Quality:**
- `any` type in TypeScript where real typing is feasible
- Significant DRY violation (same logic in 3+ places)

### MINOR 🟡

- Magic number that should be a named constant
- Method slightly over 30 lines
- Missing `trackBy` / `track` on a small list
- Slightly broad transaction scope
- Missing `@Nonnull` / `@CheckForNull` annotations
- Minor DRY violation (duplicated in 2 places)
- Missing input validation on non-security-critical field

### INFO 🔵

- "Consider adding an index on this column"
- "This could benefit from caching"
- "A strategy pattern might simplify future extensions"
- "Consider adding rate limiting to this endpoint"
- "Missing Content-Security-Policy header"

### NIT ⚪

- Import ordering preference
- Blank line placement
- Field ordering in a DTO
- Minor naming preference within conventions

## Output Format

```
🔴 CRITICAL [security] — AuthService.java:42
   Raw SQL concatenation with user input. Use parameterized queries.

🟠 MAJOR [architect] — UserController.java:15
   Controller directly accesses Repository, bypassing Service layer.

🟡 MINOR [quality] — UserService.java:88
   Magic number 30 — extract to named constant MAX_LOGIN_ATTEMPTS.

🔵 INFO [performance] — UserRepository.java:22
   Consider adding an index on email column for frequent lookups.

⚪ NIT [quality] — UserDto.java:3
   Field ordering: consider grouping required fields before optional.
```
