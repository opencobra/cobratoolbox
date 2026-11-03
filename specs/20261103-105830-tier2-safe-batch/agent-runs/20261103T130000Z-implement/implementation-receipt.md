# Implementation receipt — 20261103-105830-tier2-safe-batch

## Prompt

"can you find all of the Tier 2 functions that do not get impact from defect functions and are
safe and write tests for all of them?" — extended during the run by: "Great, make as much tests as
possible as long as they are not dependent on defect functions".

Run by `/speckit-implement`; tasks T003-T032 and T038-T059 executed by seven parallel helper
agents (groups A-G), integration inline.

## Final response

36 new tests were written for functions that use no solver, file, toolbox or known silent
defect anywhere in their call chain: 20 Tier-2 tests on distributed models and 16 Tier-1 tests.
All 36 pass in one MATLAB session and again with solver spies first on the path. 16 probed
functions were dropped (whole-body or thermodynamic data not distributed, missing toolboxes,
functions that error on every call, one that waits for user input); 8 more were excluded before
probing. 59 defects were recorded in the new test headers and the registry now lists 110. No
source file changed. `summary.md` lists every test, every drop with its reason, and eight
decisions for the maintainer.

## Diff summary

- New: 36 test files under `test/verifiedTests/` (see `summary.md`).
- Edited by the integrator: `testAddReactionGEM.m` (removed an assertion that pinned possibly
  defective accumulation behaviour); `testConstrainEcosystemPoint.m` moved to `testEcosystem/`.
- Regenerated: `test/known-defects.md` (51 → 110).
- Spec Kit artifacts in `specs/20261103-105830-tier2-safe-batch/`; `.specify/feature.json`.
- `src/`: no change.

## Tests

- 36/36 passed through `runScriptFile` in one session; 36/36 passed with solver spies
  (`solveCobraLP/QP/MILP/MIQP/NLP/EP`, `optimizeCbModel`) first on the path.
- Line coverage per test measured by the helper agents (table in `summary.md`).
- `python3 .github/scripts/known_defects.py`: exit 0, 110 defects.

## Unresolved issues

- Eight decisions for the maintainer (`summary.md`), including the derived whole-body-style
  fixtures and `addReactionGEM` accumulation.
- Defects of the 16 dropped functions are documented in `summary.md` only (no test header).
