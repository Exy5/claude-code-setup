---
description: React framework knowledge — hooks, rendering, and component patterns
globs:
  - "**/*.tsx"
  - "**/*.jsx"
  - "**/next.config.*"
  - "**/vite.config.*"
---

# React — Framework Knowledge

For coding conventions and naming rules, see `docs/coding-standards.md`.

## Hooks Rules

1. Only call hooks at the top level — never inside loops, conditions, or nested functions
2. Only call hooks from React function components or custom hooks
3. Custom hooks must start with `use`

## Rendering Behavior

- React re-renders a component when its state changes or its parent re-renders
- Props are compared by reference, not deep equality
- `React.memo` skips re-render if props haven't changed (shallow compare)
- Inline objects/functions in JSX create new references every render → breaks memoization

## Hook Selection Guide

- `useState` — simple local state
- `useReducer` — complex state with multiple sub-values or next-state-depends-on-previous
- `useEffect` — side effects (data fetching, subscriptions, DOM manipulation)
- `useCallback` — memoize functions passed as props to memoized children
- `useMemo` — memoize expensive computations
- `useRef` — mutable value that doesn't trigger re-render, or DOM references
- `useContext` — consume context values

## Server State Management

- Use React Query / TanStack Query for API data — don't store server state in `useState`
- Handles caching, deduplication, background refetching, optimistic updates
- `staleTime` vs `gcTime` — understand when data is refetched vs garbage collected

## React 18+ Patterns

- `Suspense` — declarative loading states
- `startTransition` — mark non-urgent state updates to keep UI responsive
- `useDeferredValue` — defer re-rendering expensive components
- Automatic batching — multiple `setState` calls in one render

## Next.js Considerations

- Server Components (default) vs Client Components (`'use client'`)
- Server Components: no hooks, no browser APIs, can be async
- Client Components: interactive, stateful, use hooks
- Minimize `'use client'` boundary — push it as far down as possible

## Common Pitfalls

- Missing dependency in `useEffect` dependency array → stale closures
- `useEffect` for derived state → use `useMemo` or just compute in render
- Fetching in `useEffect` without cleanup → race conditions
- Array index as `key` → broken state when items reorder
- Context value not memoized → all consumers re-render on every provider render
