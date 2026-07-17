# Implementation Review

## Summary

Feature 013 relocates vendored non-MATLAB code, static third-party data, orphan scratch, committed
generated artifacts, and a misplaced tutorial out of `src/`, leaving only thin MATLAB wrappers whose
path resolution is re-anchored on `CBTDIR`. Behavior-preserving; delivered as three independently
testable slices (P1 SAMMI, P2 Perl+GAMS, P3 data/orphans/tutorial). No source has been modified.

## Embedded Core Commands Completed

- constitution: checked (v1.3.0) · specify: done · clarify: done (3 answers) · checklist: done
  (requirements.md all-pass + relocation-safety.md) · plan: done (research/data-model/quickstart) ·
  tasks: done (27 tasks) · analyze: done (this review).

## Cross-Artifact Analysis Summary

- **Coverage: 100%** — every FR-001..011 and SC-001..006 maps to ≥1 task; no unmapped tasks.
- **CRITICAL: 0. HIGH: 1. MEDIUM: 2. LOW: 2.**
- **F1 (HIGH, governance dependency)**: the static-data sub-slice (T021–T022) introduces a new
  top-level `data/` role absent from constitution IX (v1.3.0). It is correctly *gated* on a companion
  `/speckit-constitution` amendment (T020), so there is no constitution *conflict* — but it is a
  decision the human must make at Gate 2: amend the constitution and include 3b, or defer 3b and ship
  3a (orphans/generated/tutorial) only.
- **F2 (MEDIUM)**: SAMMI's runtime still writes its generated HTML to the default location beside
  `sammi.m` in `src/` (now gitignored). FR-006 is satisfied for *committed* artifacts, but generated
  HTML still lands in `src/` at runtime. Option to redirect output out of `src/` (a small Principle II
  default-behavior tradeoff) — flagged for the maintainer.
- **F3 (MEDIUM)**: the tutorial destination subdir (`tutorials/analysis/`) is marked "confirm" in T019.
- **F4 (LOW)**: terminology "dedicated resource path" (spec) vs `data/` (plan/tasks) — reconciled
  explicitly in the plan; cosmetic.
- **F5 (LOW)**: FR-011 (`taxa2proc_*.txt`) intentionally has no task (it is an exclusion) — recorded so
  it is not mistaken for a coverage gap.

## Proposed Implementation Scope

- **Tasks proposed**: T001–T027 (6 phases). **MVP / first slice**: User Story 1 (SAMMI), tasks
  T001–T010 (incl. setup+foundational).
- **Files likely to change (edits)**: `src/visualization/SAMMIM/sammi.m`;
  `src/dataIntegration/fluxomics/c13solver/generateIsotopomerSolver.m`;
  `src/design/optForceGAMS/{optForceWithGAMS,findMustLWithGAMS,findMustLLWithGAMS,findMustUWithGAMS,findMustULWithGAMS,findMustUUWithGAMS}.m`;
  `src/base/solvers/gams/getAvailableGAMSSolvers.m`; `parse_Atomic_Weights_..._Elements.m` and the two
  `.xlsx` loaders (3b, gated); `.gitignore`; `analysis/WEAKNESSES.md`; `analysis/ARCHITECTURE.md`.
- **Files moved (git mv, byte-identical)**: SAMMI JS/CSS/HTML → `external/`; `c13solver/*.pl` →
  `external/`; `optForceGAMS/*.gms` + `licememo.gms` → `external/`; NIST `.txt` + `.xlsx` → `data/`
  (gated); orphans → `deprecated/`; `tutorial_eFBA.mlx` → `tutorials/`.
- **Files deleted**: `wang/cache/autoFragment_*.mat`; generated SAMMI `index_load*.html`,
  `sammi_test_output.html`.
- **Files that MUST NOT change**: any MATLAB public signature; `taxa2proc_*.txt`; any file not in the
  data-model manifest; `.specify/memory/constitution.md` (the `data/` amendment is a separate
  `/speckit-constitution` action, not part of this implementation).

## Tests and Validation Expected (narrowest first)

Per-domain **baseline** (T003) captured before any move via MATLAB MCP (`run_matlab_test_file`), then
compared after each slice (T010/T016/T023) and finally (T026). `check_matlab_code` on every edited
wrapper. Smoke: `sammi(...)` renders from `external/`; `getMolecularMass`/`computeElementalMatrix`
element-table equality vs baseline; GAMS/c13 wrappers build CBTDIR paths to relocated files.
`perl`/`gams` absence = baseline skip, not a regression.

## Blocking Issues

None. F1 is a Gate-2 decision (scope of the data sub-slice), not a blocker for P1/P2/3a.

## Acceptable Risks

- SAMMI's pre-existing remote-CDN/internet dependence is unchanged and out of scope.
- Static-data sub-slice (3b) deferred if the `data/` amendment is not made now — the rest still ships.

## Human Approval

- Approved: no
- Approved option: (pending Gate 2)
- Approved tasks/scope: (pending)
- Required implementation invocation per constitution: explicit `/speckit-implement` (Principle VI) —
  a Gate 2 menu choice alone does not authorize edits.
- Date (UTC): (pending)
