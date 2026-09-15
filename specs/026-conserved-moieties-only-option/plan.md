# Implementation Plan: Conserved-Moieties-Only Option for identifyConservedReactingMoieties

**Branch**: `026-conserved-moieties-only-option` | **Date**: 2026-09-14 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/026-conserved-moieties-only-option/spec.md`

## Summary

Add a new boolean `options.conservedMoietiesOnly` field to
`identifyConservedReactingMoieties.m` that, when true, makes the function return after the
existing conserved-moiety computation (`arm`, `moietyFormulae`) and skip the unconditional
reacting-moiety bond-graph/minimum-set-cover section entirely — with `reacting` returned as
an explicit "not computed" marker rather than partial data. Default behavior is unchanged.
Then extend the function's existing test file with (a) a conserved-only-mode assertion and
(b) a field-level equivalence check between the conserved-only run and the existing
full-mode run already in that test, on the same self-contained fixture.

## Technical Context

**Language/Version**: MATLAB, R2024b+ baseline (Constitution Scientific Computing
Constraints)

**Primary Dependencies**: None new. Uses only what
`src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m` already uses
(MATLAB `digraph`/`graph`, existing sparse-matrix operations already in the function). The
sibling function `src/analysis/topology/conservedMoieties/identifyConservedMoieties.m` is
referenced only as evidence that the conserved-moiety algorithm is already implementable
standalone — it is not called or depended on by this feature.

**Storage**: N/A

**Testing**: Existing MATLAB test harness (`test/testAll.m`,
`test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`), run via
`prepareTest`-gated assertions; no new test file (Principle III-Naming).

**Target Platform**: Headless Linux CI (`matlab -batch`), same as the rest of the toolbox.
The new conserved-only code path specifically must not require a MILP solver license/
installation, unlike the existing full-computation path.

**Project Type**: Library (single existing MATLAB function within the COBRA Toolbox source
tree; no new subfolder, no new dependency).

**Performance Goals**: No numeric throughput target. The qualitative goal (from the spec) is
that conserved-only mode must not execute the reacting-moiety section's work (condensed
reacting-bond graph construction, CRB2R construction, minimum-set-cover MILP solve) at all —
this is an all-or-nothing control-flow skip, not a partial speed-up.

**Constraints**: Default (option unset/false) behavior and outputs MUST be byte-identical to
today's; conserved-only mode MUST NOT invoke `intlinprog`/`solveCobraMILP` or any other code
requiring a MILP solver license.

**Scale/Scope**: One function modified
(`identifyConservedReactingMoieties.m`, currently 72,870 bytes), one test file extended
(`testConservedReactingMoieties.m`, currently 356 lines), one documentation header updated.
No new source files.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: This feature touches only which code executes
  (control flow), never the conserved-moiety formulation itself. `arm.L`, `arm.M2M`,
  `arm.M2R`, and `moietyFormulae` are produced by the exact same, unmodified code path in
  both modes (the new option only decides whether execution continues past that point into
  the reacting-moiety section). No change to `N = model.S(metAtomMappedBool,
  rxnAtomMappedBool)`, to `arm.MRH`, or to any bound/objective/status semantics — this
  function has none of those; it is a structural-decomposition analysis, not an
  optimization. (Constitution Principle I)

- **Testing and reproducibility**: Narrowest test = extend
  `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` (the
  existing, sole test file for this function, per Principle III-Naming) with:
  1. A call with `options.conservedMoietiesOnly = true` on the same `subModel`/`BG`/`dATM`
     already built earlier in the test file, asserting it succeeds, that `reacting.computed
     == false` (or equivalent marker), and that no MILP-solver requirement is declared for
     this assertion (i.e., it is NOT wrapped in an additional `prepareTest('needsMILP',
     true)` — the existing file-level `prepareTest('needsMILP', true)` call stays, since the
     file's other, pre-existing assertions still need it, but the new conserved-only
     assertions must pass even when that requirement would otherwise gate them out, so they
     are structured to not depend on the MILP-only parts of the file running).
  2. A direct comparison (`isequal`/tolerance `1e-8`, matching the file's existing `tol`) of
     `arm.L`, `arm.M2M`, `arm.M2R`, and `moietyFormulae` between the new conserved-only call
     and the pre-existing full-mode call already in the file.
  3. Re-assertion of the existing `norm(full(arm.L) * N) < tol` invariant on the
     conserved-only run's `arm.L`.
  No new fixture, no new `prepareTest` requirement declaration beyond what the file already
  declares.

- **User experience and diagnostics**: `reacting` in conserved-only mode is an explicit
  marker struct (see Data Model), not silence-and-empty — a caller inspecting it
  programmatically can distinguish "not computed" from "computed, found nothing." No new
  console output is added; `options.sanityChecks` continues to gate the conserved-moiety
  section's existing sanity-check diagnostics exactly as today.

- **Performance and numerical integrity**: The skip is a single early `return` after the
  conserved-moiety section completes; nothing in that section is reordered, shortened, or
  made conditional in a way that could change `arm`/`moietyFormulae` values. No
  diagnostic/verification step is removed — `options.sanityChecks`'s existing checks (which
  apply to the conserved-moiety computation) still run in conserved-only mode exactly as
  before.

- **External-solver configuration audit**: N/A for the new code path by design — conserved-
  only mode is defined specifically to avoid reaching the `intlinprog`/`solveCobraMILP`
  minimum-set-cover call. The existing full-mode path's solver configuration
  (`useOpenSourceMoietyTools` gating `minimumSetCoverPlain` vs. `intlinprog`) is untouched by
  this feature.

- **Spec-driven scope control**: Only two files are edited:
  `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m` (add the
  option flag, its documentation, and the early-return) and
  `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` (add
  assertions). `src/analysis/topology/conservedMoieties/` (the sibling
  `identifyConservedMoieties.m` and its helpers), `buildAtomAndBondTransitionMultigraph.m`,
  and every other file in `reactingMoieties/` are read-only for this feature — no fix to the
  previously-tracked CRB2R over-attribution or bond-node canonicalization issues is bundled
  in here (per spec Assumptions). No new dependency, helper file, or abstraction is
  introduced.

- **MATLAB coding standards**: The new option follows the exact existing pattern in this
  same function for `options.sanityChecks`/`options.useOpenSourceMoietyTools`
  (`~isfield(options, 'conservedMoietiesOnly')` then a default assignment — no `nargin`,
  per Principle VII-D, matching lines ~194-209 of the current file). No `evalc` is
  introduced. No warning is suppressed. No `try/catch` is introduced by this change (none is
  needed for a pure control-flow branch); if one becomes necessary during implementation, it
  must propagate `ME.stack` per Principle VII-C. No project-level MATLAB-lint skill is
  currently registered (checked: no skill under this repo's skills scoped to MATLAB style
  beyond this constitution's own VII-G binding to the openCOBRA style guide); the openCOBRA
  style guide (`documentation/source/guides/styleGuide.rst`) and this function's own existing
  conventions are followed directly rather than proposing a new skill, since the change is a
  small, local, convention-matching addition rather new MATLAB surface area.

- **Parameter-setting fidelity**: N/A — no cross-language port, render, or literate-document
  output is produced by this feature.

- **Artifact placement**: No new source files. The two edited files stay at their current,
  already-correct locations (`src/analysis/topology/reactingMoieties/` and
  `test/verifiedTests/analysis/testReactingMoieties/`, per Principle IX). Spec Kit artifacts
  for this feature live under `specs/026-conserved-moieties-only-option/`, as here.

## Project Structure

### Documentation (this feature)

```text
specs/026-conserved-moieties-only-option/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md         # Phase 1 output
├── quickstart.md         # Phase 1 output
├── contracts/
│   └── function-interface.md   # Phase 1 output — before/after public contract
└── tasks.md              # Phase 2 output (/speckit-tasks — not created by this command)
```

### Source Code (repository root)

**Structure Decision**: This is a single-library MATLAB toolbox feature (no
frontend/backend/mobile split applies). Exactly two existing files are modified in place;
no new source directory is created.

```text
src/analysis/topology/reactingMoieties/
└── identifyConservedReactingMoieties.m     # MODIFIED: new options field + early return

test/verifiedTests/analysis/testReactingMoieties/
└── testConservedReactingMoieties.m         # MODIFIED: new assertions, same fixture/data/
```

## Complexity Tracking

*No Constitution Check violations. Table intentionally left empty.*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|---------------------------------------|
| — | — | — |
