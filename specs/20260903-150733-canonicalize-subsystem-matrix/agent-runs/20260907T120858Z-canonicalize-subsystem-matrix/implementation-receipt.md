# Implementation Receipt: Subsystem Matrix Canonicalization

**Feature**: `20260903-150733-canonicalize-subsystem-matrix`
**Date**: 2026-09-07 (UTC timestamp `20260907T120858Z`)
**Branch**: `20260903-150733-canonicalize-subsystem-matrix`

## Prompt

Triggering command: `/speckit-implement`, invoked with no arguments (the skill's
standard "execute `tasks.md`" instructions).

Preceding context in the same session that shaped this run: `/speckit-specify`
(re-run, added FR-011/SC-007 — an explicit `model.subSystems` non-mutation
requirement), `/speckit-plan`, `/speckit-tasks` (found `model2JSON`'s test file
already existed but was undiscovered — research.md R7), and `/speckit-analyze`
(found one real coverage gap, FR-005 had an implementation task but no test —
finding C1, plus three low-severity notes). The underlying `spec.md`/`plan.md`
were authored 2026-09-03, four days before this run.

## Final response

Implemented all 28 tasks across the four user stories (`model2JSON` multi-subsystem
export, `sammi` nested-cell grouping, `getModelSubSystems` consolidation,
`verifyModel` validation) plus setup/foundational/polish phases. All three legacy
`model.subSystems` shapes remain fully supported; `model.subSystems` itself is never
mutated by any of the three read/query functions (verified by explicit `isequal`
assertions, not just MATLAB's pass-by-value guarantee); the four already-converted
functions (`isReactionInSubSystem`, `findRxnsFromSubSystem`, `buildRxn2subSystem`,
`isSameCobraModel`) and their tests are untouched and still pass with unchanged
assertion counts.

Along the way, direct execution (not just reading the spec) surfaced and required
correcting two things the spec/plan had wrong: FR-003 as literally written would have
caused infinite recursion between `getModelSubSystems` and `buildRxn2subSystem` (they
already had an existing one-way dependency the spec didn't account for), and fixing
`sammi.m`'s grouping alone wasn't sufficient to stop it throwing on a nested-cell
model — a second, independent, pre-existing bug in `makeSAMMIJson.m`'s generic
per-field JSON serializer also had to be worked around locally within `sammi.m`,
without touching that out-of-scope file. Both corrections are documented in
research.md (R4 amendment, R8) and reflected in spec.md/plan.md/contracts.

Also fixed, as directed: `model2JSON`'s existing test file (git-tracked since 2024,
never actually run because it was missing its `.m` extension) is now relocated to the
correct path and discoverable by `test/testAll.m` for the first time.

Two things could not be verified in this sandboxed environment and should be
confirmed in CI before merge: `testSammi.m`'s full 13-case suite (blocked by a
missing Statistics Toolbox license — the new case 12 and a cases-0–3 regression check
were verified via standalone scripts instead) and `testConvertOldStyleModel.m`
(blocked by a missing MOSEK installation, at a line unrelated to this feature).
Everything else — all four already-converted functions' regression suite, the new
`testModel2JSON`, `testGetModelSubSystems`, and `testVerifyModel` assertions, and the
full quickstart.md validation script — ran and passed directly in this session.

## Diff summary

24 files changed, 1280 insertions(+), 120 deletions(-) (commit `a9cdcb790`).

Source (5):
- `src/base/io/json/model2JSON.m` (+4/−1, T007/T008): the `catch` branch's `a{1}`
  (kept only the first subsystem name) replaced with `strjoin(a,';')`.
- `src/visualization/SAMMIM/sammi.m` (+63/−5, T011/T012): new
  `strcmp(parser,'subSystems')` branch computes subgraph membership via
  `buildRxn2subSystem`'s `rxn2subSystem`/`subSystemNames`; local, non-mutating
  flattening of cell-shaped `subSystems` entries before JSON serialization.
- `src/analysis/exploration/getModelSubSystems.m` (+13/−36, T015/T016): consolidated
  three overlapping shape-specific branches (one provably dead) into one.
- `src/reconstruction/modelGeneration/modelVerification/verifyModel.m` (+0/−18,
  T020/T021): deleted the 2020 TODO workaround.
- `src/base/io/definitions/COBRA_structure_fields.tab` (+3/−1, T019): `subSystems`
  Evaluator corrected; `rxn2subSystem`/`subSystemNames` registered as two new rows.

