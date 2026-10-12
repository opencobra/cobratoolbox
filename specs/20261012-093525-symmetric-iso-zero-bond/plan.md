# Implementation Plan: Exact isomorphism for near-symmetric bond components, and reading RXN reactions with no bonds

**Branch**: `20261012-093525-symmetric-iso-zero-bond` | **Date**: 2026-10-12 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/20261012-093525-symmetric-iso-zero-bond/spec.md`

## Summary

Two contained changes in `src/analysis/topology/reactingMoieties/`:
1. `classifySubgraphIsomorphism`: decide unlabelled candidate pairs with an exact individualisation–refinement test (local functions), with a bounded fallback to `isisomorphic`; labelled calls unchanged ([research](research.md) R1–R5).
2. `readABRXNFile`: create the two element columns before the bond loop so a reaction with no bonds returns a typed empty bond table (R6); verify the builder with such a reaction (R7).
Plus tests, a stored regression pair, timing evidence and the KI-001 update.

## Technical Context

**Language/Version**: MATLAB R2024b

**Primary Dependencies**: MATLAB graph/digraph functions (`findedge`, `isisomorphic`), `sparse`; no new external dependency

**Storage**: test data `.mat` beside the tests (the stuck pair, ≈ 318 nodes, small), committed as a normal binary file like the existing references (`.gitattributes`: `*.mat binary`)

**Testing**: `test/verifiedTests/analysis/testReactingMoieties/` via `testAll`/`runtests`; new `testReadABRXNFile.m`; additions to `testClassifySubgraphIsomorphism.m` and `testBuildAtomAndBondTransitionMultigraph.m`

**Target Platform**: COBRA Toolbox MATLAB, Linux (CI and the maintainer's workstation)

**Project Type**: MATLAB library

**Performance Goals**: stuck pair ≤ 5 s; ≤ +10% classification time on the 1,960-reaction model

**Constraints**: exact results; public signatures unchanged; golden references unchanged

**Scale/Scope**: two source files, three test files, one test data file, KNOWN_ISSUES.md

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: PASS. Exactness argued in research R1–R2 (colour refinement is isomorphism-invariant; complete search; verified bijection) and tested against `isisomorphic` on randomized small graphs. No formulation or solver change.
- **Testing and reproducibility**: PASS. Narrowest tests: stuck-pair case; permuted / one-edge-moved; randomized equivalence with fixed seeds (simple, multigraph, self-loop, directed); zero-bond `readABRXNFile` fixture; two-reaction builder fixture; existing golden references. Commands in [quickstart.md](quickstart.md).
- **User experience and diagnostics**: unchanged outputs; one additive action `'getFallbackCount'`; no new console output by default.
- **Performance and numerical integrity**: SC-001/SC-005 measured as in research R8; performance subordinate to exactness (fallback never returns an undecided pair as non-isomorphic).
- **External-solver configuration audit**: N/A (no solver).
- **Spec-driven scope control**: edit `src/analysis/topology/reactingMoieties/classifySubgraphIsomorphism.m`, `src/analysis/topology/reactingMoieties/readABRXNFile.m`, possibly `buildAtomAndBondTransitionMultigraph.m` only if the R7 test shows a defect; `KNOWN_ISSUES.md`; tests and test data. Read-only: every other source file, `deprecated/`, `external/`. No new abstraction beyond local functions.
- **MATLAB coding standards**: no evalc (VII-A), warnings visible (VII-B), try/catch keeps `ME.stack` (VII-C), optional arguments without `nargin` (VII-D), function help updated with provenance (VII-E).
- **Parameter-setting fidelity**: N/A.
- **Artifact placement**: source in `src/`; test fixtures beside their tests in `test/verifiedTests/analysis/testReactingMoieties/data/`, committed as normal binary `.mat` like the existing references there (the repository does not use Git LFS for them; the plan template's IX-G wording is not in the constitution); timing output to `results/` (gitignored).

## Project Structure

### Documentation (this feature)

```text
specs/20261012-093525-symmetric-iso-zero-bond/
├── spec.md
├── plan.md
├── research.md
├── quickstart.md
├── checklists/requirements.md
└── tasks.md            # next phase
```

### Source Code (repository root)

```text
src/analysis/topology/reactingMoieties/
├── classifySubgraphIsomorphism.m      # + local IR functions, fallback, getFallbackCount
├── readABRXNFile.m                    # empty-bond table fix
└── KNOWN_ISSUES.md                    # KI-001 update
test/verifiedTests/analysis/testReactingMoieties/
├── testClassifySubgraphIsomorphism.m  # + stuck pair, permuted, perturbed, randomized equivalence
├── testReadABRXNFile.m                # new: zero-bond fixture, explicit-H unchanged
├── testBuildAtomAndBondTransitionMultigraph.m  # + two-reaction zero-bond model
└── data/
    ├── nearSymmetricBondComponentPair.mat      # stuck pair (label-only copies)
    └── rxn/ (zero-bond and bonded RXN fixtures)
```

**Structure Decision**: local functions in the existing file (no new public function, so no new test file is required for it under III-Naming); one new test file for `readABRXNFile`, which has none today.

## Complexity Tracking

None.
