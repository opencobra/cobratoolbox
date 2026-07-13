# AGENTS.md

Agent-neutral entry point for any Spec Kit-compatible agent (Codex, Claude, and other
AI contributors/reviewers) working in the COBRA Toolbox. Claude also reads `CLAUDE.md`,
which points to the same place.

This file is a pointer, not a rulebook. Per constitution Principle X (single-sourcing,
no instruction leakage), the rules are NOT duplicated here.

**Read `.specify/memory/constitution.md` before doing anything.** It is the single
source of truth for how to work in this repository and it is agent-neutral. Everything
below is defined there — do not restate or fork it.

- **The gate (Principle VI):** do not edit source, tests, or build files from an
  ordinary request. Any non-trivial change goes through Spec Kit
  (`constitution → specify → clarify → plan → tasks → analyze → implement`); code is
  edited only after an approved `spec.md`/`plan.md`/`tasks.md` and an explicit
  implementation command (`/speckit-implement` for Claude, `$speckit-implement` /
  the `.agents/skills/speckit-implement` surface for Codex). Sole bypass: the exact
  phrase `DIRECT IMPLEMENTATION OVERRIDE: bypass Spec Kit for this change.`
- **Also defined in the constitution:** scientific/model correctness, backward
  compatibility of public interfaces and model fields, testing via `prepareTest` +
  `test/verifiedTests` and CI, solver abstraction (`changeCobraSolver`/`solveCobra*`),
  MATLAB standards and the openCOBRA contribution/style/documentation conventions,
  polyglot cross-language fidelity, file placement (`src/<domain>/…`), and the
  implementation-receipt ledger.

Per-agent Spec Kit surfaces: Claude uses `.claude/`; Codex and others use `.agents/`.
Both mirror the same workflow and are maintained by the `/speckit-*` tooling — do not
hand-edit them to diverge. Change governing behaviour via `/speckit-constitution`,
never by editing this file. Read-only paths: `external/`, `deprecated/`, `binary/`,
and any `old/`/`archive/` directory.
