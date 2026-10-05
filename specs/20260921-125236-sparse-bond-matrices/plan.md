# Implementation Plan: Return buildAtomAndBondTransitionMultigraph's bond matrices as sparse, without changing its original behaviour

**Branch**: `20260921-125236-sparse-bond-matrices` | **Date**: 2026-09-21 | **Spec**: `specs/20260921-125236-sparse-bond-matrices/spec.md`

**Input**: Feature specification from `/specs/20260921-125236-sparse-bond-matrices/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

`buildAtomAndBondTransitionMultigraph` allocates `M2BiE`, `M2BiW` (dense `m x b`) and
`BTi2R` (`full(sparse(...))`, `s x n`) although each holds about one non-zero per
column/row — ~330 GB at full-VMH scale versus ~65 MB sparse. This feature builds all
three with `sparse` in one pass over the bond nodes (one `ismember` of
`dBTM.Nodes.mets` against `model.mets`, replacing two loops that scan every bond node
once per metabolite; research R1), drops the `full` around `BTi2R` (R2), and adds
`options.denseBondMatrices` (default `0`). When it is `1`, the three matrices are
converted with `full` immediately after construction, before the bond residual check,
so the rest of the function — and its return values and printed diagnostics — runs
exactly as today (R3). Values, sizes, element class and every check/warning/error are
unchanged; the only default-mode difference is `issparse` (approved breaking change,
FR-010).

Evidence: the unmodified `testConservedReactingMoieties.m`; a new CI test
`testBuildAtomAndBondTransitionMultigraph.m` covering sparse default, dense opt-in,
cross-mode equality, zero residuals and the mismatch-report branch on a deliberately
inconsistent fixture (R6); and a non-CI golden-snapshot reproducibility check captured
from the unmodified function before any source edit, over tyrosine, the CI fixture and
eight further self-contained fixtures (including `bondTransitionMultigraph = 0` and a
no-RXN-file degenerate case), with storage and fill-step timing reports (R7, R8).

## Technical Context

**Language/Version**: MATLAB R2024b (installed: 24.2.0.3157250 Update 8), the
constitution's supported baseline; only core `sparse`, `ismember`, `full`, `diary`,
`tic`/`toc` used.

**Primary Dependencies**: MATLAB core; COBRA Toolbox (`readCbModel`,
`extractSubNetwork`, `prepareTest`). No new dependency.

**Storage**: N/A for the toolbox. Feature artifacts: `golden-snapshot.mat` (compressed
`-v7`; stop-and-ask if > 10 MB) and append-only `reproducibility-results.md` under
`specs/20260921-125236-sparse-bond-matrices/`.

**Testing**: `test/testAll.m` harness —
`testConservedReactingMoieties.m` (unmodified) and new
`testBuildAtomAndBondTransitionMultigraph.m` (FR-015); non-CI
`specs/20260921-125236-sparse-bond-matrices/reproducibilityCheck.m` (FR-012/FR-013,
Principle III documented-reproducibility fallback: the tyrosine fixture depends on
external model and corpus data).

**Target Platform**: headless Linux CI (GitHub Actions `testAllCI_*`, `.artenolis.yml`).

**Project Type**: single MATLAB toolbox library.

**Performance Goals**: the three matrices' combined default storage ≤ 10% of dense on
fixtures with ≥ 50 metabolites and reactions (SC-004); `M2BiE`/`M2BiW` fill-step median
of 5 runs on tyrosine not slower than before (SC-005). Subordinate to exact value
equality (SC-001).

**Constraints**: zero value mismatches across all twelve outputs; no change to any
check/warning/error text or condition; only one `src/` file changes; mismatch-report
expressions untouched (research R4).

**Scale/Scope**: three matrix constructions, two loops, one option, header docs; one
new CI test; one feature-local harness. Target scale ~11,857 metabolites, ~0.87 M bond
nodes, ~1.42 M bond transitions (sparse build is O((b + m) log(b + m))).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: Touches no formulation, solver, or model-structure
  field. Output contract of one analysis function changes storage class only
  (`contracts/public-contract.md`). **Principle II departure, restated per FR-010**:
  a new optional argument (`denseBondMatrices`) whose default (`0`, sparse) is *not*
  the historical behaviour. Approved by spec FR-010 because the historical default
  cannot run at the toolbox's target scale, values are unchanged, and
  `options.denseBondMatrices = 1` restores the historical output bit-for-bit; the
  migration path is documented in the function header (FR-004, SC-007). PASS (approved
  deviation).
- **Testing and reproducibility**: Narrowest tests — new
  `testBuildAtomAndBondTransitionMultigraph.m` (III-Naming: the function has no test
  of its own name yet; `testConservedReactingMoieties.m` is a workflow test and stays
  unmodified per FR-011); non-CI golden-snapshot check for the external tyrosine
  fixture with corpus provenance, captured before any source edit. PASS.
- **User experience and diagnostics**: No diagnostic added, removed or reworded. Dense
  mode runs the residual check and mismatch report on full matrices exactly as today;
  default mode prints identical content (R4 argument, verified by FR-015 (e)). PASS.
- **Performance and numerical integrity**: Memory for the three matrices drops from
  O(m·b + s·n) to O(b + s). Residuals are exact in both modes (integer/dyadic
  arithmetic, R4). No check made skippable; `sanityChecks` default unchanged. Speed is
  subordinate to value equality, which is gated first (SC-001). PASS.
- **External-solver configuration audit**: N/A — no solver invoked by the changed code
  or the new test.
- **Spec-driven scope control**: Edit only
  `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m`:
  options block (lines 150-155), header option/output docs (lines 72-76, 139-141), and
  matrix construction (lines 879-898, plus the dense-mode conversion). Add
  `test/verifiedTests/analysis/testReactingMoieties/testBuildAtomAndBondTransitionMultigraph.m`.
  Read-only: every other `src/` file, `testConservedReactingMoieties.m`, the residual
  check and mismatch report (lines 953-976), the `dATME` rebuild, atom-side code, the
  inaccurate `USAGE` line (58), `external/`, `binary` (pre-existing unrelated
  modification, untouched). No new dependency or abstraction. PASS.
- **MATLAB coding standards**: no `evalc` (console captured with `diary`, which keeps
  output visible — R6); no warning suppressed (VII-B); no `try/catch` added (VII-C); no
  `nargin` (options via `isfield`, VII-D); new test carries the openCOBRA header
  (VII-E, VII-G); no MATLAB skill is registered, so the VII-F targeted search is
  recorded in research R9, its rules are applied to R1, R2 and R6, and a project skill
  is proposed there. PASS.
- **Parameter-setting fidelity**: N/A — no ported or literate output.
- **Artifact placement**: source edit stays in its existing domain folder; new test in
  the existing `test/verifiedTests/analysis/testReactingMoieties/` beside its fixtures
  (reuses `data/rxnFiles`, adds no data); harness, snapshot and results are Spec Kit
  artifacts under `specs/20260921-125236-sparse-bond-matrices/` (IX, 021/022/20260902
  precedent). No file moves. PASS.

**Post-design re-check (after Phase 1)**: unchanged — all PASS, one approved Principle
II deviation (FR-010). Design adds no `src/` file (unlike feature 20260902's helper),
keeps diagnostics textually identical, and routes all evidence through the existing
harness plus one feature-local script.

## Project Structure

### Documentation (this feature)

```text
specs/20260921-125236-sparse-bond-matrices/
├── spec.md
├── plan.md                          # this file
├── research.md                      # R1-R9
├── data-model.md                    # E1-E6
├── quickstart.md                    # validation steps 1-5
├── contracts/
│   └── public-contract.md           # signature, options, output guarantees, breaking-change note
├── checklists/requirements.md
├── reproducibilityCheck.m           # NEW (implementation) — non-CI FR-012/FR-013 harness
├── golden-snapshot.mat              # NEW (generated, pre-change capture)
├── reproducibility-results.md       # NEW (generated, append-only)
└── tasks.md                         # /speckit-tasks output (not created here)
```

### Source Code (repository root)

```text
src/analysis/topology/reactingMoieties/
└── buildAtomAndBondTransitionMultigraph.m   # MODIFIED — option default + header docs; one-pass sparse M2BiE/M2BiW; BTi2R without full; dense-mode conversion

