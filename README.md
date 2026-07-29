# agentic-go-project-template

Public Go starter that follows [golang-standards/project-layout](https://github.com/golang-standards/project-layout), with shared quality gates, git hooks, CI, and agent instructions.

Opinionated Go release loop for an agentic SDLC:

- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
- [Semantic Versioning](https://semver.org/)
- [release-please](https://github.com/googleapis/release-please) automation

One bootstrap command personalizes the module path — no manual find/replace.

## Use this template

**GitHub:** click **Use this template** → create the repo → clone → run `init.sh` below.

**Local copy:**

```bash
cp -a agentic-go-project-template myapp
cd myapp
./scripts/init.sh github.com/you/myapp
make precommit
make build
```

`init.sh`:

1. Sets the Go module path (any host/org, e.g. `github.com/you/myapp`)
2. Renames `cmd/app` to match the binary name when needed
3. Rewrites imports, lint local-prefixes, and agent docs
4. Replaces this README with a project README
5. Runs `go mod tidy`, initializes git if needed, installs pre-commit hooks when available

## After init

| Target | What it does |
| -------- | ---------------- |
| `make precommit` | mod, generate, spell, lint, test (git hook / local) |
| `make ci` | `precommit` + govulncheck + clean git tree |
| `make build` | `go build -o bin/<binary> ./cmd/<binary>` |
| `make hooks` | install `pre-commit` + Conventional Commits `commit-msg` hook |
| `make agent-tools` | install/wire [rtk](https://github.com/rtk-ai/rtk) + [codegraph](https://github.com/colbymchenry/codegraph) + [ast-grep](https://github.com/ast-grep/ast-grep) |
| `make agent-skills` | install [mattpocock/skills](https://github.com/mattpocock/skills) + [obra/superpowers](https://github.com/obra/superpowers) |

Go tools are pinned in `go.mod` (`go tool …`). Agent tools/skills are optional host installs — see [docs/agent-tools.md](./docs/agent-tools.md) and [docs/agent-skills.md](./docs/agent-skills.md).

## Commits and releases

```text
feat: add search          → minor (or major if feat!)
fix: nil pointer on empty → patch
chore: tidy modules       → no version bump (by default)
```

Flow:

1. Land Conventional Commits on `main` / `master`
2. [release-please](https://github.com/googleapis/release-please) opens or updates a release PR (changelog + `.release-please-manifest.json`)
3. Merge the release PR → SemVer tag + GitHub Release
4. [GoReleaser](https://goreleaser.com) builds archives/checksums and attaches them to that release

Config: `release-please-config.json`, `.release-please-manifest.json`, `.goreleaser.yml`, `.github/workflows/release-please.yml`.

Local dry-run: `make release-snapshot`.

## Layout

Directory layout follows [golang-standards/project-layout](https://github.com/golang-standards/project-layout). The sample app and tests are only there so `make precommit` works out of the box — replace them with your code.

Template extras:

```text
scripts/init.sh                 bootstrap
scripts/setup-agent-tools.sh    rtk + codegraph + ast-grep
scripts/setup-agent-skills.sh   mattpocock/skills + obra/superpowers
scripts/README.project.md       becomes README.md after init
docs/agent-tools.md             agent toolchain guide
docs/agent-skills.md            skill packs + how they coexist
sgconfig.yml + rules/           optional ast-grep project rules
Makefile                        quality gates + agent-tools
.golangci.yml                   golangci-lint v2
.goreleaser.yml                 release archives (used by CI)
.pre-commit-config.yaml         make precommit + conventional commit-msg
.github/workflows/ci.yml        make ci
.github/workflows/release-please.yml
.github/workflows/release.yml   GoReleaser for manually pushed v* tags
.github/dependabot.yml          weekly Go + Actions updates
release-please-config.json
.release-please-manifest.json
CHANGELOG.md                    maintained by release-please
CONTRIBUTING.md                 human contributor guide
SECURITY.md                     private vulnerability reporting
AGENTS.md / CLAUDE.md           agent instructions
.cursor/rules/                  Cursor bridge to AGENTS.md
LICENSE                         MIT
```

## Prerequisites

- Go 1.26+ (CI reads `go.mod` via `go-version-file`)
- [pre-commit](https://pre-commit.com/) optional; `make hooks` or `init.sh` installs git hooks when present
- Agent tools (optional): `make agent-tools` — [docs/agent-tools.md](./docs/agent-tools.md)
- Agent skills (optional): `make agent-skills` then `/setup-matt-pocock-skills` — [docs/agent-skills.md](./docs/agent-skills.md)

## Contributing and security

- [CONTRIBUTING.md](./CONTRIBUTING.md) — gates, commits, PRs
- [SECURITY.md](./SECURITY.md) — private vulnerability reports
- [AGENTS.md](./AGENTS.md) — agent/process contract

Dependabot opens weekly PRs for Go modules and GitHub Actions (`chore(deps):`).

## License

MIT — see [LICENSE](./LICENSE).
