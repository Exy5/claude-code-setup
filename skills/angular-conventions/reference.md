# Angular / TypeScript — Reference Guide

## Standalone Component

```typescript
@Component({
  selector: 'app-user-list',
  standalone: true,
  imports: [CommonModule, RouterLink],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <ul>
      @for (user of users(); track user.id) {
        <li><a [routerLink]="['/users', user.id]">{{ user.name }}</a></li>
      }
    </ul>
  `,
})
export class UserListComponent {
  private readonly userService = inject(UserService);
  readonly users = toSignal(this.userService.getAll());
}
```

## Service with RxJS

```typescript
@Injectable({ providedIn: 'root' })
export class UserService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = '/api/users';

  getAll(): Observable<User[]> {
    return this.http.get<User[]>(this.apiUrl);
  }

  getById(id: number): Observable<User> {
    return this.http.get<User>(`${this.apiUrl}/${id}`);
  }

  create(request: CreateUserRequest): Observable<User> {
    return this.http.post<User>(this.apiUrl, request);
  }
}
```

## Async Pipe Usage

```typescript
// GOOD — async pipe handles subscribe/unsubscribe
@Component({
  template: `
    @if (user$ | async; as user) {
      <h1>{{ user.name }}</h1>
    }
  `,
})
export class UserDetailComponent {
  readonly user$ = inject(ActivatedRoute).params.pipe(
    switchMap(params => inject(UserService).getById(+params['id']))
  );
}

// BAD — manual subscribe leaks memory
export class BadComponent implements OnInit {
  user?: User;
  ngOnInit() {
    this.userService.getById(this.id).subscribe(u => this.user = u); // LEAK
  }
}
```

## takeUntilDestroyed

```typescript
// When async pipe isn't usable (e.g., side effects)
export class NotificationService {
  private readonly destroyRef = inject(DestroyRef);

  startListening(): void {
    this.websocket.messages$.pipe(
      takeUntilDestroyed(this.destroyRef)
    ).subscribe(msg => this.showNotification(msg));
  }
}
```

## Lazy Loading Routes

```typescript
export const routes: Routes = [
  {
    path: 'users',
    loadComponent: () => import('./users/user-list.component')
      .then(m => m.UserListComponent),
  },
  {
    path: 'admin',
    loadChildren: () => import('./admin/admin.routes')
      .then(m => m.ADMIN_ROUTES),
    canActivate: [authGuard],
  },
];
```

## Signals (Angular 17+)

```typescript
@Component({
  template: `
    <input (input)="updateSearch($event)" />
    <p>Results: {{ filteredCount() }}</p>
  `,
})
export class SearchComponent {
  readonly searchTerm = signal('');
  readonly items = signal<Item[]>([]);

  readonly filteredItems = computed(() =>
    this.items().filter(item =>
      item.name.toLowerCase().includes(this.searchTerm().toLowerCase())
    )
  );

  readonly filteredCount = computed(() => this.filteredItems().length);

  updateSearch(event: Event): void {
    this.searchTerm.set((event.target as HTMLInputElement).value);
  }
}
```

## Type Guards Instead of `any`

```typescript
// BAD
function process(data: any) { ... }

// GOOD — use unknown + type guard
function isUser(value: unknown): value is User {
  return typeof value === 'object' && value !== null && 'id' in value && 'name' in value;
}

function process(data: unknown): void {
  if (isUser(data)) {
    console.log(data.name); // type-safe
  }
}
```

## trackBy for *ngFor / @for

```typescript
// Old syntax — always provide trackBy
<div *ngFor="let user of users; trackBy: trackByUserId">

trackByUserId(index: number, user: User): number {
  return user.id;
}

// New syntax (Angular 17+) — track is required
@for (user of users(); track user.id) {
  <app-user-card [user]="user" />
}
```
