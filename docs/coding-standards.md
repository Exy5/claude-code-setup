# Coding Standards

Single source of truth for all coding conventions. Referenced by skills and agents.

## General Principles

- **Immutability first** — mutable state is the root of most bugs
- **Minimal surface area** — expose only what's necessary
- **Fail fast** — validate at system boundaries, throw early
- **No dead code** — delete it, don't comment it out; git has history
- **No premature abstraction** — three similar lines are better than a wrong abstraction

## Java

### Naming

| Element    | Convention       | Example                |
|------------|------------------|------------------------|
| Class      | PascalCase       | `UserService`          |
| Method     | camelCase        | `findByEmail`          |
| Field      | camelCase        | `userName`             |
| Constant   | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT`      |
| Package    | lowercase        | `com.app.user.service` |
| Enum value | UPPER_SNAKE_CASE | `ORDER_PENDING`        |

### Patterns

- Constructor injection, dependencies marked `final`
- Records for DTOs: `public record UserResponse(Long id, String name) {}`, unless we work in a pre Java-16 environment. For this we go the standard approach with POJOs. Furthermore, if we use a POJO, we never expose the constructor, but instead offer a Builder as well with a Builder Pattern.
- For classes that need extra logic (special methods), we use POJOs straight away
- `Optional` for return types only — never as parameter or field
- `@Transactional` on service methods, `readOnly = true` for queries
- Custom exception hierarchy: `AppException` → `EntityNotFoundException`, etc.
- Try-with-resources for all `AutoCloseable` instances, when it makes sense
- Annotations for better documentation: `@Nonnull`, `@CheckForNull`, `@ParametersAreNonnullByDefault`
- Streams over loops where readability improves (unless performance sensitive, then choose whatever is more performant)
- No raw string concatenation for SQL — always parameterized queries
- Lombok: only `@Builder`, `@Value`, `@Slf4j` — nothing else

### Anti-Patterns

- `@Autowired` on fields
- `@Data` or `@Getter/@Setter` from Lombok
- Empty catch blocks, unless we explicitly want that behaviour — then add a comment explaining why
- Raw SQL string concatenation
- `Optional` as method parameter or field
- Business logic in controllers
- God classes (>300 lines is a smell)

### Layering

- Controller → Service → Repository (no layer skipping)
- Business logic lives in Service, never in Controller
- Repository returns entities; Service maps to DTOs

## TypeScript

### Naming

| Element   | Convention                     | Example              |
|-----------|--------------------------------|----------------------|
| Class     | PascalCase                     | `UserService`        |
| Interface | PascalCase                     | `User` (no `I` prefix) |
| Function  | camelCase                      | `formatDate`         |
| Variable  | camelCase                      | `userName`           |
| Constant  | camelCase or UPPER_SNAKE_CASE  | `maxRetries` or `MAX_RETRIES` |
| File      | kebab-case                     | `user-service.ts`    |
| Component | PascalCase                     | `UserCard.tsx`       |

### Patterns

- `strict: true` in tsconfig — always
- `interface` for object shapes, `type` for unions/intersections
- `readonly` for properties that don't change
- `unknown` + type guards instead of `any`
- Discriminated unions for complex state

### Anti-Patterns

- `any` type — ever
- `I` prefix on interfaces (`IUser`)
- `enum` — prefer `as const` objects or union types
- Non-null assertions (`!`) — handle the null case
- `var` — use `const` or `let`

## Angular-Specific

- Standalone components, no NgModules for features
- `OnPush` change detection everywhere
- `async` pipe in templates, no manual subscriptions in components
- Signals for component state (Angular 17+)
- Lazy loading for all feature routes
- `takeUntilDestroyed()` when async pipe isn't usable

## React-Specific

- Functional components only
- Props as `interface`, destructured in signature
- `useCallback` for handlers passed to children
- `useMemo` only for genuinely expensive computations
- React Query / TanStack Query for server state
- `React.memo` for components with stable props but frequent parent re-renders

## Formatting

- Let the formatter handle it (Prettier/EditorConfig)
- Don't bikeshed formatting in reviews
- Consistent is more important than "correct"
