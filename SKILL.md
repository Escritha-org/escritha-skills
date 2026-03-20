---
name: escritha-standards
description: >
  Use this skill ALWAYS when a developer is creating, editing, reviewing, or refactoring
  any code in the Escritha project modules (escritha-api, escritha-app, or escritha-book).
  Also trigger for: creating new modules, endpoints, React components, hooks, DTOs,
  migrations, Zustand stores, NestJS services, FastAPI routes, code reviews, pull requests,
  and any question about architecture or project conventions. If the developer mentions
  any project entity (workspace, project, section, rag, pipeline, ciclo, editor, auth,
  payment, orientador, orientando), use this skill immediately.
---

# Escritha Project Standards

Escritha is an academic writing platform composed of three modules:

| Module | Stack | Role |
|---|---|---|
| `escritha-api` | NestJS + Prisma + PostgreSQL | Main REST API |
| `escritha-app` | React + Vite + Zustand + Tailwind | Frontend SPA |
| `escritha-book` | FastAPI + Python + PGVector | RAG/AI Service |

---

## Which reference file to read

Before writing any code, read the reference file for the module you are working on:

- Working on **`escritha-api`** → read `references/api.md`
- Working on **`escritha-app`** → read `references/app.md`
- Working on **`escritha-book`** → read `references/book.md`
- Creating something that spans **two or more modules** → read all relevant files

---

## Global rules (apply to all modules)

### Naming conventions
- **Folders and files**: `kebab-case` across all modules
- **Classes and interfaces**: `PascalCase`
- **Functions and variables**: `camelCase`
- **Global constants**: `UPPER_SNAKE_CASE`
- **Never** use obscure abbreviations — prefer full, descriptive names

### Language
- Variable names, functions, classes, file names, and technical comments: **English**
- Error messages displayed to end users: **Portuguese** (pt-BR)

### Known inconsistencies — how to handle them
The project has historical inconsistencies. When writing **new** code, always follow the correct pattern defined in this skill, even if there is older inconsistent code nearby. Never copy an inconsistent pattern just because it already exists.

Main inconsistencies to avoid:
1. **Auth in `escritha-api`**: do not mix `AuthGuard('jwt')` with `JwtAuthGuard` — always use `JwtAuthGuard` (the global guard from `CoreModule`)
2. **Module directory names in `escritha-app`**: new modules must use **lowercase** (`modules/my-module`), not PascalCase
3. **Prisma fields**: always use `snake_case` in the schema with `@map()` when needed for TypeScript camelCase compatibility

---

## Required flow before coding

1. Read the reference file for the corresponding module
2. Identify the domain module closest to what you are creating
3. Follow the module's folder structure (do not create new structures without justification)
4. Verify that the response/error pattern is being respected
5. If creating a migration, follow the naming pattern: `YYYYMMDDHHMMSS_description_in_snake_case`