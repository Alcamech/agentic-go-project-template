SHELL := /bin/bash

.DEFAULT_GOAL := precommit

BINARY  ?= app
OUT     ?= bin/$(BINARY)
TIMEOUT ?= 5m

# Go tools are pinned in tools/go.mod, keeping the main module dependency-free.
TOOLMOD := -modfile=tools/go.mod

# lint applies fixes locally; ci overrides this so CI reports diagnostics instead.
LINT_FLAGS ?= --fix

.PHONY: precommit
precommit: ## local / git hook gate: mod gen spell lint test
precommit: mod gen spell lint test

.PHONY: ci
ci: ## CI gate: precommit + vuln + crossbuild + clean tree
ci: LINT_FLAGS =
ci: precommit vuln crossbuild diff

.PHONY: help
help: ## show targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: mod
mod: ## go mod tidy (main + tools modules)
	go mod tidy
	go -C tools mod tidy

.PHONY: gen
gen: ## go generate
	go generate ./...

.PHONY: spell
spell: ## misspell markdown files
	@find . -name '*.md' ! -path './.git/*' -exec go tool $(TOOLMOD) misspell -error -locale=US {} +

.PHONY: lint
lint: ## golangci-lint (fixes locally; report-only under make ci)
	go tool $(TOOLMOD) golangci-lint run $(LINT_FLAGS) ./...

.PHONY: vuln
vuln: ## govulncheck (CI; not part of precommit)
	go tool $(TOOLMOD) govulncheck ./...

ifeq ($(CGO_ENABLED),0)
RACE_OPT =
else
RACE_OPT = -race
endif

.PHONY: test
test: ## go test (with -race when CGO allows)
	go test $(RACE_OPT) -count=1 -timeout=$(TIMEOUT) ./...

.PHONY: cover
cover: ## tests with coverage report
	go test $(RACE_OPT) -count=1 -timeout=$(TIMEOUT) -covermode=atomic -coverprofile=coverage.out -coverpkg=./... ./...
	go tool cover -func=coverage.out

.PHONY: diff
diff: ## fail if working tree is dirty
	git diff --exit-code
	@res=$$(git status --porcelain); if [ -n "$$res" ]; then echo "$$res" && exit 1; fi

.PHONY: build
build: ## build binary into ./bin
	mkdir -p bin
	go build -o $(OUT) ./cmd/$(BINARY)

.PHONY: crossbuild
crossbuild: ## cross-compile smoke for release targets
	GOOS=darwin GOARCH=arm64 go build ./...
	GOOS=windows GOARCH=amd64 go build ./...

.PHONY: release-snapshot
release-snapshot: ## local GoReleaser snapshot (no publish)
	go run github.com/goreleaser/goreleaser/v2@v2.9.0 release --snapshot --clean

.PHONY: hooks
hooks: ## install pre-commit + commit-msg hooks
	pre-commit install --hook-types pre-commit --hook-types commit-msg

.PHONY: agent-tools
agent-tools: ## install/wire rtk, codegraph, ast-grep (host tools)
	./scripts/setup-agent-tools.sh

.PHONY: agent-tools-check
agent-tools-check: ## show rtk / codegraph / ast-grep status
	./scripts/setup-agent-tools.sh --check

.PHONY: agent-skills
agent-skills: ## install mattpocock/skills + obra/superpowers (global)
	./scripts/setup-agent-skills.sh --global

.PHONY: agent-skills-project
agent-skills-project: ## install skill packs into this repo
	./scripts/setup-agent-skills.sh --project

.PHONY: agent-skills-check
agent-skills-check: ## list installed agent skills
	./scripts/setup-agent-skills.sh --check

.PHONY: clean
clean: ## remove build artifacts
	rm -rf bin dist
	rm -f coverage.out coverage.html
