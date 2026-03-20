# escritha-skills

> Single source of truth for code standards across all Escritha repositories.  
> Contains Cursor Agent Skills and Cursor Rules for `escritha-api`, `escritha-app`, and `escritha-book`.

---

## Repository structure

```
escritha-skills/
├── cursor/
│   ├── api.mdc              ← Cursor Rule for escritha-api  (NestJS + Prisma)
│   ├── app.mdc              ← Cursor Rule for escritha-app  (React + Vite + Zustand)
│   └── book.mdc             ← Cursor Rule for escritha-book (FastAPI + Python)
├── skills/
│   └── escritha-standards/  ← Cursor Agent Skill (folder name MUST match the name in SKILL.md)
│       ├── SKILL.md
│       └── references/
│           ├── api.md
│           ├── app.md
│           └── book.md
├── sync-rules.sh            ← copies .mdc files into each repo
└── README.md
```

> ⚠️ **Important:** The folder name `escritha-standards` must match `name: escritha-standards`
> inside `SKILL.md`. Cursor uses this to index the skill. Never rename one without the other.

---

## Two complementary mechanisms

This repo provides two things that work together:

| Mechanism | File | Purpose |
|---|---|---|
| **Agent Skill** | `skills/escritha-standards/SKILL.md` | Teaches the AI *what* the project standards are |
| **Cursor Rule** | `cursor/<module>.mdc` | Tells Cursor *when* to apply those standards |

Install both for the best experience.

---

## Installing the Agent Skill

The skill can be installed globally (works across all your projects) or per-project.

### Option 1 — Global install (recommended for all Escritha developers)

```bash
mkdir -p ~/.cursor/skills
git clone https://github.com/<your-org>/escritha-skills.git /tmp/escritha-skills
cp -r /tmp/escritha-skills/skills/escritha-standards ~/.cursor/skills/escritha-standards
```

Restart Cursor after installing.

### Option 2 — Project-level install (per repo)

Run this inside each repo you want the skill active in (`escritha-api`, `escritha-app`, or `escritha-book`):

```bash
mkdir -p .cursor/skills
cp -r /path/to/escritha-skills/skills/escritha-standards .cursor/skills/escritha-standards
```

### Option 3 — Install via Cursor UI

1. Open Cursor
2. Go to **Settings → Rules**
3. Click **Remote Rule (GitHub)**
4. Enter: `https://github.com/<your-org>/escritha-skills`
5. Cursor will discover the skill automatically from the `skills/` folder

### Verify the skill is loaded

After installing, restart Cursor and open any chat. Type:

```
@escritha-standards
```

If the skill appears as a suggestion, it is installed correctly.

---

## Installing the Cursor Rules (per repo, via git)

Rules are the `.mdc` files that tell Cursor which standards to apply per module.
They live inside each repo at `.cursor/rules/` and are committed to git — so every developer gets them automatically on clone.

### First-time setup

Make sure all four repos are **siblings** in the same parent folder:

```
~/your-projects/
├── escritha-api/
├── escritha-app/
├── escritha-book/
└── escritha-skills/     ← run the script from here
```

Then run:

```bash
cd escritha-skills
chmod +x sync-rules.sh
./sync-rules.sh
```

Output:
```
🔄  Syncing Cursor rules from escritha-skills...
✅  escritha-api  →  .cursor/rules/escritha-standards.mdc
✅  escritha-app  →  .cursor/rules/escritha-standards.mdc
✅  escritha-book →  .cursor/rules/escritha-standards.mdc

🎉  Done!
```

Then commit in each repo:

```bash
cd ../escritha-api  && git add .cursor/rules/ && git commit -m "chore: add cursor standards rule"
cd ../escritha-app  && git add .cursor/rules/ && git commit -m "chore: add cursor standards rule"
cd ../escritha-book && git add .cursor/rules/ && git commit -m "chore: add cursor standards rule"
```

From this point on, any developer who clones one of those repos gets the rule automatically — no extra setup needed.

---

## New developer checklist

- [ ] Clone `escritha-api`, `escritha-app`, `escritha-book`, and `escritha-skills` as siblings
- [ ] Install the Agent Skill globally: copy `skills/escritha-standards` to `~/.cursor/skills/`
- [ ] Restart Cursor
- [ ] Verify the skill loads: type `@escritha-standards` in any Cursor chat
- [ ] Verify the rule is active: Cursor Settings → Rules → `escritha-standards` toggled on
- [ ] Done — the AI will now follow project standards automatically

---

## Updating the standards

1. Edit the relevant file in `escritha-skills/cursor/` or `escritha-skills/skills/escritha-standards/`
2. For rule changes: run `./sync-rules.sh` and commit in each affected repo
3. For skill changes: developers re-run the install command or pull the latest and re-copy
4. Open a PR in `escritha-skills` so changes are reviewed and tracked

**Never edit `.mdc` files directly inside `escritha-api`, `escritha-app`, or `escritha-book`** — those are generated. Changes made there will be overwritten the next time `sync-rules.sh` runs.

---

## FAQ

**What is the difference between the Skill and the Rule?**
The Rule (`.mdc`) tells Cursor *when* to pay attention — it activates based on file globs and context.
The Skill (`SKILL.md`) tells the AI *what* to do — it contains the actual standards, patterns, and examples.
Together they ensure the AI both triggers at the right moment and knows exactly what to follow.

**Do I need to re-run `sync-rules.sh` every time I open the project?**
No. The `.mdc` files are committed in each repo. Only run the script when the standards change.

**The rule exists but the AI is not following it. What do I do?**
Open a new Cursor chat (rules load per session). Then check Cursor Settings → Rules and confirm the toggle is on.

**I updated `api.mdc` but changes are not showing in `escritha-app`.**
Each `.mdc` is repo-specific. Update `app.mdc` and re-run `./sync-rules.sh` for `escritha-app`.

**Can I rename the skill folder?**
Only if you also update `name:` in `SKILL.md` to match. Both must always be identical.