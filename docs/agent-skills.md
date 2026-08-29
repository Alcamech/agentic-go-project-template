# Agent skills

This template recommends [mattpocock/skills](https://github.com/mattpocock/skills) (Skills for Real Engineers) for an agentic SDLC: grill for alignment, domain docs, TDD, diagnose, architecture.

They install into your **coding agent** (Cursor, Claude Code, Codex, …), not into `go.mod`.

## One-shot setup

```bash
make agent-skills          # global install via npx skills (default)
make agent-skills-project  # copy into this repo instead
make agent-skills-check    # list what is installed
```

Or:

```bash
./scripts/setup-agent-skills.sh
./scripts/setup-agent-skills.sh --project
```

Requires [Node.js](https://nodejs.org/) (`npx`).

### After install (required once per repo)

In the agent chat, run:

```text
/setup-matt-pocock-skills
```

That configures issue tracker, triage labels, and where docs (`CONTEXT.md`, ADRs) live — other Matt Pocock engineering skills read that config.

### Marketplace alternative

If you prefer an agent-native plugin instead of (or in addition to) `npx skills`:

**Claude Code**

```bash
claude plugins install mattpocock-skills
# or in-session:
# /plugin install mattpocock-skills
```

Matt’s README warns: **plugin + skills.sh copy of the same pack = duplicated skills**. Pick one install path.

## When to use which

| Phase | Prefer |
|-------|--------|
| Align on *what* to build | `/grill-me` or `/grill-with-docs` (builds shared language / ADRs) |
| Explicit red-green loop | `/tdd` |
| Hard bug | `/diagnose` / `diagnosing-bugs` |
| Rescue messy design | `/improve-codebase-architecture` |
| Navigate code cheaply | Host tools: codegraph + rtk + ast-grep ([agent-tools.md](./agent-tools.md)) |

Use grilling before large implementation runs.

## Project artifacts these skills may create

Depending on `/setup-matt-pocock-skills` answers:

- `CONTEXT.md` — ubiquitous language / domain glossary  
- ADRs under a docs path you choose  
- Local issue/ticket files if you are not using GitHub/Linear  

Commit those when they are project truth. Do not commit agent-private skill caches.

## Updates

```bash
npx skills update
```

Plugin installs update through the agent’s marketplace/plugin updater.
