# Contributing

Thanks for helping improve this project.

## Develop

```bash
make hooks           # pre-commit + Conventional Commits commit-msg hook
make precommit       # local gate before every commit
make ci              # full CI gate (govulncheck + cross-compile smoke + clean tree)
```

Optional agent setup (host tools + skill pack):

```bash
make agent-tools
make agent-skills
# then in agent chat, once: /setup-matt-pocock-skills
```

See [docs/agent-tools.md](./docs/agent-tools.md) and [docs/agent-skills.md](./docs/agent-skills.md).

## Commits and PRs

- Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) (`feat:`, `fix:`, `chore:`, …)
- Versions follow [SemVer](https://semver.org/) via [release-please](https://github.com/googleapis/release-please)
- Release artifacts are built with [GoReleaser](https://goreleaser.com) (`.goreleaser.yml`)
- Open PRs against `main` / `master`; CI must pass (`make ci`)

## Agent and process contract

Coding agents and detailed engineering expectations live in [AGENTS.md](./AGENTS.md). Humans can treat that file as the source of truth for quality gates, skills, and release flow.

## Security

Report vulnerabilities privately — see [SECURITY.md](./SECURITY.md). Do not file public issues for security bugs or leak secrets in PRs.

## Layout

Follow [golang-standards/project-layout](https://github.com/golang-standards/project-layout).
