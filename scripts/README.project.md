# {{PROJECT}}

Module: `{{MODULE}}`

## Develop

```bash
make precommit   # run before every commit
make build       # → bin/{{BINARY}}
./bin/{{BINARY}}
```

Install git hooks once (optional):

```bash
make hooks       # requires https://pre-commit.com
```

Agent host tools (optional, recommended):

```bash
make agent-tools         # rtk + codegraph + ast-grep
make agent-tools-check
```

Agent skills (optional, recommended):

```bash
make agent-skills        # mattpocock/skills + obra/superpowers
# then in agent chat: /setup-matt-pocock-skills
```

See [docs/agent-tools.md](./docs/agent-tools.md) and [docs/agent-skills.md](./docs/agent-skills.md).

## Layout

Follows [golang-standards/project-layout](https://github.com/golang-standards/project-layout). Quality gates live in the `Makefile` (`precommit` / `ci`).

## Versioning and releases

- Commits: [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
- Versions: [Semantic Versioning](https://semver.org/)
- Automation: [release-please](https://github.com/googleapis/release-please) on pushes to `main` / `master`

Merge conventional commits → release-please opens a release PR → merge that PR to tag and publish. [GoReleaser](https://goreleaser.com) attaches archives and checksums (see `.goreleaser.yml`). Local dry-run: `make release-snapshot`.

## Commands

| Target | What it does |
|--------|----------------|
| `make precommit` | mod, generate, spell, lint, test |
| `make ci` | `precommit` + govulncheck + clean git tree |
| `make test` | unit tests (`-race` when CGO allows) |
| `make cover` | tests with coverage summary |
| `make build` | build `bin/{{BINARY}}` |

See [CONTRIBUTING.md](./CONTRIBUTING.md) for humans and [AGENTS.md](./AGENTS.md) for coding agents. Report vulnerabilities via [SECURITY.md](./SECURITY.md).