Tests (4, one relocated):
- `test/verifiedTests/base/testIO/testModel2JSON` → `.../testModel2JSON/testModel2JSON.m`
  (T005 `git mv`, content byte-identical; T006 extended, +40/−0 net).
- `test/verifiedTests/visualization/testSammi/testSammi.m` (+66, T010): new case 12.
- `test/verifiedTests/analysis/testGetModelSubSystems/testGetModelSubSystems.m`
  (+12, T014).
- `test/verifiedTests/reconstruction/testModelGeneration/testVerifyModel.m` (+52/−3,
  T018).

Spec Kit bookkeeping (15):
- `CLAUDE.md`, `.specify/feature.json` (+1/−1 each): repointed from the previous
  feature to this one (routine Spec Kit convention on this fork, not new content).
- `specs/20260903-150733-canonicalize-subsystem-matrix/{spec.md,plan.md,research.md,
  quickstart.md,data-model.md,tasks.md,checklists/requirements.md,contracts/*.md}`
  (13 files, all new to this branch): the spec/plan/research/task artifacts this run
  executed and, in three cases, corrected in-flight against what direct execution
  showed (research.md R4 amendment/R8; spec.md FR-003/FR-009 corrections).
- `specs/.../agent-runs/20260907T120858Z-canonicalize-subsystem-matrix/implementation-receipt.md`
  (this file).

Not modified (frozen, FR-008): `buildRxn2subSystem.m`, `isReactionInSubSystem.m`,
`findRxnsFromSubSystem.m`, `isSameCobraModel.m`, `model2xls.m`, `xls2model.m`.

## Tests

| Check | Result |
|---|---|
| T002 baseline: `testGetModelSubSystems`/`testFindRxnsFromSubSystem`/`testIsReactionInSubSystem`/`testBuildRxn2subSystem`/`testWriteSBML` | PASS (all 5); assertion counts 4/4/4/3/3 |
| T003 bug reproduction (pre-fix): `model2JSON` drops 2nd subsystem name; `sammi` throws on uniform nested-cell | Both confirmed |
| T009 `testModel2JSON` (relocated + extended) | PASS |
| T013 `testSammi` case 12 (equivalence oracle + nested-cell grouping + non-mutation), verified standalone | PASS |
| T013 regression, cases 0–3 (`ecoli_core_model`, `Recon2.v04`/`modelR204`, `iJO1366`/`compartment`), verified standalone | PASS |
| T017 `testGetModelSubSystems` (extended) | PASS, assertion count 4→6 |
| T022 `testVerifyModel` (fixed + extended) | PASS, assertion count 2→14 |
| T023 full regression run (7 of 8 target tests; `testSammi` excluded, see Unresolved issues) | PASS; 4 frozen tests' assertion counts unchanged |
| T024 `testLoadBiGGModel` (`isSameCobraModel` consumer) | PASS |
| T024 `testConvertOldStyleModel` (`isSameCobraModel` consumer) | FAILS at line 22 (`changeCobraSolver('mosek')`, not installed) — before any subSystems code; unrelated to this feature |
| T025 quickstart.md steps 1/3/4 (direct execution) | PASS; fixed a false-negative-prone whole-file `contains()` check in the doc's own Step 3 |
| T026 solver/network/GUI-call audit of all 5 edited files | Clean, none introduced |

## Unresolved issues

- **`testSammi.m` could not run in this environment.** It is gated by
  `prepareTest('requiredToolboxes',{'statistics_toolbox'})` for its *entire* file
  (cases 0–12), and the Statistics and Machine Learning Toolbox is not licensed here
  (`license('test','statistics_toolbox')` returns 0) — confirmed pre-existing and
  unrelated to this feature. Verified the new logic (case 12) and a cases-0–3
  regression check via standalone scripts outside the toolbox gate instead. Cases
  4–11 and the full in-harness run are unverified in this environment.
  **Recommend a CI run before merge.**
- **`testConvertOldStyleModel.m` could not complete** for the same reason class
  (missing solver, not missing toolbox) — see Tests table. Recommend confirming in
  an environment with a licensed LP solver before merge.
- FR-005's own validator correctness (per the C1 finding from `/speckit-analyze`) is
  now tested (T018's two new fixtures) but only against one malformed shape
  (dimension mismatch); other malformation modes are covered by the shared
  `Evaluator` logic but not by a dedicated fixture.

## Other information

Two defects in the spec/plan itself (not the source) were found via direct execution
(Constitution Principle V) and corrected before implementing around them — see
research.md R4's amendment and R8 for the full detail; summarized above under Final
response and in the Diff summary's Spec Kit bookkeeping entry.
