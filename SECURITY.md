# Security policy

## Reporting a vulnerability

Please report security issues **privately** via [GitHub Security Advisories](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability) on this repository:

**Security → Report a vulnerability**

Do not open a public issue for vulnerabilities or include secrets in issues, PRs, or chat logs.

## What to include

- Description of the issue and impact
- Steps to reproduce (PoC if possible)
- Affected versions / commit if known
- Any suggested fix (optional)

## Response

We aim to acknowledge reports within **7 days** and to keep you updated until the issue is resolved or declined with an explanation.

## Supported versions

Only the latest released version (and `main` / `master`) is supported for security fixes unless noted otherwise in a release.

## Supply-chain checks

This project runs `govulncheck` in CI (`make ci` / `make vuln`) and may receive dependency update PRs via Dependabot. Those automate detection and upgrades; they do not replace private vulnerability reporting for novel issues.
