# React / TypeScript — Reference Guide

## Component with Props Interface

```tsx
interface UserCardProps {
  readonly user: User;
  readonly onSelect: (userId: number) => void;
}

export function UserCard({ user, onSelect }: UserCardProps) {
  const handleClick = useCallback(() => {
    onSelect(user.id);
  }, [user.id, onSelect]);

  return (
    <div className="user-card" onClick={handleClick}>
      <h3>{user.name}</h3>
      <p>{user.email}</p>
    </div>
  );
}
```

## Custom Hook

```tsx
interface UseUserResult {
  readonly user: User | undefined;
  readonly isLoading: boolean;
  readonly error: Error | null;
}

export function useUser(userId: number): UseUserResult {
  const { data: user, isLoading, error } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
  });

  return { user, isLoading, error };
}

// Usage
function UserProfile({ userId }: { readonly userId: number }) {
  const { user, isLoading, error } = useUser(userId);

  if (isLoading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;
  if (!user) return null;

  return <UserCard user={user} onSelect={handleSelect} />;
}
```

## Memoization — When To Use

```tsx
// GOOD — expensive computation
const sortedItems = useMemo(
  () => items.sort((a, b) => a.name.localeCompare(b.name)),
  [items]
);

// GOOD — callback passed to memoized child
const handleDelete = useCallback(
  (id: number) => mutation.mutate(id),
  [mutation]
);

// BAD — premature, simple computation
const fullName = useMemo(() => `${first} ${last}`, [first, last]);
// Just do: const fullName = `${first} ${last}`;
```

## React.memo — Preventing Re-renders

```tsx
// Use when parent re-renders frequently but props rarely change
export const ExpensiveList = React.memo(function ExpensiveList({
  items,
}: {
  readonly items: readonly Item[];
}) {
  return (
    <ul>
      {items.map(item => (
        <li key={item.id}>{item.name}</li>
      ))}
    </ul>
  );
});
```

## Context + Hook Pattern

```tsx
interface AuthContextValue {
  readonly user: User | null;
  readonly login: (credentials: Credentials) => Promise<void>;
  readonly logout: () => void;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { readonly children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);

  const login = useCallback(async (credentials: Credentials) => {
    const user = await authApi.login(credentials);
    setUser(user);
  }, []);

  const logout = useCallback(() => {
    authApi.logout();
    setUser(null);
  }, []);

  const value = useMemo(() => ({ user, login, logout }), [user, login, logout]);

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth(): AuthContextValue {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
```

## Code Splitting

```tsx
const AdminDashboard = lazy(() => import('./admin/AdminDashboard'));

function App() {
  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route
        path="/admin"
        element={
          <Suspense fallback={<Spinner />}>
            <AdminDashboard />
          </Suspense>
        }
      />
    </Routes>
  );
}
```

## Avoid Inline Objects in JSX

```tsx
// BAD — creates new object every render, breaks memo
<UserCard style={{ padding: 16 }} config={{ showAvatar: true }} />

// GOOD — stable references
const cardStyle = { padding: 16 } as const;
const cardConfig = { showAvatar: true } as const;
<UserCard style={cardStyle} config={cardConfig} />

// Or with useMemo if values are dynamic
const cardStyle = useMemo(() => ({ padding: size * 2 }), [size]);
```
