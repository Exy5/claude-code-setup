---
description: Angular framework knowledge — lifecycle, reactive patterns, and component architecture
globs:
  - "**/*.component.ts"
  - "**/*.service.ts"
  - "**/*.module.ts"
  - "**/*.directive.ts"
  - "**/*.pipe.ts"
  - "**/angular.json"
---

# Angular — Framework Knowledge

For coding conventions and naming rules, see `docs/coding-standards.md`.

## Component Lifecycle

1. `constructor` — DI only, no logic
2. `ngOnInit` — initialization, data fetching
3. `ngOnChanges` — react to `@Input()` changes
4. `ngAfterViewInit` — DOM-dependent logic
5. `ngOnDestroy` — cleanup subscriptions, timers

With signals (Angular 17+), prefer `effect()` and `computed()` over lifecycle hooks.

## Signals vs RxJS

- **Signals** — synchronous, simple state: component state, form values, UI toggles
- **RxJS** — async, complex streams: HTTP, WebSockets, debounced input, combining multiple sources
- They interop: `toSignal()` wraps Observable, `toObservable()` wraps Signal

## Dependency Injection

- Prefer `inject()` function over constructor injection in Angular 17+
- `providedIn: 'root'` for app-wide singletons
- `providers: [...]` in component for component-scoped instances
- Use `InjectionToken` for non-class dependencies

## Change Detection

- `OnPush` — only re-renders when `@Input()` reference changes, signal updates, or async pipe emits
- Avoid function calls in templates — they run every change detection cycle
- `markForCheck()` when mutating state imperatively (prefer signals instead)

## Routing

- `loadComponent` / `loadChildren` for lazy loading
- Route guards: `canActivate`, `canDeactivate`, `resolve`
- Functional guards (Angular 15+): `() => inject(AuthService).isLoggedIn()`

## RxJS Operator Selection

- `switchMap` — cancel previous (search/autocomplete)
- `concatMap` — preserve order (sequential writes)
- `mergeMap` — parallel execution (independent requests)
- `exhaustMap` — ignore new while busy (form submit)
- Never nest subscribes — use operators to compose

## Common Pitfalls

- Manual `.subscribe()` in components without unsubscribe → memory leak
- `bypassSecurityTrustHtml()` with user input → XSS
- Barrel files (`index.ts`) breaking tree shaking
- Circular dependencies between services
