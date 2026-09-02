# Implementation Receipt: 022-eliminate-table-object-hotspots

## Prompt

`/speckit-implement` (no additional user input), invoked after `/speckit-constitution` (pre-existing) → `/speckit-specify` → `/speckit-clarify` (no critical ambiguities found) → `/speckit-plan` → `/speckit-tasks` → `/speckit-analyze` (two remediation edits applied: F1 — corrected tasks.md T013's false claim that an existing test fixture exercises the try/catch parse-failure paths; E1 — added the SC-004 "averaged over at least 2 runs" wall-clock requirement to research.md R3 and tasks.md T002) had already produced an approved `spec.md`, `plan.md`, and `tasks.md` for this feature. MATLAB (R2024b, `/usr/local/MATLAB/R2024b`) and the external Tyrosine model/RXN-file paths from `spec.md`'s Assumptions section were both available in this environment, so all verification tasks were run for real rather than left blocked. Mid-implementation, the final combined reproducibility check (T014) showed SC-002/SC-003's percentage thresholds were not met; the user was asked how to proceed (AskUserQuestion) and chose "Document the gap, finish as-is."

## Final response

Feature 022-eliminate-table-object-hotspots is implemented and verified. Both FR-scoped fixes are in place, all tests pass, and output is byte-identical to the pre-change baseline — but SC-002/SC-003's percentage targets fall short, for a traced, documented reason (not a bug).

### What changed
- `readABRXNFile.m` (FR-001/FR-002): per-bond loop now builds a `containers.Map` lookup once (keyed by met/metNr/instance) instead of 4 redundant `find(...&ismember(...))` scans per bond; duplicate-key and no-match edge cases reproduce the exact pre-change error behavior.
- `buildAtomAndBondTransitionMultigraph.m` (FR-003/FR-004): both EdgeTable-building loops (atom-transition, bond-transition) now accumulate into plain preallocated arrays/cells and build the `table`/`digraph` once after each loop, instead of dot-indexing into a live table every iteration.

### Verification
- `testConservedReactingMoieties.m`: **PASSED**, unmodified, both after User Story 1 alone and after User Story 1 + User Story 2 combined.
- Direct `readABRXNFile` before/after comparison (ACONTm, real CI fixture, via a scoped `git stash` of just that file): atoms/bonds tables identical, all four bond columns (headAtomTransitionNrs, tailAtomTransitionNrs, headAtomElements, tailAtomElements) identical.
- Edge cases (no-match atom, duplicate `(met,metNr,instance)` key, zero-bond file): verified via a controlled synthetic-table test — the old (`find`-based) and new (map-based) logic throw the identical error identifier (`MATLAB:subsassigndimmismatch`) or both succeed identically, in all three cases.
- FR-007/FR-008 (mismatch warning, try/catch partial-accumulation state): verified by code trace only — confirmed no fixture in `test/` exercises either path (matches the finding surfaced during `/speckit-analyze`); the refactor changed only the write target (table dot-assignment → plain array indexing), not loop bounds, `k` increment placement, or exception boundaries, so both are provably unchanged.
- Tyrosine reproducibility check (139-reaction real benchmark, real atom-mapped RXN files): structural equality holds — `dATM.Nodes`/`dATM.Edges`, `dBTM.Nodes`/`dBTM.Edges`, and three sampled `atoms`/`bonds` tables are all byte-identical to the pre-change golden snapshot (SC-005 met), at both the interim (US1-only) and final (US1+US2) compare runs.
- Scope boundary: only `readABRXNFile.m` and `buildAtomAndBondTransitionMultigraph.m` are modified under `src/` (SC-006 met, verified via `git diff --name-only -- src/`). Function signatures byte-for-byte unchanged (FR-006 met, verified via diff of the `function [...] = ...(...)` declaration lines).

### SC-002 / SC-003: not met, root cause identified
- `cell.ismember`: 508,534 → 168,954 (**66.8%** reduction; target ≥90%)
- `tabular.dotAssign`: 772,794 → 396,969 (**48.6%** reduction; target ≥70%)
- `tabular.dotReference`: 1,863,426 → 1,351,986 (**27.4%** reduction; target ≥70%)
- Wall-clock (not gated, SC-004): 87.4s → 55.0s (**37% faster**)

Root cause: `buildAtomAndBondTransitionMultigraph.m`'s bond-transition loop (lines 677-684) contains a second, separate `ismember`-based node-lookup hotspot — 8 expressions per bond-transition instance, each calling `ismember(dATME.Nodes.mets, ...)` twice (16 `ismember` calls per iteration, scaled by `nTotalBondTransitions`), used to resolve node identities for `EdgeTable`'s Head/Tail-Bond-Atom fields. FR-003/FR-004, as written, govern only *how computed values get written* into `EdgeTable` ("accumulate its per-transition fields in preallocated plain arrays... construct the EdgeTable only once") — not *how those values are computed*. This lookup pattern is outside both FRs' literal scope. Per the user's explicit choice, this is documented here rather than fixed, to avoid expanding implementation beyond the approved `tasks.md` (Constitution Principle VI).

### Files changed
- `src/analysis/topology/reactingMoieties/readABRXNFile.m` (29 changed lines: the per-bond lookup replacement)
- `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m` (136 insertions, 86 deletions: both EdgeTable accumulator replacements)
- New: `specs/022-eliminate-table-object-hotspots/tyrosineReproducibilityCheck.m`, `tyrosine-golden-snapshot.mat`, `tyrosine-reproducibility-results.md`
- All 18 tasks in `tasks.md` are marked `[X]`.

### Unresolved issues
1. SC-002/SC-003 percentage thresholds not met (see above, root cause traced) — tracked, not fixed, per the user's explicit decision to document and finish as-is.
2. FR-007/FR-008 are verified by code trace only; no automated or real-data trigger exists for either the `nTotalAtomTransitions ~= k-1` warning or either try/catch's parse-failure path (a pre-existing gap, not introduced by this feature — confirmed via `git log` on commit `e95da5fa6`).
3. `quickstart.md` step 3's scope-boundary command (`git diff --name-only master... -- src/`) is misleading on this branch, since many prior features' commits already diverge from `master`; the working `T015` check used plain `git diff --name-only -- src/` (working tree vs `HEAD`) instead. `quickstart.md` itself was not corrected.
4. Generated artifacts (`.mat` snapshot, results `.md`) and this feature's planning docs sit untracked in git; not committed since the user has not asked for a commit.

## Diff summary

```text
 CLAUDE.md                                                                          |   2 +-
 src/analysis/topology/reactingMoieties/readABRXNFile.m                             |  29 +++-
 src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m      | 193 +++++++++++---------
 specs/022-eliminate-table-object-hotspots/*  (spec/plan/tasks/research/data-model/quickstart/contracts,
   tyrosineReproducibilityCheck.m, tyrosine-golden-snapshot.mat, tyrosine-reproducibility-results.md)
```

(CLAUDE.md's plan-pointer update and the planning artifacts under `specs/022-eliminate-table-object-hotspots/` were produced during the earlier `/speckit-plan`/`/speckit-tasks`/`/speckit-analyze` phases of this same session; listed for completeness of the feature's total diff.)

## Tests

- `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` — **PASSED** (unmodified), run twice: once after User Story 1 alone, once after User Story 1 + User Story 2.
- Direct `readABRXNFile` before/after comparison on `ACONTm.rxn` — **PASSED** (atoms/bonds field-for-field identical).
- Synthetic edge-case comparison (no-match, duplicate key, zero-bond) — **PASSED** (identical error identifier or identical success in all three cases, old vs. new).
- `specs/022-eliminate-table-object-hotspots/tyrosineReproducibilityCheck.m` — ran three times: 1× capture (pre-change baseline), 1× compare (post-US1), 1× compare (post-US1+US2, final). Structural-equality assertions **PASSED** every time (SC-005); percentage-reduction thresholds (SC-002/SC-003) **NOT MET** on the final run (see Unresolved Issues #1). Results in `tyrosine-reproducibility-results.md`.

## Unresolved issues

(see "Unresolved issues" under Final response above — repeated here per the standard receipt structure)

1. SC-002/SC-003 percentage thresholds not met; root cause traced to an out-of-FR-scope `ismember`-based node-lookup hotspot in the bond-transition loop. Documented per user decision, not fixed.
2. FR-007/FR-008 verified by inspection only, no test exercises either path (pre-existing).
3. `quickstart.md` step 3's `git diff` scope-boundary command uses a base (`master...`) that is misleading on this branch; not corrected in the file itself.
4. New/generated artifacts under `specs/022-eliminate-table-object-hotspots/` are untracked; no commit made.
