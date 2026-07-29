# Agent contract — YOUR_PROJECT

Go module `github.com/OWNER/REPO`. Default binary package: `cmd/app`.

## Layout

Follow [golang-standards/project-layout](https://github.com/golang-standards/project-layout). Keep exported APIs minimal.

`scripts/init.sh` is one-time bootstrap (module path, binary name, hooks). The `Makefile` is the quality-gate source of truth.

## Verify before claiming done

```bash
make precommit   # local / git-hook gate (mod, gen, spell, lint, test)
make ci          # precommit + govulncheck + clean tree (matches GitHub Actions)
```

Do **not** skip hooks or claim success without running these when you changed Go, Markdown, or config files.

Humans: see [CONTRIBUTING.md](./CONTRIBUTING.md). Vulnerabilities: [SECURITY.md](./SECURITY.md) (never file public issues for security bugs).

## Commits, versions, releases

This repository is built for a deterministic, agent-friendly release loop:

| Spec | Link | Rule |
|------|------|------|
| Conventional Commits | https://www.conventionalcommits.org/en/v1.0.0/ | Every commit message must follow this format |
| Semantic Versioning | https://semver.org/ | Versions are `MAJOR.MINOR.PATCH` |
| release-please | https://github.com/googleapis/release-please | Automates changelog, version bumps, tags, and GitHub Releases |

### Commit messages (required)

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

Common types:

- `feat:` — new user-facing capability (minor; breaking with `!` or `BREAKING CHANGE:` → major)
- `fix:` — bug fix (patch)
- `docs:`, `chore:`, `refactor:`, `test:`, `ci:`, `build:` — non-release or as configured

Examples:

```text
feat: add location search
fix: handle empty weather response
feat!: drop support for Go 1.21
```

A `commit-msg` hook rejects non-conventional messages when pre-commit is installed.

Do **not** hand-bump versions or edit release tags for routine work. Merge conventional commits to the default branch; release-please opens a release PR; merging that PR publishes the SemVer tag and release notes.

## Testing mandate

- Change behavior → add or adjust a test that would fail without the change.
- Prefer table-driven tests for branches and edge cases.
- Assert errors and return values, not only happy paths.
- Concurrent code must be exercised under `-race` (`make test` enables race when CGO allows).

## Bootstrap (template only)

If this tree still uses the `github.com/OWNER/REPO` placeholder:

```bash
./scripts/init.sh github.com/you/your-module [binary-name]
```

That rewrites the module path, renames `cmd/app` when needed, installs a project README, runs `go mod tidy`, and installs pre-commit when available. No manual find/replace afterward.

## Agent skills (mattpocock + superpowers)

Setup once:

```bash
make agent-skills                 # global via npx skills
# then in agent chat, once per repo:
#   /setup-matt-pocock-skills
```

Details: [docs/agent-skills.md](./docs/agent-skills.md).

| Need | Prefer |
|------|--------|
| Align before building | Matt `/grill-me` or `/grill-with-docs` |
| Default plan → implement → review loop | **Superpowers** (auto-triggers) |
| Explicit TDD on a slice | Superpowers TDD **or** Matt `/tdd` (not both at once) |
| Hard bug | Matt diagnose **or** Superpowers systematic-debugging |
| Architecture deepening | Matt `/improve-codebase-architecture` |

Do not skip grilling on ambiguous work. Do not claim done without `make precommit`.

## Agent host tools (rtk + codegraph + ast-grep)

```bash
make agent-tools
```

Details: [docs/agent-tools.md](./docs/agent-tools.md).

| Need | Tool | Do this |
|------|------|---------|
| Smaller shell / test / git / lint output | **rtk** | Prefer hooked shell commands, or `rtk go test ./...`, `rtk git diff` |
| Navigate symbols, callers, blast radius | **codegraph** | Use CodeGraph MCP tools before broad Grep/Read crawls |
| Find or rewrite a **syntax shape** across files | **ast-grep** | `ast-grep -p '...' -l go` (not for ordinary navigation) |

Rules of thumb:

- Discover structure with **codegraph**, not endless file reads.
- Compress noisy command output with **rtk**.
- Use **ast-grep** only for structural search/codemods; do not use it as a substitute for codegraph.
- Quality gates remain `make precommit` / `make ci` (Go tools below).

## Go toolchain (Makefile)

Pinned via `tool` directives in `tools/go.mod` (a dedicated module, so the main `go.mod` stays dependency-free) and invoked as `go tool -modfile=tools/go.mod …` from the Makefile:

- golangci-lint v2
- govulncheck (CI via `make ci` / `make vuln`, not pre-commit)
- misspell (Markdown only)

Requires Go 1.26+ (see `go.mod`). [pre-commit](https://pre-commit.com/) is optional but recommended.
