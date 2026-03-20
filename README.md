# escritha-skills

> Single source of truth for code standards across all Escritha repositories.
> Edit here → sync → commit in each repo. Every developer gets the rules automatically on clone.

---

## Repository structure

```
escritha-skills/
├── cursor/
│   ├── api.mdc          ← Cursor rule for escritha-api  (NestJS + Prisma)
│   ├── app.mdc          ← Cursor rule for escritha-app  (React + Vite + Zustand)
│   └── book.mdc         ← Cursor rule for escritha-book (FastAPI + Python)
├── skills/
│   └── escritha-skill-en/
│       ├── SKILL.md
│       └── references/
│           ├── api.md
│           ├── app.md
│           └── book.md
├── sync-rules.sh        ← copies .mdc files into each repo
└── README.md
```

---

## How this works

Each repo (`escritha-api`, `escritha-app`, `escritha-book`) contains a `.cursor/rules/escritha-standards.mdc` file that the Cursor AI reads automatically. The source of those files lives here in `escritha-skills/cursor/`. When you update the standards, you run one script and commit in each repo.

```
escritha-skills/cursor/api.mdc
        │
        └──→  escritha-api/.cursor/rules/escritha-standards.mdc  (git-tracked)
                escritha-app/.cursor/rules/escritha-standards.mdc (git-tracked)
                escritha-book/.cursor/rules/escritha-standards.mdc (git-tracked)
```

---

## First-time setup (do this once)

### 1. Clone all four repos as siblings

Your local folder layout must look like this:

```
~/projects/
├── escritha-api/
├── escritha-app/
├── escritha-book/
└── escritha-skills/     ← clone this repo here
```

If they are in different locations, edit the paths at the top of `sync-rules.sh`.

### 2. Run the sync script

```bash
cd escritha-skills
chmod +x sync-rules.sh
./sync-rules.sh
```

You will see:
```
🔄  Syncing Cursor rules from escritha-skills...
✅  escritha-api  →  .cursor/rules/escritha-standards.mdc
✅  escritha-app  →  .cursor/rules/escritha-standards.mdc
✅  escritha-book →  .cursor/rules/escritha-standards.mdc

🎉  Done!
```

### 3. Commit the generated files in each repo

```bash
cd ../escritha-api  && git add .cursor/rules/ && git commit -m "chore: add cursor standards rule"
cd ../escritha-app  && git add .cursor/rules/ && git commit -m "chore: add cursor standards rule"
cd ../escritha-book && git add .cursor/rules/ && git commit -m "chore: add cursor standards rule"
```

From this point on, any developer who clones one of those repos gets the rules automatically — no extra setup needed.

---

## Enabling the rule in Cursor

The `.mdc` file is picked up automatically by Cursor when it exists in `.cursor/rules/`.
You can verify it is active:

1. Open the project in Cursor
2. Press `Cmd+Shift+P` → type **Cursor Settings**
3. Go to the **Rules** tab
4. You should see `escritha-standards` listed and enabled

If it shows as disabled, click the toggle to enable it.

---

## Updating the standards

1. Edit the relevant file in `escritha-skills/cursor/` (e.g. `api.mdc`)
2. Run `./sync-rules.sh` from the `escritha-skills` root
3. Commit and push in each affected repo
4. Open a PR in `escritha-skills` so the change is reviewed and tracked

**Never edit the `.mdc` files directly inside `escritha-api`, `escritha-app`, or `escritha-book`** — those are generated files. Changes made there will be overwritten the next time `sync-rules.sh` runs.

---

## New developer checklist

- [ ] Clone `escritha-api`, `escritha-app`, `escritha-book`, and `escritha-skills` as siblings
- [ ] Open the Cursor workspace (`.code-workspace` file if available, or open the folder you want)
- [ ] Verify the rule is active in Cursor Settings → Rules → `escritha-standards`
- [ ] Done — the AI will now follow project standards automatically

---

## FAQ

**Do I need to run `sync-rules.sh` every time I open the project?**
No. The `.mdc` files are already committed in each repo. You only need to run the script when the standards change.

**Can I add my own personal rules on top of these?**
Yes. In Cursor Settings → Rules → User Rules, you can add personal preferences. They apply to all your projects and stack on top of the project rule.

**The rule exists but the AI is not following it. What do I do?**
Open a new chat in Cursor (rules are loaded per session). If it still does not work, go to Cursor Settings → Rules and make sure the toggle next to `escritha-standards` is on.

**I updated `api.mdc` but the AI in `escritha-app` still uses the old rules.**
Each `.mdc` is repo-specific. Changing `api.mdc` only affects `escritha-api`. Update `app.mdc` and re-run `./sync-rules.sh` for `escritha-app`.