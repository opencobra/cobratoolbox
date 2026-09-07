# Implementation Receipt: Subsystem Matrix Canonicalization

**Feature**: `20260903-150733-canonicalize-subsystem-matrix`
**Date**: 2026-09-07 (UTC timestamp `20260907T120858Z`)
**Branch**: `20260903-150733-canonicalize-subsystem-matrix`

## Context: why this run happened

`/speckit-specify`, `/speckit-plan`, `/speckit-tasks`, and `/speckit-analyze` all ran
earlier in this session (the spec/plan/research artifacts predated this session by a
few days, from 2026-09-03). `/speckit-specify`'s re-run added FR-011/SC-007 (an
explicit non-mutation requirement). `/speckit-tasks` found `model2JSON`'s test file
already existed but was undiscovered (research.md R7). `/speckit-analyze` found one
real coverage gap (FR-005 had an implementation task but no test — finding C1) plus
three low-severity notes. This `/speckit-implement` run executed all 28 tasks in
`tasks.md`, and found two further defects during execution that the spec/plan had
gotten wrong (both corrected in-flight, see below).

## Files changed

- `src/base/io/json/model2JSON.m` (T007/T008): the `catch` branch's `a{1}` (kept only
  the first subsystem name) replaced with `strjoin(a,';')` — a one-line fix that is a
  no-op for a single-element cell, so the existing single-subsystem output is
  unchanged by construction.
- `src/visualization/SAMMIM/sammi.m` (T011/T012): new `strcmp(parser,'subSystems')`
  branch computes subgraph membership via `buildRxn2subSystem`'s
  `rxn2subSystem`/`subSystemNames` (reusing them if already present) instead of
  `unique`/`ismember`; plus a local (non-mutating) flattening of any cell-shaped
  `subSystems` entry to a `;`-joined string before JSON serialization, needed for a
  second, independent defect found during implementation (see below).
- `src/analysis/exploration/getModelSubSystems.m` (T015/T016): consolidated three
  overlapping shape-specific branches (one provably dead) into the single
  flatten/`unique`/filter-empty loop that already handled all three legacy shapes
  correctly.
- `src/reconstruction/modelGeneration/modelVerification/verifyModel.m` (T020/T021):
  deleted the 2020 TODO workaround that unconditionally stripped every `subSystems`
  error, now unnecessary since the corrected validator (below) discriminates
  correctly on its own.
- `src/base/io/definitions/COBRA_structure_fields.tab` (T019): `subSystems`'s
  `Evaluator` corrected to accept both legacy cell shapes; two new rows registering
  `rxn2subSystem` (modeled on `rxnGeneMat`) and `subSystemNames` (modeled on
  `rxnNames`) as optional, derived fields.
- `test/verifiedTests/base/testIO/testModel2JSON` → `test/verifiedTests/base/testIO/testModel2JSON/testModel2JSON.m`
  (T005, `git mv`, content verified byte-identical) + extended (T006): this file
  already existed and was git-tracked, but missing its `.m` extension meant
  `test/testAll.m` never discovered it — now it does, for the first time.
- `test/verifiedTests/visualization/testSammi/testSammi.m` (T010): new case 12 —
  an equivalence oracle proving the new matrix-based grouping matches the old
  `unique`/`ismember` grouping exactly (modulo an empty-string name the old code
  spuriously included), plus the new nested-cell-grouping and non-mutation checks.
- `test/verifiedTests/analysis/testGetModelSubSystems/testGetModelSubSystems.m`
  (T014): added a `buildRxn2subSystem` cross-check and a non-mutation assertion.
- `test/verifiedTests/reconstruction/testModelGeneration/testVerifyModel.m` (T018):
  fixed the dead-code malformed-`subSystems` scenario (`(20) = {'blubb'}` →
  `{20} = 5`), added valid-flat/valid-nested/non-mutation assertions, and two more
  fixtures closing the FR-005 coverage gap found during `/speckit-analyze`.
- `specs/20260903-150733-canonicalize-subsystem-matrix/{spec.md,plan.md,research.md,quickstart.md,contracts/*.md,tasks.md}`:
  corrected in-flight to match what direct execution actually showed (see below);
  all 28 tasks marked `[X]`.
- **Not modified** (frozen, FR-008): `buildRxn2subSystem.m`, `isReactionInSubSystem.m`,
  `findRxnsFromSubSystem.m`, `isSameCobraModel.m`, `model2xls.m`, `xls2model.m`.

## Defects found in the spec/plan during implementation (not just in the source)

