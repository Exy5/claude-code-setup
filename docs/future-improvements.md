# Future Improvements

Ideas for future iterations of the claude-code-setup. Driven by real-world usage feedback.

---

## Commands

### /refactor
Analyze code and propose a refactoring plan. Follows the ask → plan → implement workflow. Could scope by file, directory, or concern (e.g., `/refactor extract-service UserController.java`).

### /commit
Auto-generate Conventional Commit messages from the current diff. Could suggest splitting changes into separate commits when multiple concerns are mixed.

### /pr
Auto-generate a well-structured PR description from commit history and review reports. Include summary, changes, test plan, and link to review report if available.

### /contract
Generate or validate an API contract (OpenAPI spec, GraphQL schema, shared TypeScript interfaces) before `/build` starts. Enables the contract-first variant for full-stack parallel development.

## Agents

### CI/CD Setup Agent
Scaffolds GitHub Actions workflows based on the project's tech stack. Generates build, test, lint, and deploy pipelines. Adapts to the deployment target from the project kickoff context.

## Skills

- Add more skills as new frameworks are encountered (e.g., Python/Django, Go, Rust)
- Skills could be community-contributed if the repo goes public

## General

- Prompt tuning for agents after real-world review output analysis
- Documenter output format refinement based on actual generated docs
- Explore whether MCP servers become useful as the setup matures
