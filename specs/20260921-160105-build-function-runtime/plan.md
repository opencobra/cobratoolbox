# Implementation Plan: Cut the redundant RXN-file work and the per-bond element loop in buildAtomAndBondTransitionMultigraph, without changing its outputs

**Branch**: `20260921-160105-build-function-runtime` | **Date**: 2026-09-22 | **Spec**: `specs/20260921-160105-build-function-runtime/spec.md`

**Input**: Feature specification from `/specs/20260921-160105-build-function-runtime/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Three internal changes, no change to any output. (1) In `addBondMappingsRXNFile`, the
unchanged `energy = table(...)` statement moves from the top of the per-row loop into the
two reacting-bond branches that use it (research R3). (2) In
`buildAtomAndBondTransitionMultigraph`, the loop that writes `dBTM.Nodes.BondElmts` one cell
at a time becomes one `cellfun` over `dATME.Nodes.Element` indexed by the bond head/tail
atom indices, skipped when there are no bond nodes (R4). (3) `addBondMappingsRXNFile` gains
optional trailing `atoms, bonds` inputs; `checkABRXNFiles` and the bond loop hand it the
parse they already made, and `checkABRXNFiles`' block 2 reuses block 1's parse for the first
reaction, so each of the three passes parses each reaction once: `3r + 1` calls instead of
`5r + 3` (430 instead of 718 on bileacid, R1, R2). Nothing parsed outlives its loop iteration
(R6). Every `addBondMappingsRXNFile` call stays, so its own warning count is unchanged;
only `readABRXNFile` messages may repeat less (R5).

Evidence: the two existing tests unmodified; new CI tests `testAddBondMappingsRXNFile.m` and
`testCheckABRXNFiles.m` with expected values captured from the unmodified functions (R8); a
non-CI golden-snapshot harness over seven subsystem fixtures plus the CI fixture comparing
outputs, helper outputs, console text, alternating-order timing, call counts and peak memory
(R7).

## Technical Context

**Language/Version**: MATLAB R2024b (installed 24.2.0.3157250 Update 8); core `table`,
`cellfun`, `digraph`, `profile`, `diary`, `tic`/`toc` only.

**Primary Dependencies**: MATLAB core; COBRA Toolbox (`readCbModel`, `extractSubNetwork`,
`prepareTest`, `verifyCobraFunctionError`). No new dependency.

**Storage**: N/A for the toolbox. Feature artefacts: per-fixture `snapshots/*.mat`
(compressed `-v7`, stop-and-ask above 10 MB), append-only `reproducibility-results.md`; two
small expected-value `.mat` files beside the new tests.

**Testing**: `test/testAll.m` harness — `testConservedReactingMoieties.m`,
`testBuildAtomAndBondTransitionMultigraph.m` (both unmodified), new
`testAddBondMappingsRXNFile.m`, `testCheckABRXNFiles.m`; non-CI
`specs/20260921-160105-build-function-runtime/buildRuntimeReproducibilityCheck.m`
(Principle III documented-reproducibility fallback: the subsystem fixtures need external
model and corpus data).

**Target Platform**: headless Linux CI (GitHub Actions `testAllCI_*`, `.artenolis.yml`).

**Project Type**: single MATLAB toolbox library.

**Performance Goals**: whole-function median not slower than the original beyond measured
noise on every fixture (SC-004); `readABRXNFile` ≤ `3r + 2` calls (bileacid ≤ 431,
expected 430) and `energy` constructions = energy rows (SC-005). Subordinate to exact
equality (SC-001). Profile reference: ~58 of 140 profiled seconds on bileacid are in the
targeted code, reported but not gated.

**Constraints**: zero mismatches in any output, helper output or non-`readABRXNFile`
console line; no parse cache (FR-006); three `src/` files only; no message text changed.

**Scale/Scope**: ~30 changed source lines across three files plus header docs; two new
tests; one harness. Full-VMH target ~0.87 M bond nodes: the vectorised `BondElmts` is O(b)
with one table write; memory unchanged by construction.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: no formulation, solver, stoichiometry, or model field is
  touched; the atom and bond transition multigraphs and both decompositions are pinned by the
  golden snapshot and the unmodified tests. Principle II: `buildAtomAndBondTransitionMultigraph`
  and `checkABRXNFiles` keep their contracts exactly; `addBondMappingsRXNFile` gains two
  optional trailing inputs defaulting to the historical behaviour (additive,
  `contracts/public-contract.md`). The only observable change is the spec-approved FR-009
  reduction of repeated `readABRXNFile` messages. PASS.
- **Testing and reproducibility**: two new III-Naming test files (neither function has one),
  `prepareTest()` declared, expected values captured before the edit (R8); non-CI
  golden-snapshot check with corpus provenance, captured before the edit (R7, 029 R9). PASS.
- **User experience and diagnostics**: no message added, removed or reworded; every
  `addBondMappingsRXNFile` call kept so its warning count is unchanged; `readABRXNFile`
  messages appear at least once per pass that used to print them. Stack-frame lines
  (warning backtraces, `getReport` frames) change location by necessity and are exempt from
  exact comparison and reported instead (R5; spec FR-009, Clarifications 2026-09-22). PASS.
- **Performance and numerical integrity**: no check skipped or made optional;
  `checkABRXNFiles` still runs in full whatever `sanityChecks` is; no warning suppressed.
  Values are discrete (indices, strings, integer counts), so equality is exact
  (`isequaln`). Speed measured, not assumed (R7). PASS.
- **External-solver configuration audit**: N/A (R10).
- **Spec-driven scope control**: edit only, in `src/analysis/topology/reactingMoieties/`:
  `addBondMappingsRXNFile.m` (signature, header, parse guard at `:62`, `energy` at `:163`);
  `checkABRXNFiles.m` (`:102-118`, `:154-163`: pass the parse on, reuse block 1's parse);
  `buildAtomAndBondTransitionMultigraph.m` (`:637` call, `:808-813` loop). Read-only:
  `readABRXNFile.m`, `identifyAtomEquivalenceClasses.m`, the atom loop and probe (`:187-360`),
  per-reaction graph handling, the untracked `buildAtomAndBondTransitionMultigraph.asv`, both
  existing tests, every other `src/` file, `external/`. No new abstraction or dependency. PASS.
- **MATLAB coding standards**: no `evalc` (console via `diary`); no warning suppressed; no
  `try/catch` added or altered (VII-C); optional inputs via `exist`/`isempty`, not `nargin`
  (VII-D); headers updated with `USAGE:`/`OPTIONAL INPUTS:`/`NOTE:`/`Author:` (VII-E); no
  MATLAB skill registered, so the VII-F search and applied rules are in R9. PASS.
- **Parameter-setting fidelity**: N/A — no ported or literate output.
- **Artifact placement**: source edits in place; new tests and their `.mat` data in
  `test/verifiedTests/analysis/testReactingMoieties/` beside the fixtures they reuse; harness,
  snapshots and results under `specs/20260921-160105-build-function-runtime/`; baseline copies
  in a `tempname` directory, never committed. No file moves. PASS.

**Post-design re-check (after Phase 1)**: unchanged — all PASS. The design adds no `src/`
file, keeps parsed data within one loop iteration, and keeps every
`addBondMappingsRXNFile` call site, so the only console difference is the approved one plus
stack-frame locations (R5).

## Project Structure

### Documentation (this feature)

```text
specs/20260921-160105-build-function-runtime/
├── spec.md
├── plan.md                                  # this file
├── research.md                              # R1-R10
├── data-model.md                            # E1-E6
├── quickstart.md                            # validation steps 1-6
├── contracts/
│   └── public-contract.md                   # the three functions' contracts
├── buildRuntimeReproducibilityCheck.m       # NEW (implementation) — non-CI harness, capture/compare
├── snapshots/<fixture>-golden-snapshot.mat  # NEW (generated before the source edit)
├── reproducibility-results.md               # NEW (generated, append-only)
└── tasks.md                                 # /speckit-tasks output (not created here)
```

### Source Code (repository root)

```text
src/analysis/topology/reactingMoieties/
├── addBondMappingsRXNFile.m                 # MODIFIED — optional atoms/bonds; energy built in branches
├── checkABRXNFiles.m                        # MODIFIED — one parse per reaction, handed on
└── buildAtomAndBondTransitionMultigraph.m   # MODIFIED — bond-loop hand-on; vectorised BondElmts

test/verifiedTests/analysis/testReactingMoieties/
├── testAddBondMappingsRXNFile.m             # NEW (FR-013)
├── testCheckABRXNFiles.m                    # NEW (FR-013)
├── testConservedReactingMoieties.m          # UNCHANGED
├── testBuildAtomAndBondTransitionMultigraph.m  # UNCHANGED
└── data/
    ├── addBondMappingsRXNFileExpected.mat   # NEW — captured from unmodified function
    ├── checkABRXNFilesExpected.mat          # NEW — captured from unmodified function
    └── rxnFiles/                            # UNCHANGED — reused
```

**Structure Decision**: single MATLAB toolbox layout; all edits stay in the existing
`reactingMoieties` folder and the new tests sit beside the existing ones and their data.

## Implementation order (for `/speckit-tasks`)

1. Write `buildRuntimeReproducibilityCheck.m` (capture/compare modes, baseline copies via
   `git show`, provenance, console rule R5, alternating timing, profiler counts, fresh-process
   `VmHWM`). Run **capture** against the unmodified source (quickstart step 1). Gate:
   snapshots and expected-value files exist, provenance recorded, bileacid shows 718 parses,
   size ≤ 10 MB or user approval.
2. Write `testCheckABRXNFiles.m` and `testAddBondMappingsRXNFile.m`; run against the
   unmodified source (step 2).
3. `addBondMappingsRXNFile.m`: optional inputs + header (R2), `energy` in branches (R3).
4. `checkABRXNFiles.m`: hand on the parse, block-1 reuse (R1). Bond loop hand-on in
   `buildAtomAndBondTransitionMultigraph.m` (R1).
5. `buildAtomAndBondTransitionMultigraph.m`: vectorised `BondElmts` (R4).
6. Run the four CI tests, then **compare**, then static checks (steps 3-5). Stop on any FAIL.
   Each of steps 3-5 is separately revertible, so a failure can be bisected to one change.
7. Optional `pufa` timing (step 6).

## Resolved point

- **Stack-frame lines in the console comparison (R5)**: confirmed by the user on 2026-09-22
  and written into spec FR-009/FR-011 (Clarifications, Session 2026-09-22).

## Complexity Tracking

No constitution violations; no entries.
