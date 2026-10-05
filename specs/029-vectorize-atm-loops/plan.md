# Implementation Plan: Vectorize the stage02 reorientation loop and createBIGraph's edge-expansion loop

**Branch**: `029-vectorize-atm-loops` | **Date**: 2026-09-18 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/029-vectorize-atm-loops/spec.md`

## Summary

Two pure-performance rewrites inside `identifyConservedReactingMoieties.m`'s unconditional
pre-branch section, both replacing per-row work with bulk operations, and both required to be
bit-identical (`isequal`) to today's output: (1) the stage02 reorientation loop
(`identifyConservedReactingMoieties.m:321-335`) which rebuilds `Trans` with `strtok` and
reassigns four other `ATM.Edges` columns one row at a time via table dot-indexing; (2)
`createBIGraph.m`'s nested edge-expansion loop (`createBIGraph.m:38-61`) which grows
`srcNodes`/`tgtNodes`/every property array by `[array; x]` concatenation once per bond
instance (O(n^2)). Both are rewritten **inline, in place** (Clarifications: no new `src/`
files). Correctness is established by a non-CI, per-fixture-resumable reproducibility check
under `specs/029-vectorize-atm-loops/`, extending the feature 021/022
`tyrosineReproducibilityCheck.m` pattern to all 8 reconXmoieties fixtures, every one run
through the normal pipeline, with corpus provenance recorded per snapshot so a data change is
never mistaken for a code regression (Clarifications: `SCP2x.rxn` quarantined, `bileacid`
restored as an ordinary fixture).

## Technical Context

**Language/Version**: MATLAB, R2024b+ baseline (Constitution Scientific Computing Constraints).

**Primary Dependencies**: None new. Uses only base MATLAB already used by these files —
`graph`/`digraph`, `repelem`, `cellfun`, logical indexing, `strtok`. The reconXmoieties
prototypes (`reorientATMEdgesVectorized.m`, `createBIGraphVectorized.m`) are reference
implementations only; no code is imported from that repository (spec Assumptions).

**Storage**: Golden-snapshot `.mat` files (one per fixture) plus an append-only results
`.md`, under `specs/029-vectorize-atm-loops/`, matching the 021/022 precedent. Large
snapshots are handled per the placement decision in research.md (R7).

**Testing**: Two tiers. (1) CI: `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
must pass and is not edited at all (FR-009, SC-001) — it exercises both rewritten code paths on
the small self-contained fixture, since both run unconditionally. A **new** CI file,
`test/verifiedTests/analysis/testReactingMoieties/testCreateBIGraph.m`, pins `createBIGraph`'s
edge cases on synthetic graphs as a characterization test written and passed against the
unmodified function before the rewrite (analysis finding G2; permitted by III-Naming, since the
function has no test file yet). (2) Non-CI documented reproducibility check (Constitution
Principle III's sanctioned substitute): `specs/029-vectorize-atm-loops/vectorizationReproducibilityCheck.m`,
capture-then-compare per fixture across all 8 fixtures (FR-010, FR-011), plus a
`sanityChecks = 1` pass on `tyr` and a synthetic stage02 edge-case section (research.md R10,
R12).

**Target Platform**: Headless Linux (`matlab -batch`). The CI test is self-contained; the
reproducibility check is **not** CI-runnable — it depends on external, non-repo data (the
atom-mapped corpus at `/media/JACK/repos/ctf/rxns/atomMapped_std` and the subsystem submodels
under `~/repos/ReconXKG-cidev/...`) and on multi-hour runtimes at the largest fixture.

**Project Type**: Library (two existing MATLAB functions in the COBRA Toolbox source tree; no
new `src/` file, no new dependency).

**Performance Goals**: SC-004 — on `tyr`, ≥100x for stage02 and ≥200x for `createBIGraph`,
measured by temporary `tic`/`toc` and reported as numbers, not just pass/fail. Prior
reconXmoieties measurements (262.7x and 799.2x) sit well above these floors.

**Constraints**: Output must be `isequal` to the pre-change implementation for every column
named in FR-001/FR-003, in the same row order (this includes faithfully reproducing behaviour
that is arguably wrong today — see research.md R3 and R5, which must NOT be "fixed" here).
Public signatures unchanged (FR-004, FR-005, SC-006). No timing code ships in `src/`
(Clarifications). Exactly two `src/` files change (SC-005).

**Scale/Scope**: 8 fixtures spanning 3 to 682 reactions (`nglycan` … `pufa`). Measured
2026-09-17 on this machine: the small six complete in seconds to ~1 minute; `pufa`'s graph
build alone is ~744 s and its full-mode `identifyConservedReactingMoieties` exceeded 3 h 48 min
without completing, so capture+compare for `pufa` is a multi-hour, possibly multi-session
activity — hence the per-fixture resumability requirement in FR-011.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: Neither hotspot performs any model, solver, or numerical
  computation — stage02 corrects edge orientation bookkeeping (`Trans`, head/tail indices and
  names) after `graph()` reorients edges, and `createBIGraph` expands weighted bond edges into
  one edge per bond instance. The scientific content is unchanged by construction: the
  acceptance bar is `isequal` output, not "equivalent" output. No stoichiometry, bounds,
  objective, or status semantics are touched (Principle I).

- **Testing and reproducibility**: `testConservedReactingMoieties.m` is the CI-level guard and
  must pass unmodified (FR-009, SC-001); it reaches both rewritten paths because both execute
  before the `conservedMoietiesOnly` branch. Because that fixture is tiny (3 reactions), it
  proves correctness-in-kind but not at scale, so Principle III's documented-reproducibility-check
  substitute carries the scale evidence: a per-fixture capture/compare script over all 8
  fixtures (FR-010/FR-011), reporting `isequal` outcomes and before/after timings into an
  append-only results file. `prepareTest` requirement declarations are unchanged — this feature
  adds no new solver requirement (neither code path calls a solver).

- **User experience and diagnostics**: No console output, warnings, or returned fields are
  added or removed. The two existing guards that bracket these hotspots — the `sanityChecks`
  block after stage02 and the `if ~isequal(BIG.Nodes, dATM.Nodes)` check after `createBIGraph`
  — must keep passing unmodified and must not be weakened to accommodate the rewrite (FR-006).

- **Performance and numerical integrity**: This feature is *only* performance, and the
  constitution's ordering (performance strictly subordinate to correctness) is enforced here by
  the `isequal` acceptance bar: any rewrite that is faster but not byte-identical fails. No
  diagnostic or verification step is removed or made skippable; `sanityChecks`-gated work is
  untouched. The temporary `tic`/`toc` used for SC-004 is reverted before commit, so the
  shipped diff contains no measurement scaffolding.

- **External-solver configuration audit**: N/A — neither the stage02 reorientation nor
  `createBIGraph` invokes any external solver or library. (`identifyConservedReactingMoieties`'s
  only solver call is the STEP 4 set-cover MILP, far downstream of both hotspots and untouched
  by this feature.)

- **Spec-driven scope control**: Exactly two `src/` files are edited —
  `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m` (stage02 lines
  ~321-335) and `src/analysis/topology/reactingMoieties/createBIGraph.m` (lines ~38-61 plus the
  property-assignment tail). Everything else under `src/` is read-only for this feature
  (SC-005), including the pre-existing `bileacid`/`SCP2x.rxn` atom-mapping defect, which is
  explicitly out of scope (FR-007). `createBIGraph.m` has exactly one production caller
  (`identifyConservedReactingMoieties.m:566`, verified by grep over `src/`, `test/`,
  `tutorials/`), so no other call site is affected and no production caller is added (FR-008).
  The new test file and the reproducibility harness call it directly, which FR-008 permits.

- **MATLAB coding standards**: The rewrite must not introduce `evalc` (VII-A), must not
  suppress warnings (VII-B), and introduces no `try/catch` (VII-C) — none is needed for a pure
  vectorization. No `nargin` is introduced (VII-D); neither function's argument contract
  changes. Help headers are unchanged in content, since neither signature nor documented
  behaviour changes (VII-E, SC-006); an in-body comment explaining the vectorized reverse-edge
  swap is warranted only where the index bookkeeping is non-obvious. Vectorization idioms
  (`repelem`, logical masks, `cellfun`) are MATLAB-native, not Python-style refactors (VII-F);
  no project MATLAB-lint skill is registered (checked, as in features 026/028), so the
  openCOBRA style guide governs (VII-G).

- **Parameter-setting fidelity**: N/A — no cross-language port, render, or literate output.

- **Artifact placement**: No new `src/` file (Clarifications). The reproducibility check,
  its per-fixture golden snapshots, and its results file live under
  `specs/029-vectorize-atm-loops/`, exactly as features 021 and 022 placed theirs. Snapshot
  size is the one placement question this feature must answer rather than inherit — see
  research.md R7 and Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/029-vectorize-atm-loops/
├── plan.md                                # This file
├── research.md                            # Phase 0 output
├── data-model.md                          # Phase 1 output
├── quickstart.md                          # Phase 1 output
├── contracts/
│   └── function-interface.md              # Phase 1 output — the two unchanged contracts
├── vectorizationReproducibilityCheck.m    # FR-010 harness (created during implementation)
├── snapshots/                             # per-fixture golden snapshots (see research.md R7)
├── vectorization-reproducibility-results.md  # append-only results (created during implementation)
└── tasks.md                               # Phase 2 output (/speckit-tasks — not created here)
```

### Source Code (repository root)

**Structure Decision**: Single-library MATLAB toolbox feature. Two existing files are modified
in place; no new source directory and no new source file (Clarifications: inline rewrite).

```text
src/analysis/topology/reactingMoieties/
├── identifyConservedReactingMoieties.m     # MODIFIED: stage02 loop (lines ~321-335) vectorized
└── createBIGraph.m                         # MODIFIED: edge-expansion loop (lines ~38-61) vectorized

test/verifiedTests/analysis/testReactingMoieties/
├── testConservedReactingMoieties.m         # UNCHANGED — must pass, not edited at all
└── testCreateBIGraph.m                     # NEW — characterization test for createBIGraph edge cases
```

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|---------------------------------------|
| Golden-snapshot `.mat` artifacts are committed under `specs/029-vectorize-atm-loops/snapshots/` | The capture/compare design (inherited from features 021/022) requires the pre-change output to persist across the code change; `isequal` against a stored baseline is the feature's entire correctness argument | Recomputing the baseline on demand is impossible once the code is changed; storing only hashes would satisfy pass/fail but destroy the ability to diagnose *where* a mismatch occurred. Size is bounded by R7's policy (large fixtures' snapshots stay out of the repo) |
