# Global Claude Code Configuration

## Language & Communication

- All responses, code, comments, and documentation in English
- Be concise and direct — lead with the answer, not the reasoning
- No trailing summaries — the diff speaks for itself

## Tech Stack Context

These are my most common stacks. Adapt to whatever the project actually uses.
- **Usual backend:** Java 17+ (Spring Boot 3.x), but any language/framework is fine
- **Usual frontend:** Angular 17+ (TypeScript), occasionally React (TypeScript)
- **Usual build:** Maven/Gradle (Java), npm (frontend)

When a project uses a different stack, follow that project's conventions. These defaults only apply when there's ambiguity. Always ask first for clear decisions on a tech stack, if uncertain.

## Coding Philosophy

- Immutability preferred
- No over-engineering — don't add abstractions for one-time operations
- Minimal diffs — change only what's necessary
- Don't add features, refactor surrounding code, or add comments/docstrings to code you didn't change
- Ask before big refactors
- Fail fast — validate at system boundaries, throw early

For language-specific conventions, see `docs/coding-standards.md`.

## New Project Kickoff

When starting a new project (empty or near-empty directory with no `.claude/CLAUDE.md`), ask these questions before writing code:

1. **What is this project?** — purpose, domain, target users
2. **Tech stack** — preferences or constraints? (use global defaults only if no preference)
3. **Scale expectations** — expected traffic/users? Will this grow significantly?
4. **Lifespan** — prototype/throwaway or long-lived production system?
5. **Non-functional requirements** — performance, availability, compliance, offline support?
6. **Deployment target** — cloud provider, containerized, serverless, on-prem?
7. **Review reports** — should `/review` output be committed or gitignored?

Write the answers into the project's `.claude/CLAUDE.md` so all agents have calibrated context from day one. Keep it concise — this file is loaded every session.

## Before Implementation

Never assume — always clarify first. Follow this sequence for any non-trivial task:

1. **Ask** — ask questions about anything that is unclear. Don't guess intent, requirements, or constraints. Keep asking until everything is understood.
2. **Plan** — break down the solution into clear, reviewable steps. Present the plan for approval before writing any code.
3. **Implement** — only after the plan is confirmed, start coding. Follow the plan step by step.

For trivial tasks (renaming a variable, fixing a typo, etc.), skip straight to implementation.

## Workflow

- **Conventional Commits:** `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`
- One concern per commit — don't mix refactors with features
- After completing any logical unit of code (feature, service, component, utility), automatically spawn the **test-writer** agent to generate tests. Every piece of code should have test coverage from the start.
- After changes, recommend running `/review` before committing and `/document` for significant additions

## What NOT To Do

- Don't add features beyond what's asked
- Don't refactor surrounding code during a bug fix
- Don't add docstrings/comments to code you didn't change
- Don't over-engineer with abstractions for one-time operations
