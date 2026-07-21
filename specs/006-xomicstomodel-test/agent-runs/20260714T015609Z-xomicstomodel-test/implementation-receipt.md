# Implementation Receipt — XomicsToModel test (006)

**UTC**: 2026-07-14T01:56:09Z · **Branch**: 006-xomicstomodel-test ·
**Gate 2**: "Approve all tasks" · **Invocation**: `/speckit-implement`

## Prompt

Repurpose the XomicsToModel tutorial into full-mode-only tests that cover XomicsToModel
and thermoKernel (approved scope T001–T008), given the verified finding that XomicsToModel
is a heavyweight (~10 min) run.

## Final response

Added two full-mode-only tests that drive `XomicsToModel` end-to-end on the shipped
generic model (`papers/2023_iDopaNeuro/Recon3DModel_301_xomics_input.mat`) and the tutorial's
omics data (copied beside the test), one with `fastCore` and one with `thermoKernel` — so both
previously-untested functions (`XomicsToModel` and `thermoKernel`), plus `preprocessingOmicsModel`
and `fastcc`, are now covered. Both extractors were run to completion first (T001/T002): fastCore
→ 1375×2222, 1235 genes; thermoKernel → 1393×2232, 1231 genes; both feasible. Each test guards
`getCobraTestMode()=='fast'` and skips cleanly (COBRA:RequirementsNotMet) in fast/default mode, so
routine runs are unaffected; each runs in full mode / CI. Assertions are genuine (no smoke run): the
extracted model is a proper smaller submodel, is feasible (`optimizeCbModel` stat==1), matches the
captured size within 5%, and retains ≥85% of the 334 bibliomic core reactions (fastCore keeps 296,
thermoKernel 300). Requirements declared via `prepareTest('needsLP',true,'needsMILP',true)`; figures
generated invisibly (DefaultFigureVisible off + onCleanup). Verified: both PASS in full mode
(fastCore 553s, thermoKernel 550s) and both SKIP in fast mode; checkcode clean bar the by-design
`global` warnings. No `src` change.

## Diff summary

Test-only (all NEW, under `test/verifiedTests/dataIntegration/testXomicsToModel/`):
- `testXomicsToModel_fastCore.m` — XomicsToModel + fastCore (full-mode-only).
- `testXomicsToModel_thermoKernel.m` — XomicsToModel + thermoKernel (full-mode-only).
- `data/{bibliomicData.xlsx, exometabolomicData.txt, transcriptomicData.txt}` — omics fixtures
  copied from the tutorial (submodule-independent). The 4.6 MB generic model is referenced from
  its shipped `papers/2023_iDopaNeuro/` path (CBTDIR-anchored, clean skip if the submodule is absent).
No src/interface/result change. No submodule modified (papers/tutorials read-only).

## Tests

- Reference capture (T001/T002): fastCore XOMICS_OK t=571.9s size 1375×2222 nGenes=1235 optStat=1;
  thermoKernel XOMICS_OK t=562.8s size 1393×2232 nGenes=1231 optStat=1. Core retention 296/334 and
  300/334 of 334 bibliomic active reactions.
- Full mode: testXomicsToModel_fastCore PASS 553s; testXomicsToModel_thermoKernel PASS 550s.
- Fast mode: both SKIP cleanly (full-mode-only guard).
- checkcode: only the by-design `global CBTDIR`/`global CBT_MISSING_REQUIREMENTS_ERROR_ID` warnings.
- Debug-pollution fix: the first full-mode run revealed XomicsToModel writes numbered
  `*.debug_prior_to_*.mat` checkpoints to the current directory (they were briefly committed and
  removed). Both tests now set `param.debug=false` AND run the extraction inside a `tempname`
  directory (error-safe cd-back + rmdir), so nothing lands in the repo. Re-verified: fastCore
  full-mode PASS 570s with debugInTestDir=0, debugInRoot=0; no debug .mat anywhere in the repo.

## Unresolved issues

- The tests are ~9–10 min each; quarantined to full mode so routine local runs are unaffected. In CI
  (full mode) they add ~19 min — acceptable for the coverage of a major untested function, but worth
  noting for CI budget.
- Assertions use tolerances (±5% size; ≥85% core retained) to absorb solver nondeterminism in the
  extraction/relaxation; exact reference sizes are recorded above for future tightening if the run
  proves deterministic.
- The iDopaNeuro paper drivers remain non-viable test sources (private hardcoded paths) — documented,
  not pursued. thermoKernel now has coverage here, so no separate thermoKernel follow-up is needed.
