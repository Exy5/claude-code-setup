# Java / Spring Boot — Reference Guide

## Constructor Injection Pattern

```java
@Service
@Slf4j
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    // Explicit constructor — @Autowired not needed with single constructor
    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }
}
```

Or with Lombok:

```java
@Service
@Slf4j
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
}
```

## Record DTOs

```java
public record UserResponse(
    Long id,
    String name,
    String email,
    Instant createdAt
) {}

public record CreateUserRequest(
    @NotBlank String name,
    @Email String email,
    @Size(min = 8) String password
) {}
```

## Optional Usage

```java
// Correct — return type
public Optional<User> findByEmail(String email) {
    return userRepository.findByEmail(email);
}

// Correct — consuming
User user = userService.findByEmail(email)
    .orElseThrow(() -> new UserNotFoundException(email));

// WRONG — never as parameter
public void process(Optional<String> name) { ... }
```

## Exception Hierarchy

```java
public abstract class AppException extends RuntimeException {
    protected AppException(String message) {
        super(message);
    }
}

public class EntityNotFoundException extends AppException {
    public EntityNotFoundException(String entity, Object id) {
        super("%s not found with id: %s".formatted(entity, id));
    }
}
```

## Global Exception Handler

```java
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(EntityNotFoundException ex) {
        log.warn("Entity not found: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(new ErrorResponse(ex.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException ex) {
        String message = ex.getBindingResult().getFieldErrors().stream()
            .map(e -> e.getField() + ": " + e.getDefaultMessage())
            .collect(Collectors.joining(", "));
        return ResponseEntity.badRequest()
            .body(new ErrorResponse(message));
    }
}
```

## Transaction Best Practices

```java
@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final PaymentService paymentService;

    // Read-only — optimizes DB connection
    @Transactional(readOnly = true)
    public OrderResponse getOrder(Long id) {
        return orderRepository.findById(id)
            .map(OrderMapper::toResponse)
            .orElseThrow(() -> new EntityNotFoundException("Order", id));
    }

    // Write — minimal scope
    @Transactional
    public OrderResponse createOrder(CreateOrderRequest request) {
        Order order = OrderMapper.toEntity(request);
        order = orderRepository.save(order);
        paymentService.initiate(order); // Consider: should this be in the same TX?
        return OrderMapper.toResponse(order);
    }
}
```

## N+1 Query Prevention

```java
// BAD — triggers N+1
List<Order> orders = orderRepository.findAll();
orders.forEach(o -> o.getItems().size()); // lazy load per order

// GOOD — JOIN FETCH
@Query("SELECT o FROM Order o JOIN FETCH o.items WHERE o.status = :status")
List<Order> findByStatusWithItems(@Param("status") OrderStatus status);

// GOOD — @EntityGraph
@EntityGraph(attributePaths = {"items", "customer"})
List<Order> findByStatus(OrderStatus status);
```

## String Concatenation in Loops

```java
// BAD
String result = "";
for (String item : items) {
    result += item + ", ";
}

// GOOD
StringBuilder sb = new StringBuilder();
for (String item : items) {
    sb.append(item).append(", ");
}

// BETTER — Streams
String result = items.stream().collect(Collectors.joining(", "));
```

## Try-With-Resources

```java
// Always use try-with-resources for AutoCloseable resources
try (var input = new FileInputStream(path);
     var reader = new BufferedReader(new InputStreamReader(input))) {
    return reader.lines().collect(Collectors.toList());
}
```
