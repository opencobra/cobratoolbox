# Development tooling

This page summarises the tools used to develop this fork of the COBRA Toolbox and
the open-source tooling recommended for lead-developer / maintainer work. It is a
navigational overview for developers picking up the project. Authoritative rules on
*how* to work in the repo live in `.specify/memory/constitution.md` — this page
describes *what* the toolchain is, not the governance.

The repository is polyglot and large: ~298k lines of MATLAB across ~1,580 source
files under `src/`, plus Python (docs build + Spec Kit tooling), C/C++ under
`external/`, and an emerging Julia surface. Development is spec-driven (GitHub Spec
Kit), so the toolchain spans code, tests, docs, and the SDD workflow.

## Quick start

Run the self-auditing setup script (gitignored, in `.ci-tools/`):

```bash
bash .ci-tools/setup-dev-tools.sh            # audit: show what is present/missing
bash .ci-tools/setup-dev-tools.sh --install  # install the missing tools
```

It detects your package manager (apt / Homebrew / dnf) and installs only what is
missing, grouped into the tiers below. It never installs MATLAB (proprietary) or
the vendored MATLAB test/coverage frameworks.

## Toolchain by area

### Language toolchains

MATLAB is the primary language. The MATLAB IDE supplies `checkcode`/`mlint`. For
open-source static analysis and formatting of the ~3,200 `.m` files, use
**MISS_HIT** (`mh_style` formatter, `mh_lint` linter, `mh_metric` complexity
metrics). Python (3.10+) drives the documentation build and Spec Kit tooling; it is
managed with **uv**, linted/formatted with **ruff**, type-checked with **mypy**, and
tested with **pytest**. C/C++ under `external/` builds with **gcc**/**cmake**. Julia
is currently a single file but the project is evolving toward a MATLAB + Python +
Julia polyglot (see constitution, Principle IX); use **juliaup** + **JuliaFormatter**
when working there.

### Testing and coverage

The MATLAB test suite is driven from `test/testAll.m` using **MOxUnit** (unit test
framework) and **MOcov** (coverage), both vendored under `.ci-tools/` / submodules
rather than system-installed. Coverage gating is feature 001; a coverage summary is
feature 007. Run the full suite locally with `.ci-tools/run-local-ci.sh` (mirrors
`testAllCI_step1.yml`; ~40–60 min, requires MATLAB and `COBRA_CI=1`). Python tests
use pytest.

### Documentation

The public site at <https://opencobra.github.io/cobratoolbox/> is generated with
**Sphinx** from `documentation/source/` (`cd documentation && make html`), driven by
`.github/workflows/build-and-publish-docs.yml`. Dependencies are in
`documentation/requirements.txt`. **pandoc** handles format conversion and
**graphviz**/**plantuml** render diagrams. The repo is the single source of truth and
the website is a generated artifact — never edit the published site directly.

### Spec-driven development (Spec Kit)

Work is gated through GitHub **Spec Kit** (`specify` CLI, run via `uv`/`pipx`). The
machinery lives in `.specify/` (constitution, templates, scripts, extensions,
memory); per-feature artifacts live in `specs/<NNN-feature-name>/`. Installed
extensions (`.specify/extensions.yml`): **git** (per-phase auto-commit),
**agent-context** (refreshes `CLAUDE.md`/`AGENTS.md`), and **human-loop** (bundles
core phases behind sparse human gates). Agent surfaces are under `.claude/` and
`.agents/`. Do not begin implementation from an ordinary request — see constitution
Principle VI.

### CI / automation

CI runs on GitHub Actions (`testAllCI_step1.yml`, `testAllCI_step2.yml`,
`build-and-publish-docs.yml`) and Jenkins (`Jenkinsfile`, `.artenolis.yml`), with
coverage reported to **Codecov** (`codecov.yml`). Locally, **act** runs Actions
workflows, **shellcheck** lints the shell scripts in `.ci-tools/`, and **yamllint**
lints workflow YAML. **Docker** is used for reproducible environments and by the
`autodoc` documentation service.

### Collaboration and code navigation

Contributions flow upstream to `opencobra/cobratoolbox` via pull request; the
**gh** CLI streamlines this and **pre-commit** runs linters before commit.
**git-lfs** matters because `binary/` is ~246 MB. For navigating a large polyglot
codebase, **universal-ctags** builds a cross-language symbol index, **ripgrep**
(`rg`) and **fd** provide fast search/find, **scc** (or tokei/cloc) gives per-language
LOC and complexity stats, and **jq**/**yq** parse the JSON/YAML that CI and Spec Kit
produce.

## Tool reference

| Tier | Tools | Purpose |
| --- | --- | --- |
| core | git, git-lfs, gh, pre-commit | version control, PRs upstream, hooks |
| matlab | MISS_HIT (mh_style/mh_lint/mh_metric); MOxUnit + MOcov (vendored) | lint/format/metrics; test + coverage |
| python | uv, ruff, mypy, pytest | env, lint/format, typing, tests |
| julia | juliaup, JuliaFormatter | polyglot direction |
| docs | sphinx, pandoc, graphviz, plantuml | Sphinx site + diagrams |
| ci | act, docker, shellcheck, yamllint | run/lint pipelines locally |
| nav | universal-ctags, ripgrep, fd, scc, jq, yq | cross-language navigation & metrics |

Install a single tier with `bash .ci-tools/setup-dev-tools.sh --install --tier <tier>`.

## Related documents

- `.specify/memory/constitution.md` — how to work in this repo (single source of truth)
- `documentation/source/contributing.rst` — contribution conventions (openCOBRA)
- `documentation/source/guides/specDrivenDevelopment.rst` — the SDD workflow
- `.ci-tools/run-local-ci.sh` — run the full CI suite locally
