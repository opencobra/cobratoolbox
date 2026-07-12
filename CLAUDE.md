<!-- SPECKIT START -->
No active Spec Kit feature. Start a new one with `/speckit-specify` (it will scaffold
`specs/<NNN-feature-name>/` and set it active). Spec Kit rewrites this block to point at
the active feature's `plan.md` once one exists.
<!-- SPECKIT END -->

<!-- Hand-maintained; keep OUTSIDE the SPECKIT markers (Spec Kit rewrites that block). -->
## Governance

Behavioral rules live in `.specify/memory/constitution.md` — the **single source of truth**
for how to work in this repo. Do not duplicate or override its rules here; change behavior
via `/speckit-constitution`, not by editing CLAUDE.md. Read the constitution before
implementing. Load-bearing rules that apply on **every** turn (spec-driven or not):

- **Principle VI (strict implementation gate):** no edits to source, tests, or build files
  outside an explicit `/speckit-implement` after the feature has approved `spec.md`,
  `plan.md`, and `tasks.md`. An ordinary "fix this / add this" request is a request to
  enter the Spec Kit workflow, not authorization to edit code. The only bypass is the exact
  phrase `DIRECT IMPLEMENTATION OVERRIDE: bypass Spec Kit for this change.` Spec Kit
  artifacts under `specs/<feature>/` are not "source" and may be written during preparation.
- **Principle II (backward compatibility):** public function signatures, COBRA model
  structure fields, and the `solveCobra*`/`changeCobraSolver` solver-interface contract stay
  backward-compatible unless a spec explicitly approves a documented break. Deprecate into
  `deprecated/` rather than delete; new optional arguments default to historical behavior.
- **Principle III (testing/CI):** every behavioral change ships with a test under
  `test/verifiedTests/<category>/` that runs via `test/testAll.m` and the CI pipelines
  (`testAllCI_*`, `.artenolis.yml`, `codecov.yml`). Justify numerical tolerances; skip
  gracefully when a required commercial solver is absent.
- **Principle VII (MATLAB standards):** no warning-suppressing `evalc`, keep warnings
  visible, propagate `ME.stack` in try/catch, prefer `exist`/`isempty` over `nargin` for new
  optional args, and carry the openCOBRA help-header convention on new functions.
- **Principle IX (file placement):** respect the existing layout — source in `src/`, tests in
  `test/`, docs in `documentation/`, third-party in `external/` (read-only), Spec Kit
  artifacts in `specs/<feature>/`. Do not accumulate scratch or generated files at the root.
- **Implementation-receipt ledger:** every implementation run records a receipt under
  `specs/<feature>/agent-runs/<UTC>-<name>/implementation-receipt.md`.

## Project

Local fork of https://github.com/rmtfleming/cobratoolbox (upstream
https://github.com/opencobra/cobratoolbox), documented at
https://opencobra.github.io/cobratoolbox/stable/. Goal: evolve the toolbox toward a polyglot
(MATLAB + Python + Julia) version with additional capabilities, under spec-driven development
(Principle VIII governs cross-language fidelity). Initialize with `initCobraToolbox`.

## Spec Kit workflow (with human loop)

Phase order for any non-trivial change:
`constitution → specify → clarify (if ambiguous) → plan → tasks → analyze (if available) → implement`.
Commands: `/speckit-constitution`, `/speckit-specify`, `/speckit-clarify`, `/speckit-plan`,
`/speckit-tasks`, `/speckit-analyze`, `/speckit-implement`, plus `/speckit-checklist`,
`/speckit-human-loop`, and `/speckit-taskstoissues`. The `human-loop` and `git`/`agent-context`
extensions are installed (see `.specify/extensions.yml`).
