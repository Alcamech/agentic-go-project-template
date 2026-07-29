#!/usr/bin/env bash
# Bootstrap a new project from this template.
# Usage:
#   ./scripts/init.sh github.com/you/myapp
#   ./scripts/init.sh github.com/you/myapp myapp
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Portable sed -i: GNU sed uses -i (no arg), BSD/macOS sed requires -i ''.
if sed --version >/dev/null 2>&1; then
  sedi() { sed -i "$@"; }
else
  sedi() { sed -i '' "$@"; }
fi

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <module-path> [binary-name]" >&2
  echo "  example: $0 github.com/you/myapp" >&2
  exit 1
fi

MODULE="$1"
BINARY="${2:-$(basename "$MODULE")}"
OLD_MODULE="github.com/OWNER/REPO"
OLD_BINARY="app"
PROJECT_NAME="$(basename "$MODULE")"
# github.com/you/myapp → you/myapp (host stripped)
MODULE_PATH="${MODULE#*/}"

if [[ ! "$MODULE" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*/[a-zA-Z0-9._/-]+$ ]]; then
  echo "module path looks invalid: $MODULE" >&2
  echo "expected something like: github.com/you/myapp" >&2
  exit 1
fi

if [[ "$MODULE" == "$OLD_MODULE" || "$MODULE_PATH" == *"OWNER/REPO"* ]]; then
  echo "pick a real module path, not the placeholder ($OLD_MODULE)" >&2
  exit 1
fi

if [[ ! "$BINARY" =~ ^[a-zA-Z0-9][a-zA-Z0-9._-]*$ ]]; then
  echo "binary name looks invalid: $BINARY" >&2
  exit 1
fi

echo "module:  $MODULE"
echo "binary:  $BINARY"
echo "project: $PROJECT_NAME"

# Rename cmd/app → cmd/<binary> when needed
if [[ "$BINARY" != "$OLD_BINARY" ]]; then
  mkdir -p "cmd/$BINARY"
  if [[ -f "cmd/$OLD_BINARY/main.go" ]]; then
    mv "cmd/$OLD_BINARY/main.go" "cmd/$BINARY/main.go"
    rmdir "cmd/$OLD_BINARY" 2>/dev/null || true
  fi
  sedi "s|^BINARY  ?= ${OLD_BINARY}\$|BINARY  ?= ${BINARY}|" Makefile
  if [[ -f .goreleaser.yml ]]; then
    sedi "s|main: ./cmd/${OLD_BINARY}|main: ./cmd/${BINARY}|g" .goreleaser.yml
  fi
fi

# Rewrite module / project placeholders (never rewrite this script)
while IFS= read -r -d '' file; do
  sedi \
    -e "s|${OLD_MODULE}|${MODULE}|g" \
    -e "s|OWNER/REPO|${MODULE_PATH}|g" \
    -e "s|YOUR_PROJECT|${PROJECT_NAME}|g" \
    "$file"
done < <(find . -type f \
  ! -path './.git/*' \
  ! -path './bin/*' \
  ! -path './dist/*' \
  ! -path './scripts/init.sh' \
  ! -path './scripts/README.project.md' \
  ! -name 'go.sum' \
  ! -name 'LICENSE' \
  \( -name '*.go' -o -name 'go.mod' -o -name 'Makefile' -o -name '*.md' -o -name '*.mdc' -o -name '*.yml' -o -name '*.yaml' \) \
  -print0)

# Replace template README with a project README
if [[ -f scripts/README.project.md ]]; then
  sed \
    -e "s|{{MODULE}}|${MODULE}|g" \
    -e "s|{{BINARY}}|${BINARY}|g" \
    -e "s|{{PROJECT}}|${PROJECT_NAME}|g" \
    scripts/README.project.md > README.md
  rm -f scripts/README.project.md
fi

go mod tidy

if [[ ! -d .git ]]; then
  git init -b main
fi
git add -A

if command -v pre-commit >/dev/null 2>&1; then
  pre-commit install --hook-types pre-commit --hook-types commit-msg
  echo "installed pre-commit hooks"
else
  echo "pre-commit not found; install it then run: make hooks"
fi

cat <<EOF

Ready — no further find/replace needed.
  make precommit   # local/hook gate (mod, gen, spell, lint, test)
  make ci          # precommit + govulncheck + clean tree
  make build       # → bin/${BINARY}

Agent host tools (rtk + codegraph + ast-grep):
  make agent-tools           # install/wire (once per machine/project)
  make agent-tools-check
  docs/agent-tools.md

Agent skills (mattpocock/skills + obra/superpowers):
  make agent-skills          # global via npx skills
  # then in agent chat: /setup-matt-pocock-skills
  docs/agent-skills.md

EOF

if [[ "${SKIP_AGENT_TOOLS:-}" != "1" ]]; then
  if [[ -x ./scripts/setup-agent-tools.sh ]]; then
    echo "Running agent-tools setup (set SKIP_AGENT_TOOLS=1 to skip)..."
    ./scripts/setup-agent-tools.sh || echo "agent-tools setup had warnings; see docs/agent-tools.md"
  fi
fi

if [[ "${SKIP_AGENT_SKILLS:-}" != "1" ]]; then
  if [[ -x ./scripts/setup-agent-skills.sh ]] && command -v npx >/dev/null 2>&1; then
    echo "Running agent-skills setup (set SKIP_AGENT_SKILLS=1 to skip)..."
    ./scripts/setup-agent-skills.sh --global || echo "agent-skills setup had warnings; see docs/agent-skills.md"
  else
    echo "Skip agent-skills auto-install (npx missing or script missing). Later: make agent-skills"
  fi
fi
