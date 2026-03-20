# escritha-standards skill

> Standards and conventions for the [Escritha](https://escritha.com) project.  
> Works with **Claude Code**, **Cursor**, **Codex**, and any agent that supports the `SKILL.md` format.

---

## What this skill does

This skill enforces consistent code patterns across all three Escritha modules:

| Module | Stack |
|---|---|
| `escritha-api` | NestJS · Prisma · PostgreSQL |
| `escritha-app` | React · Vite · Zustand · Tailwind |
| `escritha-book` | FastAPI · Python · PGVector |

Once installed, your AI agent automatically reads the relevant standards before creating modules, endpoints, components, DTOs, stores, migrations, and more — no manual prompting needed.

---

## Requirements

- **Node.js** 18+ (for `npx`)
- One of: Claude Code, Cursor, Codex CLI, or any agent that supports `SKILL.md`

---

## Installation

### Option 1 — Project install (recommended)

Installs the skill into `.claude/skills/` inside your repo. Everyone who clones the project gets it automatically.

```bash
# from the root of any escritha module (escritha-api, escritha-app, or escritha-book)
npx skills add YOUR_ORG/escritha-skills --skill escritha-standards
```

> Replace `YOUR_ORG/escritha-skills` with the actual GitHub path where this skill is hosted.

---

### Option 2 — Install from a local path

If you have the skill folder locally (e.g. after cloning this repo):

```bash
npx skills add ./escritha-skill-en
```

---

### Option 3 — Global install

Makes the skill available across **all your projects**, not just Escritha.

```bash
npx skills add YOUR_ORG/escritha-skills --skill escritha-standards --global
```

---

### Option 4 — Target a specific agent

```bash
# Claude Code only
npx skills add YOUR_ORG/escritha-skills --skill escritha-standards -a claude-code

# Cursor only
npx skills add YOUR_ORG/escritha-skills --skill escritha-standards -a cursor

# Both at once
npx skills add YOUR_ORG/escritha-skills --skill escritha-standards -a claude-code -a cursor
```

---

### Option 5 — Manual install (no npx)

Copy the skill folder directly into your project:

```bash
# project-level
mkdir -p .claude/skills
cp -r escritha-skill-en .claude/skills/escritha-standards

# or global
mkdir -p ~/.claude/skills
cp -r escritha-skill-en ~/.claude/skills/escritha-standards
```

---

## Verify installation

```bash
npx skills list
```

You should see `escritha-standards` in the output.

---

## Skill priority

When the same skill name exists in multiple locations, the following priority applies (highest wins):

```
enterprise > personal (~/.claude/skills) > project (.claude/skills)
```

For most teams, **project-level install is the right choice** — the skill is versioned alongside the code and available to every contributor automatically.

---

## Updating

```bash
npx skills update escritha-standards
```

---

## Uninstalling

```bash
# Interactive (pick from list)
npx skills remove

# By name
npx skills remove escritha-standards

# From global scope
npx skills remove --global escritha-standards
```

---

## Skill structure

```
escritha-standards/
├── SKILL.md                  ← entry point, global rules, module routing
└── references/
    ├── api.md                ← NestJS patterns (controllers, DTOs, Prisma, auth)
    ├── app.md                ← React patterns (components, Zustand, apiFetch, Tailwind)
    └── book.md               ← FastAPI patterns (endpoints, Pydantic, RAG service)
```

The skill uses **progressive disclosure**: `SKILL.md` stays lightweight and directs the agent to load only the reference file relevant to the current module. This keeps context clean and focused.

---

## For Claude.ai users (non-Claude Code)

If you use Claude via the web interface instead of Claude Code, install skills through the UI:

1. Go to **Settings → Capabilities** and enable **Code execution and file creation**
2. Go to **Customize → Skills**
3. Upload the `escritha-standards.skill` file (packaged version)
4. Toggle it on

To generate the `.skill` package from the source folder:

```bash
npx skills pack ./escritha-skill-en
```

---

## Contributing

To update the standards:

1. Edit the relevant file inside `references/` (or `SKILL.md` for global rules)
2. Test by running a few prompts in your agent and checking that it follows the updated patterns
3. Open a PR — changes take effect for everyone after merging and running `npx skills update`

---

## Security note

Only install skills from trusted sources. This skill contains no executable scripts — it is purely instructional markdown read by the agent at task time.