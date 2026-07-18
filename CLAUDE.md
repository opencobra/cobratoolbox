<!-- SPECKIT START -->
Active Spec Kit feature: **014-src-header-compliance** — behaviour-preserving audit +
remediation of function header comments in every in-scope `src/*.m` file for openCOBRA
documentation-guide (Principle VII-E) compliance, so the CI Sphinx build
(`sphinxcontrib-matlabdomain==0.18.0`) generates complete pages. Plan:
`specs/014-src-header-compliance/plan.md` (spec + clarify + plan done). Deliverables: a
standing MATLAB CI-gate checker under `test/verifiedTests/documentation/` and per-leaf-
folder header remediation, full fan-out across all six domains via the agent-assign
pipeline. Struct fields documented = only those the function uses; vendored subtrees
(rBioNet, modelBorgifier) excluded and deferred to a follow-up feature. Status: planned;
awaiting `/speckit-tasks` then the assign → validate → execute pipeline. Source edits
remain gated on an explicit implementation command. NOTE: this feature took number 014;
the previously-earmarked W4-base (base layering inversion) is now the next free number.
<!-- SPECKIT END -->

<!-- Hand-maintained; keep OUTSIDE the SPECKIT markers (Spec Kit rewrites that block). -->
# Claude instructions

This file is a pointer, not a rulebook. Per constitution Principle X
(single-sourcing, no instruction leakage), the rules are NOT duplicated here.

**Read `.specify/memory/constitution.md` before doing anything.** It is the single
source of truth for how to work in this repository and it is agent-neutral —
`AGENTS.md` (for Codex and other agents) points to the same constitution.

Essentials it defines, so you know what you are bound by:

- **The gate (Principle VI):** do not edit source, tests, or build files from an
  ordinary request. Any non-trivial change goes through Spec Kit
  (`constitution → specify → clarify → plan → tasks → analyze → implement`), and
  code is edited only after an approved `spec.md`/`plan.md`/`tasks.md` and an
  explicit implementation command — `/speckit-implement`, or the agent-assign
  pipeline (`/speckit-agent-assign-assign` -> `/speckit-agent-assign-validate` ->
  `/speckit-agent-assign-execute`, run in series; same `tasks.md`, same gate). Sole
  bypass: the exact phrase
  `DIRECT IMPLEMENTATION OVERRIDE: bypass Spec Kit for this change.`
- Backward compatibility, testing/CI, solver abstraction, MATLAB standards,
  openCOBRA contribution conventions, polyglot fidelity, file placement, and the
  implementation-receipt ledger are all defined there.

Change behaviour via `/speckit-constitution`, never by editing this file. The
`human-loop`, `git`, and `agent-context` extensions are installed
(`.specify/extensions.yml`). Project context: local fork of
https://github.com/rmtfleming/cobratoolbox (upstream
https://github.com/opencobra/cobratoolbox), evolving toward a polyglot
(MATLAB + Python + Julia) toolbox; initialize with `initCobraToolbox`.
