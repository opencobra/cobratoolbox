<!-- SPECKIT START -->
Active Spec Kit feature: **none** — no feature is currently in progress. The
entropic-FBA series 010 (optional GECKO/enzyme support), 011 (infeasible/dual/test
hardening), and 012 (GECKO header docs + enzyme-aware KKT/thermo diagnostics) are all
merged to `develop` and pushed. A comments-only follow-up documenting the
GECKO-compatible mathematical formulation in the `entropicFluxBalanceAnalysis.m` header
(commit `47c3a127c`) landed via an explicit direct-implementation override; see
`specs/012-gecko-diagnostics-docs/human-loop.md` (Post-closeout addendum). Start the next
change through Spec Kit (`constitution → specify → clarify → plan → tasks → analyze →
implement`); source edits remain gated on an explicit `/speckit-implement`.
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
  explicit `/speckit-implement`. Sole bypass: the exact phrase
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
