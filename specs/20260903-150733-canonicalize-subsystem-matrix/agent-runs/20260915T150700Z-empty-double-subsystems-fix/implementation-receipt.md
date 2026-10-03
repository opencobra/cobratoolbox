# Implementation Receipt: Subsystem Matrix Canonicalization — Empty-Double `subSystems` Entry Fix

**Feature**: `20260903-150733-canonicalize-subsystem-matrix`
**Date**: 2026-09-15 (UTC timestamp `20260915T150716Z`)
**Branch**: `20260903-150733-canonicalize-subsystem-matrix`

## Prompt

The user reported `testConvertOldStyleModel.m` failing in GitHub Actions CI (a
different environment from this session's sandbox, using a licensed Gurobi Docker
image per `.github/workflows/testAllCI_step1.yml`, not the broken-MOSEK-interface
sandbox this session otherwise runs in). The user diagnosed it themselves: manually
restoring the 2020 `verifyModel.m` suppression workaround (removed in the original
implementation run) made the test pass again, and identified the failing assertion as
line 153/154 (`res = verifyModel(testModel,'simpleCheck',true); assert(res == 1);`),
with `res` coming back `0` instead of `1`.

## Final response

Root-caused precisely: `testConvertOldStyleModel.m:152` sets
`testModel.subSystems(10) = {[]}` — paren-indexing a cell literal containing `[]`
assigns the *unwrapped* empty double `[]` (not `''`, not `{}`) to that position. The
Evaluator this feature installed in `COBRA_structure_fields.tab`
(`iscell(x) && all(cellfun(@(y) ischar(y) || (iscell(y) && all(cellfun(@ischar,y))), x))`)
only tolerated `''` and `{}` as legacy-empty representations, not a bare `[]` — so it
correctly-by-its-own-logic, but incorrectly-per-actual-codebase-convention, flagged
that reaction as malformed, which is exactly the regression the user found.

The user's workaround (restoring the blanket suppression) was **not kept** — that
would have silently regressed FR-006 back to "verifyModel never reports a real
`subSystems` error," reopening the exact bug this feature exists to fix. Instead,
fixed the actual root cause: the Evaluator now also accepts `isempty(y)` (covering
`[]`, `''`, and `{}` uniformly) before the `ischar`/cell-of-char checks, so it stays
exactly as strict for genuinely malformed content (a non-empty non-char non-cell
value, e.g. the existing `subSystems{20} = 5` fixture in `testVerifyModel.m`, still
correctly reports an error) while tolerating this additional pre-existing "empty"
convention. The suppression workaround in `verifyModel.m` was removed again (for the
second time), now backed by a validator that is actually correct rather than
over-strict.

Verified directly against the exact failing lines from `testConvertOldStyleModel.m`
(148–165) using this session's actually-working Gurobi installation (bypassing
`prepareTest`'s unrelated pre-existing quirk of resolving to a non-functional MOSEK
interface at line 22, which blocked running that test file end-to-end even before
this feature existed) — all four `verifyModel`/`convertOldStyleModel` assertions in
that range now pass. Also added a permanent regression fixture to `testVerifyModel.m`
covering this exact case, and re-ran the full existing regression suite to confirm no
other test relies on the stricter (bug-having) Evaluator behavior.

## Diff summary

3 files changed, 13 insertions(+), 3 deletions(-):

- `src/base/io/definitions/COBRA_structure_fields.tab` (+1/−1): `subSystems`
  Evaluator gains `isempty(y) ||` ahead of the `ischar`/cell-of-char checks.
- `src/reconstruction/modelGeneration/modelVerification/verifyModel.m` (+0/−2,
  net after the user's temporary manual revert and this fix's re-removal): the 2020
  suppression workaround is removed again, this time backed by a correct validator.
- `test/verifiedTests/reconstruction/testModelGeneration/testVerifyModel.m` (+12):
  new fixture asserting `subSystems(i) = {[]}` is tolerated, not reported as
  malformed.

## Tests

| Check | Result |
|---|---|
| Direct reproduction of `testConvertOldStyleModel.m:148-165` (the exact user-identified failing scenario) using this session's working Gurobi installation | PASS — `res`/`res2`/`res3` all `1`, all four assertions in that range pass |
| `testVerifyModel` (including the new empty-double fixture and the pre-existing malformed-value fixture `subSystems{20}=5`, confirming the Evaluator is not over-relaxed) | PASS |
| Full 7-test regression run (`testGetModelSubSystems`, `testFindRxnsFromSubSystem`, `testIsReactionInSubSystem`, `testBuildRxn2subSystem`, `testWriteSBML`, `testVerifyModel`, `testModel2JSON`) | PASS |

## Unresolved issues

- **`testConvertOldStyleModel.m` still cannot run end-to-end in this local sandbox**
  as a single `run(...)`/`runtests(...)` call: `prepareTest('needsLP',true,
  'useMinimalNumberOfSolvers',true)` at its line 19 resolves to `'mosek'` regardless
  of Gurobi being genuinely installed and working here, and the test's own line 22
  (`changeCobraSolver(solverPkgs.LP{1},'LP')`) then fails on that unusable MOSEK
  interface. This is a pre-existing `prepareTest`/environment quirk unrelated to this
  feature (confirmed reproducible before this feature's changes too) — the targeted
  reproduction above bypasses it by calling `changeCobraSolver('gurobi','LP')`
  directly, which is sufficient to confirm the actual regression is fixed, but is not
  the same as a clean full-file run. Real CI (Gurobi-based, per
  `.github/workflows/testAllCI_step1.yml`) should be checked to confirm this quirk
  doesn't also affect it.
- No broader audit was done for other pre-existing tests that might rely on `[]`
  (or another empty-ish sentinel not yet identified) in a `subSystems` entry; this fix
  was scoped to the specific case the user found.

## Other information

This is the third `agent-runs/` entry for this feature: the original implementation
(`20260907T120858Z-canonicalize-subsystem-matrix/`), the review-remediation round
(`20260907T131645Z-review-remediation/`), and this one — each documenting a distinct
round of work rather than being folded into an earlier receipt under its original
timestamp.
