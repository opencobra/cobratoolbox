---
description: "Tasks for the plain-MATLAB toolbox replacements"
---

# Tasks: Plain-MATLAB replacements for paid-toolbox functions (first slice)

**Input**: `specs/20261103-120403-toolbox-free-replacements/` (spec, plan, research,
mathworks-semantics.md, quickstart)

## Procedure for every new function

1. Read its section of `mathworks-semantics.md` and every call site (spec scope list). Support
   every syntax/option the call sites use; reject other options with `error` naming the option.
2. Write it in `src/base/utilities/toolboxFree/<name>.m` from the documented formulas (never
   copy MathWorks code), with an openCOBRA help header (USAGE, INPUTS, OPTIONAL INPUTS,
   OUTPUTS, NOTE: "Plain-MATLAB replacement for <MathWorks function> (<toolbox>); supported
   syntaxes ...; semantics: mathworks-semantics.md §n"). Base MATLAB only.
3. Reference values: compute with SciPy 1.16 (or an exact enumeration in Python where SciPy has
   no equivalent) in `specs/20261103-120403-toolbox-free-replacements/references/<group>.py`,
   print them with full precision, and paste them into the test with a comment naming the
   script and SciPy version. Use MathWorks documentation numbers where published.
4. Test `test/verifiedTests/base/testToolboxFree/test<Name>.m` (Tier 1, `prepareTest()`): sections
   for each call-site syntax, edge cases from the semantics note, the error for an unsupported
   option, and a parity section that runs only if the MathWorks function exists
   (`exist('<name>','file')` and its toolbox licence), otherwise prints "skipped: <toolbox> not
   installed". Tolerances justified (e.g. 1e-12 relative for closed forms, looser where SciPy
   uses a different algorithm). 100% line coverage or exemptions listed.
5. Run the test (runScriptFile + coverage helper); it must pass.

## Phase 1: Setup

- [X] T001 Create src/base/utilities/toolboxFree/ and test/verifiedTests/base/testToolboxFree/
- [X] T002 Confirm SciPy 1.16 and the coverage helper are available

## Phase 2: User Story 1 — parallel helpers (P1)

- [X] T003 [P] [US1] Write isParallelToolboxAvailable.m, getParallelPool.m, openParallelPool.m, closeParallelPool.m in src/base/utilities/toolboxFree/ and their tests (with-toolbox branch on this machine; no-toolbox branch via a stand-in for isParallelToolboxAvailable written to a temporary folder at run time and removed afterwards)
- [X] T004 [US1] Switch the 41 call sites of gcp/parpool in src/ (outside old/, deprecated/) to the helpers, keeping each file's logic; where a pool object's properties are used, keep them guarded for the empty case; where code relied on parpool raising an error to fall back to serial computation (SteadyComPOAgr, SteadyComFVAgr), fall back when no pool is open

## Phase 3: User Story 2 — statistics replacements (P1)

- [X] T005 [P] [US2] Distributions: cobraNormcdf (x,mu,sigma[,pcov] one output; 'upper'), cobraNorminv, cobraTcdf (incl. 'upper'), cobraTinv, cobraChi2cdf, cobraFcdf in src/base/utilities/toolboxFree/ with tests; references in references/distributions.py
- [X] T006 [P] [US2] Tables and moments: cobraTabulate, cobraGrp2idx, cobraCrosstab (uses cobraChi2cdf: coordinate with T005 or use 1-gammainc directly), cobraSkewness, cobraKurtosis, cobraSmooth with tests; references in references/tables.py
- [X] T007 [US2] (after T005) cobraPdist ('euclidean' default, 'jaccard'), cobraCorr (Pearson/Spearman/Kendall, [rho,pval], 'type'/'Type'), cobraPca ('Centered', 'Algorithm' 'als' for complete data; outputs coeff, score, latent, tsquared, explained), cobraRegress (5 outputs), cobraTdfread with tests; references in references/multivariate.py

## Phase 4: User Story 3 — call sites (P2)

- [X] T008 [US3] Switch call sites: normcdf (8 files), norminv (1), tinv (1), chi2cdf (1), nansum→sum(...,'omitnan') (1)
- [X] T009 [US3] Switch call sites: tabulate (5), grp2idx (2), crosstab (1), skewness (1), kurtosis (1), smooth (2)
- [X] T010 [US3] Switch call sites: pdist (4), corr (7), pca (1), regress (1), tdfread (3)
- [X] T011 [US3] Scan src/ (outside old/, deprecated/) for remaining calls to gcp, parpool and the 16 replaced functions: none

## Phase 5: User Story 4 — independent review (P2)

- [X] T012 [US4] Codex review (read-only) of each group against mathworks-semantics.md; record findings in specs/20261103-120403-toolbox-free-replacements/review.md
- [X] T013 [US4] Fix or answer every finding; re-run the affected tests

## Phase 6: Polish

- [X] T014 Re-run the existing tests of every changed call-site file that ran before on this machine; record results (7 ran and passed; 9 skipped for CPLEX or the Statistics Toolbox)
- [X] T014b Remove the Statistics Toolbox requirement from existing tests that no longer need it, verified by running them on base MATLAB: testMTA, testMoieties, testEfmBackboneExtraction now run and pass; testCreatePanModels (ksdensity via violinplot), testSammi (randsample) and testSteadyCom (cleanup fails when no LP branch runs; follow-up) keep it
- [X] T015 Run all new tests in one MATLAB session
- [X] T016 Write agent-runs/<UTC>-implement/implementation-receipt.md
- [X] T017 Commit (maintainer identity, no co-author line, only this feature's files) and push the branch with upstream tracking

## Phase 7: Test requirements (maintainer request, 2026-11-03)

"For the functions that you've updated you should modify the tests because the tests mention paid
toolboxes and dependencies and that is what makes the CI skip them."

- [X] T018 Scan every test for declared Statistics / Curve Fitting / Parallel Computing requirements (13 tests) and for direct calls to replaced functions in test code (16 test files, 2 test-suite runners)
- [X] T019 Switch direct calls in tests to the helpers / cobra* functions (gcp, parpool, tinv, regress) in testFVA, testpFBA, testMinSpan, testFindBlockedReaction, testCycleFreeFlux, testOptForce, testExtractConditionSpecificModel, testFitC13Data, testWriteSBML, testSampleCbModel, testSteadyCom, testuFBA, tutorialDerived steadyCom and uFBA, runTestSuite, runTestSuite_Actions
- [X] T020 Remove requirements no longer needed, verified by running the test on base MATLAB where possible: testuFBA (Statistics); testFastFVA, testCreatePanModels (Parallel Computing); testFastGapFill (Statistics; needs CPLEX, verified statically); testMgPipe declares Statistics instead of Parallel Computing (it reaches ksdensity, kruskalwallis). Kept, with reason: testRFASTCORMICS (Curve Fitting), testSampleCbModel (exprnd), testSampleCbModelRHMC (distribution_test), testFEA (mafdr), testSWIFTCORE and testSammi (randsample), testBiomassPrecursorCheck (pre-existing assertion failure at line 91, hidden by the skip; follow-up), testSteadyCom (save folder lost under parallel workers at cleanup; follow-up)

## Dependencies & parallelism

T003, T005, T006 in parallel; T007 after T005; call-site tasks after their functions; review
after all functions; polish last.
