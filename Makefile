SHELL := /bin/bash

.DEFAULT_GOAL := precommit

BINARY  ?= app
OUT     ?= bin/$(BINARY)
TIMEOUT ?= 5m

.PHONY: precommit
precommit: ## local / git hook gate: mod gen spell lint test
precommit: mod gen spell lint test

.PHONY: ci
ci: ## CI gate: precommit + vuln + clean tree
ci: precommit vuln diff

.PHONY: help
help: ## show targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: mod
mod: ## go mod tidy
	go mod tidy

.PHONY: gen
gen: ## go generate
	go generate ./...

.PHONY: spell
spell: ## misspell markdown files
	@find . -name '*.md' ! -path './.git/*' -exec go tool misspell -error -locale=US {} +

.PHONY: lint
lint: ## golangci-lint
	go tool golangci-lint run --fix ./...

.PHONY: vuln
vuln: ## govulncheck (CI; not part of precommit)
	go tool govulncheck ./...

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
