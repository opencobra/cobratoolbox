# Feature Specification: Fix the code defects of the core blocking functions

**Feature Branch**: `20261120-161825-core-blocker-fixes`. It starts from
`20261120-151023-doc-matches-code`, which starts from the open pull request's branch.

**Created**: 2026-11-20

**Status**: In progress. Fixes are added one function at a time, after the maintainer's review.

**Input**: Maintainer, 2026-11-20: "ok now lets go through the 8 problematic functions one by one",
then for #1: "ok lets fix it with respect to your suggestion. we need to push these 7 function fixes
to a new branch. Yes use speckit to fix it. report to me if any output would be affected."

## Context

Seven quarantined functions block most of the 429 BLOCKED functions of the back-fill ledger. In the
ledger's own words (the blocked reasons), and in order of reach:

| # | Function | Blocks |
|---|---|---|
| 1 | getCobraSolverParams | 308 |
| 2 | getModelFieldsForType | 306 |
| 3 | setGurobiParam | 294 |
| 4 | findSExRxnInd | 248 |
| 5 | getFilesInDir | 245 |
| 6 | checkBalance | 240 |
| 7 | setCplexParametersForProblem | 239 |

parseSolverParameters, the eighth, was cleared by a help-text fix in feature
20261120-151023-doc-matches-code. The maintainer reviews each function with the lead (the defects,
the code, the proposed fix). Only an approved fix is implemented, and every fix reports which outputs
can change.

## Decisions

### 1. getCobraSolverParams: approved 2026-11-20

- **Defect "the global solver parameters are ignored when no paramStructure is given":** fix the
  code. One flag (`overRideDefaults`) decided both whether the global settings are read and whether
  a structure is returned. Split it into `useGlobals` and `returnStructure`. The two-input form then
  reads the global settings; the number of outputs of every calling form is unchanged.
- **Defect "paramStructure 'default' returns the global values":** fix the code. With 'default',
  `useGlobals = 0`.
- **Defect "the structure output keeps the fields named in paramNames":** fix the help text, which
  becomes "the fields named in paramNames are set to the returned values". No caller uses this
  output.

### 2. getModelFieldsForType: approved 2026-11-23

- **Defect "custom fields named after the type are missed for a model with one or no element of
  that type":** fix the code. Line 104 reads `length(type-1)`, which is the length of the whole type
  name; it becomes `length(type)-1`, as the comment and line 184 intend. Checked with the maintainer
  against the 80 standard COBRA fields: all of them are in the field definitions, and every one that
  starts with a type's prefix belongs to that type. The fix therefore changes the result only for
  non-standard fields named after a type (`rxnCustom`, ...), in models with 0 or 1 elements of the
  type.
- **Found while writing the test:** an undefined field named after the type, square in the type's
  size, in a model where another type has the same size, got the placeholder dimension -1, so
  removeRxns and the other callers failed with an indexing error. Guessing "both dimensions" would
  silently mistreat a reactions x metabolites field such as rxnMetMat. The maintainer chose (2026-11-23)
  a guiding error, `getModelFieldsForType:ambiguousField`, documented in the help. It names the
  field and points to the standard COBRA field names (getDefinedFieldProperties, and
  documentation/source/guides/COBRAModelFields.rst).

### 3. setGurobiParam: approved 2026-11-23 (fixes 1-3)

- **Defect "printLevel, feasTol and optTol are required although the fields are documented as
  optional":** fix the code. OutputFlag = 0 and DisplayInterval = 1 are set directly when absent:
  every printLevel case set these same values, so the output is unchanged. FeasibilityTol and
  OptimalityTol are copied from feasTol and optTol only if those are given; otherwise Gurobi's
  defaults apply.
- **Defect "timelimit overrides TimeLimit":** fix the code. timelimit is copied only when
  TimeLimit is absent, as the help says.
- **Defect "the warning for an unknown lpmethod names param.qpmethod":** fix the message.
- **Not included (maintainer, 2026-11-23):** translating COBRA's camel-case `timeLimit`, which
  setGurobiParam drops, so a COBRA time limit has no effect with Gurobi. It stays an open item in
  review.md.

### 4. findSExRxnInd: approved 2026-11-23 (fixes 1-4)

- **Defect "a mass-balanced reaction named DM_atp(c) is classified as an exchange":** fix the
  code. The three ATP names (ATPM, DM_atp(c), DM_atp_c_) are collected in one boolean, which is
  removed from both DMRxnBool and the heuristic exchange set, as the printed message says. Output
  change: SIntRxnBool (and the metabolite booleans) of a model with a multi-coefficient DM_atp(c);
  of the shipped test models only cardiac_mit_glcuptake_atpmax.
- **Defect "a model without c gets a c with one entry per metabolite":** fix the code, zeros(n, 1).
  No classification changes; the returned c has the documented size.
- **Defect "the exchange prefix Ex_ is never recognised":** fix the code, compare three
  characters. Reactions named Ex_... become exchanges; none in the shipped test models.
- **Defect "the biomass reaction found from biomassRxnAbbr is printed at every printLevel":** gate
  the message with printLevel > 0, as every other message. Screen output only.

### 5. getFilesInDir: approved 2026-11-23 (fixes 1-3)

- **Defect "an empty git listing returns the folder itself as a file":** fix the code. Empty names
  are dropped after the listing, so an empty listing gives an empty cell array and a clean
  repository lists no folder entry for 'all'. removeTempFiles could only try to delete the folder
  path (a warning and status false); it no longer tries.