Constitution Principle V requires reading and mapping the relevant files before
editing, not just grepping. Doing so surfaced two things the spec/plan had gotten
wrong, both corrected in research.md/spec.md/plan.md/contracts before implementing
around them:

1. **FR-003 was circular as written.** `buildRxn2subSystem.m:73` already delegates
   its own name-enumeration to `getModelSubSystems` — so "have `getModelSubSystems`
   call `buildRxn2subSystem`" recurses infinitely. Separately, `getModelSubSystems`'s
   three-branch structure had a latent bug: `nestedCells` was computed by the exact
   same per-element test as `cellBool`, making the dedicated flat-cell-of-char branch
   unreachable dead code (confirmed empirically). FR-003 corrected to "consolidate the
   three branches into one" instead of "call `buildRxn2subSystem`" (research.md R8).
2. **`sammi.m`'s actual failure point and message differ from what research.md R4
   recorded.** Direct execution against the exact quickstart.md fixture shows
   `unique()` at line 156 throws first (`Cell array input must be a cell array of
   character vectors.`), not `ismember()` at line 160 as originally quoted. More
   importantly, fixing the grouping alone left `sammi()` still throwing — a *second*,
   independent, pre-existing defect in `makeSAMMIJson.m`'s generic per-reaction-field
   JSON serializer (reachable from every `sammi()` call, any `parser` value, whenever
   `subSystems` uses either cell legacy shape). Fixed by flattening a local copy of
   `model.subSystems` in `sammi.m` before serialization (not touching
   `makeSAMMIJson.m`, which is out of scope and general-purpose, not
   `subSystems`-specific) — the grouping computation itself uses the preserved raw
   shape, captured before flattening.

## Checks run and results

| Check | Result |
|---|---|
| T002 baseline: `testGetModelSubSystems`/`testFindRxnsFromSubSystem`/`testIsReactionInSubSystem`/`testBuildRxn2subSystem`/`testWriteSBML` | PASS (all 5); assertion counts 4/4/4/3/3 |
| T003 bug reproduction (pre-fix): `model2JSON` drops 2nd subsystem name; `sammi` throws on uniform nested-cell | Both confirmed |
| T009 `testModel2JSON` (relocated + extended) | PASS |
| T013 `testSammi` case 12 (equivalence oracle + nested-cell grouping + non-mutation), verified standalone | PASS |
| T013 regression, cases 0–3 (`ecoli_core_model`, `Recon2.v04`/`modelR204`, `iJO1366`/`compartment`), verified standalone | PASS |
| T017 `testGetModelSubSystems` (extended) | PASS, assertion count 4→6 |
| T022 `testVerifyModel` (fixed + extended) | PASS, assertion count 2→14 |
| T023 full regression run (7 of 8 target tests; `testSammi` excluded, see below) | PASS; 4 frozen tests' assertion counts unchanged |
| T024 `testLoadBiGGModel` (`isSameCobraModel` consumer) | PASS |
| T024 `testConvertOldStyleModel` (`isSameCobraModel` consumer) | FAILS at line 22 (`changeCobraSolver('mosek')`, not installed) — before any subSystems code; unrelated to this feature |
| T025 quickstart.md steps 1/3/4 (direct execution) | PASS; fixed a false-negative-prone whole-file `contains()` check in the doc's own Step 3 |
| T026 solver/network/GUI-call audit of all 5 edited files | Clean, none introduced |

## Residual unverified / out-of-scope items

- **`testSammi.m` could not run in this environment.** It is gated by
  `prepareTest('requiredToolboxes',{'statistics_toolbox'})` for its *entire* file
  (cases 0–12), and the Statistics and Machine Learning Toolbox is not licensed here
  (`license('test','statistics_toolbox')` returns 0) — confirmed pre-existing and
  unrelated to this feature. Verified the new logic (case 12) and a cases-0–3
  regression check via standalone scripts outside the toolbox gate instead. Cases
  4–11 and the full in-harness run are unverified in this environment.
  **Recommend a CI run before merge.**
- **`testConvertOldStyleModel.m` could not complete** for the same reason class
  (missing solver, not missing toolbox) — see table above. Recommend confirming in
  an environment with a licensed LP solver before merge.
- FR-005's own validator correctness (new in this run, per the C1 finding from
  `/speckit-analyze`) is now tested (T018's two new fixtures) but only against one
  malformed shape (dimension mismatch); other malformation modes (e.g. non-numeric
  `rxn2subSystem` content) are covered by the shared `Evaluator` logic but not by a
  dedicated fixture.

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
