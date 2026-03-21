# Future Improvements

Ideas for future iterations of the claude-code-setup. None of these are urgent — they should be driven by real-world usage feedback.

## Commands

### /refactor
Analyze code and propose a refactoring plan. Follows the ask → plan → implement workflow. Could scope by file, directory, or concern (e.g., `/refactor extract-service UserController.java`).

### /commit
Auto-generate Conventional Commit messages from the current diff. Could suggest splitting changes into separate commits when multiple concerns are mixed.

### /pr
Auto-generate a well-structured PR description from commit history and review reports. Include summary, changes, test plan, and link to review report if available.

## Agents

### CI/CD Setup Agent
Scaffolds GitHub Actions workflows based on the project's tech stack. Generates build, test, lint, and deploy pipelines. Adapts to the deployment target from the project kickoff context.

## Skills

- Add more skills as new frameworks are encountered (e.g., Python/Django, Go, Rust)
- Skills could be community-contributed if the repo goes public

## Parallel Development — Task Scheduler Architecture

The ultimate productivity multiplier: the main Claude session becomes a pure orchestrator that plans, splits, spawns, and reviews — but never writes code itself. Developer agents do the actual work in parallel.

### Core Architecture

```
Main Claude (Orchestrator)
  │
  ├── 1. Ask — clarify requirements
  ├── 2. Plan — break into steps, build dependency graph
  │
  ├── 3. Wave 1 (parallel): tasks with no dependencies
  │   ├── Developer Agent A → spawns test-writer A
  │   ├── Developer Agent B → spawns test-writer B
  │   └── Developer Agent C → spawns test-writer C
  │
  ├── 4. Wave 2 (parallel): tasks that depended on Wave 1
  │   ├── Developer Agent D → spawns test-writer D
  │   └── Developer Agent E → spawns test-writer E
  │
  ├── 5. Integration Reviewer — checks everything fits together
  │
  └── 6. Report back to developer
```

### How it works

1. **Plan phase** — the orchestrator breaks the task into discrete steps, exactly as it does today with ask → plan → implement
2. **Dependency analysis** — for each step, determine: does it depend on another step's output? Build a directed acyclic graph (DAG)
3. **Wave execution** — group independent tasks into waves. All tasks in a wave run in parallel. Each wave waits for the previous wave to complete.
4. **Developer agents** — generic coding agents that receive a specific task, relevant file context, and coding standards. Each spawns its own test-writer when done.
5. **Integration reviewer** — a new agent that runs after all waves complete. Checks:
   - Do the pieces fit together? (interfaces match, imports resolve, types align)
   - Are there conflicts? (two agents modified related code inconsistently)
   - Do tests still pass as a whole?

### What's needed

- **orchestrator-developer** agent — the task scheduler that builds the DAG, spawns waves, and coordinates
- **developer** agent (generic) — a coding agent that takes a scoped task and executes it. Follows coding standards, spawns test-writer when done.
- **integration-reviewer** agent — post-merge validation. Checks cross-cutting concerns, runs full test suite, flags conflicts.
- **/build** command (or similar) — triggers the full parallel workflow

### Contract-First variant (full-stack)

For full-stack features, add a contract phase before splitting:
1. Define the API contract first (OpenAPI spec, GraphQL schema, shared TypeScript interfaces)
2. Backend agent(s) build against the contract
3. Frontend agent(s) build against the same contract
4. Each side spawns its own test-writer, mocking the other side based on the contract
5. Integration reviewer validates both sides match the contract

A **/contract** command could generate or validate the API spec before development starts.

### When it works

- Features with multiple independent parts (e.g., 3 new API endpoints that don't share code)
- Full-stack development (frontend + backend in parallel)
- Microservice development (multiple services with defined interfaces)
- Large refactors that touch many files independently

### When to fall back to sequential

- Tightly coupled changes within a single module
- Exploratory prototyping where the shape isn't known yet
- Small tasks where the overhead of coordination exceeds the time saved

### Key risk

Token cost scales linearly with agent count. 5 parallel agents = 5x token usage. The orchestrator must be smart about when parallelization actually saves time vs when sequential is cheaper and simpler.

## General

- Prompt tuning for agents after real-world review output analysis
- Documenter output format refinement based on actual generated docs
- Explore whether MCP servers become useful as the setup matures