- **Defect "the default checkSubFolders omits subfolders in folders not under git":** fix the
  code, default true as documented. Inside git the old default '' already behaved as true, so only
  folders outside git change. In a COBRA copy not under git, initCobraToolbox's snapshot now
  includes subfolders, so the final removeTempFiles(CBTDIR, ...) deletes only files that are new,
  not every subfolder file matching COBRA's .gitignore.
- **Defect "folders are listed as files in folders not under git":** fix the code, keep only the
  entries of rdir that are not folders. removeTempFiles no longer tries to delete folders.

### 6. checkBalance: approved 2026-11-23 (fix and help correction)

- **Defect "with exactly one metabolite without a formula, the wrong reactions are set to NaN":**
  fix the code, any(..., 1), so the reactions that use a metabolite without a formula are found
  column by column whatever the number of such metabolites. Output change: dE of a model with
  exactly one metabolite without a usable formula. Of the shipped test models, Recon3D_301 and
  Recon3DModel_301 (protein[c]): 10FTHF5GLUtl (reaction 1) goes from NaN to its balance,
  PROTEIN_BS from -32.5694 (carbon) and DM_PROTEIN from 0 to NaN; checkMassChargeBalance's
  results follow.
- **Help text (found in the review, cosmetic):** the help gives printLevel default 0 ({-1, (0),
  1}), the code uses 1. The help is corrected to the code's default; no output change.

### 7. setCplexParametersForProblem: approved 2026-11-23 (option A)

- **Defect "text values of problemTypeParams.method have no effect for MIQP":** fix the code
  with the smallest change: the barrier default for lpmethod (lpmethod = 4 for every problem type
  other than LP) is not applied when lpmethod was just set from a text value of
  problemTypeParams.method for MIQP, so the named algorithm is kept, as the code and help
  describe. Not changed (maintainer chose option A over B): names set lpmethod while the numeric
  legacy codes set qpmethod, and the warning "check the problemTypeParams.method mapping ..." on
  every MIQP call. Output change: solveCobraMIQP with ibm_cplex and a text method gets the named
  lpmethod instead of 4; LP, QP, MILP and MIQP with a numeric or no method are unchanged.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Settings and helpers that do what they document (Priority: P1)

A user who sets a solver parameter with changeCobraSolverParams, or who calls one of the seven
functions as documented, gets the documented result.

**Independent Test**: each fixed function has a full test of its documented behaviour, including the
inputs that showed the defect, and passes with coverage.

**Acceptance Scenarios (getCobraSolverParams)**:

1. **Given** `changeCobraSolverParams('LP', 'feasTol', 1e-9)`, **When**
   `getCobraSolverParams('LP', 'feasTol')` runs, **Then** it returns 1e-9. Without a global
   setting, it returns the built-in 1e-6.
2. **Given** the same global setting, **When** `getCobraSolverParams('LP', 'feasTol', 'default')`
   runs, **Then** it returns 1e-6 and, as before, a structure as the last output.
3. **Given** a parameter structure, **When** the three-input form runs, **Then** the structure wins
   over the global setting, which wins over the built-in default, as before.
4. **Given** any calling form, **When** it runs, **Then** the number of outputs is as before.

### User Story 2 - Impact report (Priority: P1)

For every fix, the maintainer gets a report of which outputs of the toolbox can change, under which
conditions, and the evidence that nothing else changed (the tests of the callers).

### User Story 3 - More tested functions (Priority: P2)

When a fix clears a quarantine, the blocked functions whose blockers are all cleared get tests,
written after all approved fixes are in.

### Edge Cases

- A user who changed a global setting gets that setting where it was ignored before. This is the
  documented behaviour, and the impact report names the affected callers.
- A paramStructure that is neither a structure nor 'default' (for example another text): it reads
  the global settings, as before.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Each fix implements exactly the decision recorded above. Interfaces (inputs, number
  of outputs, error identifiers) are unchanged unless the decision says otherwise (Principle II).
- **FR-002**: Each fixed function's test becomes a full test. It checks the formerly defective
  inputs, has its defect entries removed, and passes with coverage of every line not exempted.
- **FR-003**: Each fix reports the outputs that can change (callers, conditions) and runs the tests
  of the callers that have tests. A test that changes result is reported, not adjusted silently.
- **FR-004**: Ledger rows move to TESTED, blocked reasons drop the cleared functions, and the
  registry is regenerated. `--check` and `--verify-coverage` report 0 problems.
- **FR-005**: The functions unblocked by the approved fixes get tests (US3), or quarantine tests
  with confirmed defects.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Every approved function is TESTED with full coverage. Its formerly defective inputs
  give the documented result.
- **SC-002**: The impact report lists, for each fix, every caller whose output can change, and the
  caller tests pass.
- **SC-003**: The number of BLOCKED functions falls by the number unblocked, each with a test.

## Assumptions

- The global solver settings are empty after initCobraToolbox (checked 2026-11-20 for LP, MILP and
  QP). The getCobraSolverParams fix therefore changes nothing unless a user changes a setting.
- The branch is stacked on the documentation branch and the pull request's branch.

## Traceability

| Acceptance criterion | Test | Source function |
|---|---|---|
| US1 getCobraSolverParams 1-4 | testGetCobraSolverParams | src/base/solvers/param/getCobraSolverParams.m |
| US2 impact | tests of the callers (impact report in review.md) | callers of each fixed function |
| US3 unblocked | the new tests | the unblocked functions |
