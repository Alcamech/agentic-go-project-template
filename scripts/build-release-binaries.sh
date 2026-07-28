#!/usr/bin/env bash
# Cross-compile all packages under ./cmd into ./dist.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

mapfile -t cmd_dirs < <(find ./cmd -mindepth 1 -maxdepth 1 -type d | sort)
if [[ ${#cmd_dirs[@]} -eq 0 ]]; then
  echo "no packages under ./cmd" >&2
  exit 1
fi

repo_name="${GITHUB_REPOSITORY##*/}"
if [[ -z "$repo_name" || "$repo_name" == "${GITHUB_REPOSITORY:-}" ]]; then
  repo_name="$(basename "$ROOT")"
fi

mkdir -p dist
targets=(
  "linux/amd64"
  "linux/arm64"
  "darwin/amd64"
  "darwin/arm64"
  "windows/amd64"
)

for cmd_dir in "${cmd_dirs[@]}"; do
  bin_name="$(basename "$cmd_dir")"
  # For single-binary repos, use the repo name; for multi-binary, prefix with it.
  if [[ ${#cmd_dirs[@]} -eq 1 ]]; then
    prefix="$repo_name"
  else
    prefix="${repo_name}-${bin_name}"
  fi

  for target in "${targets[@]}"; do
    goos="${target%/*}"
    goarch="${target#*/}"
    ext=""
    if [[ "$goos" == "windows" ]]; then
      ext=".exe"
    fi
    out="dist/${prefix}_${goos}_${goarch}${ext}"
    echo "building $out from $cmd_dir"
    CGO_ENABLED=0 GOOS="$goos" GOARCH="$goarch" go build -o "$out" "$cmd_dir"
  done
done
