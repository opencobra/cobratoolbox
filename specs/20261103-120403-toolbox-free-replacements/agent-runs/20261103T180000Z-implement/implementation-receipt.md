# Implementation receipt — 20261103-120403-toolbox-free-replacements

## Prompt

"One of the things that we want is to be independent from the MATLAB paid toolboxes. can we write
our own adjacent functions for those toolboxes in plain MATLAB functions? ..." — "Great I agree
with your recomended plan. test the outputs and make sure the outputs are consistent with the
toolboxes outputs, run the tests and make sure the tests pass. ... look online see if you find any
reference if now rely on your judgement and you can also ask codex installed on this machine to
review your codes ... for some of the functions there is already existing MALTAB alternatives that
we might use" — "do it on another branch using speckit".

Run by `/speckit-implement`; the new functions were written by four helper agents (parallel
helpers; distributions; tables and moments; multivariate), reviewed by four independent reviewer
agents, and integrated inline.

## Final response

The toolbox now runs without the Parallel Computing Toolbox and, for the functions in this slice,
without the Statistics and Curve Fitting toolboxes. Four parallel-pool helpers replace direct
`gcp`/`parpool` calls in 41 files; 17 `cobra*` functions replace `normcdf`, `norminv`, `tcdf`,
`tinv`, `chi2cdf`, `fcdf`, `tabulate`, `grp2idx`, `crosstab`, `skewness`, `kurtosis`, `smooth`,
`pdist`, `corr`, `pca`, `regress` and `tdfread`; `nansum` became `sum(...,'omitnan')`. Each
replacement reproduces the MathWorks semantics documented in `mathworks-semantics.md` (MathWorks
documentation plus MathWorks source versions from 2005 to 2014 where the documentation is silent)
and is tested against MathWorks documentation examples, SciPy 1.16 / mpmath references and, where
the toolbox is installed, the MathWorks function itself. All 21 new tests and the 10 existing tests
of changed files that run on this machine pass; three existing tests (testMTA, testMoieties,
testEfmBackboneExtraction) no longer need the Statistics Toolbox. Codex could not run (the ChatGPT
account rejects every model), so four independent reviewer agents reviewed the code; 63 findings
were fixed or answered (`review.md`).

## Diff summary

- New: `src/base/utilities/toolboxFree/` (4 parallel helpers, 17 `cobra*` functions);
  `test/verifiedTests/base/testToolboxFree/` (21 tests); feature folder with spec, plan, research,
  `mathworks-semantics.md`, `references/*.py`, `review.md`, this receipt.
- Changed call sites (74 files in `src/`): parallel helpers (41), statistics replacements (about 35),
  plus follow-on fixes in `cycleFreeFlux`, `GPR2models`, `setWorkerCount`, `SteadyComPOAgr`,
  `SteadyComFVAgr`, `sampleScatterMatrix`, `identifyConservedMoieties`,
  `identifyConservedReactingMoieties`.
- Existing tests: Statistics Toolbox requirement removed from `testMTA`, `testMoieties`,
  `testEfmBackboneExtraction` (verified to run and pass on base MATLAB).
- `old/` and `deprecated/` untouched.

## Tests

- 31/31 passed in one MATLAB R2025a session (21 new, 10 existing incl. the 3 newly runnable);
  100% line coverage of every new function; parity sections skip on this machine (no Statistics /
  Curve Fitting Toolbox) and run where installed.
- 9 existing tests of changed files are skipped here for CPLEX or for toolbox functions outside
  this slice (ksdensity, randsample) or a test-harness issue (testSteadyCom, follow-up).

## Unresolved issues

- Codex review to be repeated when the Codex account works.
- Parity with the MathWorks functions not run on this machine; parity sections will settle the
  items marked UNCONFIRMED (e.g. smooth's uniformity tolerance, tdfread field-name rule in current
  releases, chi2cdf with v = 0).
- Follow-ups found during review, not changed here: DEMETER `.tsv` headers mangled by tdfread field
  names (pre-existing); `quanQualAcc` filters its two vectors with different masks; `testSteadyCom`
  cleanup fails when no LP branch runs; out-of-scope toolbox functions remain (fitglm, fitglme,
  fitlm, ksdensity, ranksum, ttest2, kruskalwallis, anova1, mafdr, randsample, boxplot, Optimization
  Toolbox calls).

## Addendum (2026-11-03): test requirements

Prompt: "For the functions that you've updated you should modify the tests because the tests mention
paid toolboxes and dependencies and that is what makes the CI skip them. so if we replaced the paid
functions we have to remove the mentioned dependency that we give as input to the prepareTest
function".

Done (tasks T018-T020): direct calls to gcp/parpool/tinv/regress in 16 test files and the two
test-suite runners now use the helpers and cobra* functions; requirements removed from testuFBA,
testFastFVA, testCreatePanModels (Parallel only) and testFastGapFill, and testMgPipe now declares
Statistics instead of Parallel Computing. Run on this machine: testuFBA, testFVA, testpFBA,
testMinSpan, testFindBlockedReaction, testCycleFreeFlux, testOptForce,
testExtractConditionSpecificModel, testWriteSBML pass; testFitC13Data skipped for its other
requirements. Requirements kept where the test still needs the toolbox (see tasks.md T020), with
two follow-ups: testBiomassPrecursorCheck fails at line 91 when run without the requirement
(pre-existing; no changed code reaches that call), and testSteadyCom loses its save folder at
cleanup under parallel workers.