test/verifiedTests/analysis/testReactingMoieties/
├── testBuildAtomAndBondTransitionMultigraph.m   # NEW — FR-015 (a)-(f)
├── testConservedReactingMoieties.m              # UNCHANGED (FR-011, SC-002)
└── data/rxnFiles/                               # UNCHANGED — reused fixture data
```

**Structure Decision**: single MATLAB toolbox layout; the change stays inside the
existing `reactingMoieties` domain folder, and the new test sits beside the existing
test and fixtures it reuses. No `tests/contract|integration|unit` split applies.

## Implementation order (for `/speckit-tasks`)

1. Write `reproducibilityCheck.m`; run it in capture mode against the **unmodified**
   source (quickstart step 1). Gate: snapshot exists, provenance recorded, originals
   confirmed full `double`, every fixture's original residuals recorded (stop if a
   required fixture's, `tyr` or `ci`, is nonzero — R7), snapshot ≤ 10 MB or user approval.
2. Write `testBuildAtomAndBondTransitionMultigraph.m`; confirm (d) and the
   pre-change parts of (e) pass against the unmodified source, and (a) fails
   (establishes the test detects the change).
3. Modify `buildAtomAndBondTransitionMultigraph.m` (R1, R2, R3, R5).
4. Run both CI tests, then the reproducibility check in compare mode, then the static
   checks (quickstart steps 2-4). Stop on any FAIL (R4 fallback applies to (e)).
5. Optional FR-014 full-VMH demonstration.

**Naming note**: the harness is `reproducibilityCheck.m`, not
`tyrosineReproducibilityCheck.m` as in features 021/022, because it covers the
tyrosine fixture plus the CI fixture and further self-contained fixtures.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Principle II: new optional argument whose default is not the historical behaviour | Historical dense default needs ~330 GB at the toolbox's target (full-VMH) scale; sparse default is the only way the function can be called there without every caller opting in | Defaulting `denseBondMatrices` to `1` (historical) would leave every existing full-scale call — including the pipeline via `identifyConservedReactingMoieties` callers — out of memory unless each is edited; values are identical either way and the opt-in restores the historical output exactly (spec FR-010) |
