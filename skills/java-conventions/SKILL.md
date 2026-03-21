---
description: Java and Spring Boot framework knowledge — lifecycle, patterns, and pitfalls
globs:
  - "**/*.java"
  - "**/pom.xml"
  - "**/build.gradle"
  - "**/build.gradle.kts"
---

# Java / Spring Boot — Framework Knowledge

For coding conventions and naming rules, see `docs/coding-standards.md`.

## Spring Bean Lifecycle

1. Bean instantiation (constructor)
2. Dependency injection (constructor args resolved)
3. `@PostConstruct` — initialization logic
4. Bean ready for use
5. `@PreDestroy` — cleanup on shutdown

Beans are singletons by default. Use `@Scope("prototype")` only when truly needed.

## @Transactional Behavior

- Proxied — only works on public methods called from outside the class
- Self-invocation (`this.method()`) bypasses the proxy — no transaction
- `readOnly = true` enables DB-level optimizations (no dirty checking)
- Default rollback: unchecked exceptions only. Use `rollbackFor` for checked exceptions.
- Keep scope minimal — don't hold DB connections during external API calls

## Spring Security Filter Chain

- Filters execute in order: CORS → CSRF → Authentication → Authorization
- `@PreAuthorize` / `@Secured` on service methods for method-level security
- Always validate both authentication (who) and authorization (what they can do)

## JPA / Hibernate Pitfalls

- Lazy loading outside transaction = `LazyInitializationException`
- `JOIN FETCH` or `@EntityGraph` to solve N+1 queries
- `@Version` for optimistic locking in concurrent scenarios
- `flush()` vs `save()` — understand when writes hit the DB
- Bidirectional relationships need `mappedBy` on one side

## Exception Handling

- `@ControllerAdvice` + `@ExceptionHandler` for centralized REST error responses
- Map exceptions to HTTP status codes consistently
- Never expose stack traces or internal details in API responses

## Testing

- `@SpringBootTest` for integration tests (full context)
- `@WebMvcTest` for controller tests (web layer only)
- `@DataJpaTest` for repository tests (JPA layer only)
- `@MockBean` to replace beans in test context
