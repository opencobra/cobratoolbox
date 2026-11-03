# Feature Specification: Plain-MATLAB replacements for paid-toolbox functions (first slice)

**Feature Branch**: `20261103-120403-toolbox-free-replacements` (from `upstream/develop`)

**Created**: 2026-11-03

**Status**: Draft

**Input**: User description: "One of the things that we want is to be independent from the MATLAB paid toolboxes ... I agree with your recommended plan. test the outputs and make sure the outputs are consistent with the toolboxes outputs, run the tests and make sure the tests pass ... look online ... ask codex installed on this machine to review your codes ... for some of the functions there is already existing MATLAB alternatives that we might use. do it on another branch using speckit."

## Why

The toolbox should run on base MATLAB. A scan of `src/` (2026-11-03) found paid-toolbox calls
in about 100 files; the largest groups are the Parallel Computing Toolbox (`gcp`/`parpool`, 41
files, which fail without the toolbox although `parfor` itself runs serially) and the
Statistics and Machine Learning Toolbox (45 files). During recent test work, missing toolboxes
blocked DEMETER (`tdfread`) and two rFASTCORMICS functions.

## Scope of this first slice

1. **Parallel pool helpers** (new): find the current pool, open a pool, close a pool. With the
   Parallel Computing Toolbox they behave exactly like `gcp('nocreate')`, `parpool(...)` and
   `delete(gcp('nocreate'))`; without it they return empty / do nothing, so `parfor` runs
   serially. All 41 call sites outside `old/` use them.
2. **Statistics replacements** (new, own names with the prefix `cobra`, never shadowing a
   MathWorks name): `cobraNormcdf`, `cobraNorminv`, `cobraTcdf`, `cobraTinv`, `cobraChi2cdf`,
   `cobraFcdf`, `cobraTabulate`, `cobraGrp2idx`, `cobraCrosstab`, `cobraPdist`, `cobraCorr`,
   `cobraSkewness`, `cobraKurtosis`, `cobraPca`, `cobraRegress`, `cobraTdfread`, `cobraSmooth`.
   Each supports at least every syntax and option used by a call site in `src/` (outside
   `old/`), reproduces the MathWorks result for those uses, and raises a clear error for an
   option it does not support.
3. **Existing base-MATLAB alternatives** used directly where they are exact: `nansum(x)` →
   `sum(x, 'omitnan')`.
4. **Call sites** in `src/` outside `old/` and `deprecated/` switch to the replacements
   (normcdf 8 files, norminv 1, tinv 1, chi2cdf 1, nansum 1, tabulate 5, grp2idx 2, crosstab 1,
   pdist 4, corr 7, skewness 1, kurtosis 1, pca 1, regress 1, tdfread 3, smooth 2).

Out of scope (left toolbox-gated, listed for a later slice): `fitglm`, `fitglme`, `fitlm`,
`fitcsvm`, `tsne`, `ksdensity`, `kruskalwallis`, `ranksum`, `ttest2`, `anova1`, `mafdr`,
`boxplot`, `gscatter`, `fit`/`fittype`/`prepareCurveData`, `ga`, `simplify`, `biograph`,
`graphconncomp` (only in `old/`), and the Optimization Toolbox calls (`linprog`, `fmincon`,
`fminunc`, `optimoptions`), which should go through the toolbox solver layer (Principle IV) in a
separate feature.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Code that only needed a pool runs on base MATLAB (Priority: P1)

**Independent Test**: on a MATLAB without the Parallel Computing Toolbox, call each helper; it
returns empty or does nothing, and a function that used `gcp`/`parpool` no longer errors for that
reason. With the toolbox, the helpers return the same objects as `gcp`/`parpool`.

**Acceptance Scenarios**:

1. **Given** no Parallel Computing Toolbox, **When** a call site asks for a pool, **Then** no error
   is raised and the work runs serially.
2. **Given** the toolbox, **When** a call site asks for a pool, **Then** the result equals the
   direct toolbox call (same pool, same worker count).

---

### User Story 2 - Statistics results without the Statistics Toolbox (Priority: P1)

**Independent Test**: each replacement's test compares it with (a) MathWorks documentation
values or examples where published, (b) an independent implementation (SciPy 1.16) computed for
the same inputs, and (c) the MathWorks function itself when its toolbox is installed (a parity
section that is skipped otherwise).

**Acceptance Scenarios**:

1. **Given** the syntaxes used by call sites, **When** the replacement runs, **Then** its outputs
   (values, sizes, types, orientation, ordering) match the reference within a justified
   tolerance (exact for counts, labels and orderings).
2. **Given** an option the replacement does not support, **When** it is passed, **Then** a clear
   error names the option.

---

### User Story 3 - Call sites use the replacements (Priority: P2)

**Independent Test**: no call site outside `old/`/`deprecated/` calls one of the replaced
toolbox functions; existing tests of the changed functions still pass.

### User Story 4 - Independent review (Priority: P2)

**Independent Test**: the Codex CLI reviews every new function against the MathWorks semantics
note; each finding is fixed or answered in `review.md`.

### Edge Cases

- NaN inputs (propagated or ignored exactly as the MathWorks function does).
- Scalar expansion and output orientation (row vs column).
- Ties in rank correlations; small samples where MathWorks uses exact p-values.
- `tabulate` of positive integers lists zero counts; cell/categorical input returns a cell array.
- `pca` sign convention; `regress` with rank-deficient X.
- Without the toolbox, a parity section skips cleanly (the test still runs its other sections).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: New functions live in a new folder `src/base/utilities/toolboxFree/` with
  openCOBRA help headers that state which MathWorks function they reproduce, which syntaxes are
  supported, and the source of the algorithm.
- **FR-002**: No new function shadows a MathWorks function name.
- **FR-003**: Each replacement supports every syntax its call sites use and reproduces the
  MathWorks outputs for them; unsupported options raise an error naming the option.
- **FR-004**: With the toolbox installed, a call site's results are unchanged by the switch
  (parity); without it, the call site no longer fails for lack of the toolbox.
- **FR-005**: One Tier-1 test per new function (III-Naming), declaring no requirement; values
  checked against MathWorks documentation examples where available and against SciPy-computed
  references (stated as such in the header, with the SciPy version); a parity section against
  the MathWorks function runs only when its toolbox is installed (otherwise it prints a skip
  message), so the test passes on base MATLAB.
- **FR-006**: Line coverage 100% or every uncovered line listed with its reason.
- **FR-007**: The Codex CLI reviews each new function (read-only) and the call-site changes;
  findings and their resolution are recorded in `review.md`. If Codex cannot run (2026-11-03:
  the ChatGPT account of this machine rejects every model, "model is not supported when using
  Codex with a ChatGPT account"), independent reviewer agents that receive only the code, the
  tests and the semantics note perform the same review, and `review.md` says so; the Codex
  review is repeated when the account works again.
- **FR-008**: Existing tests of the functions whose call sites change still pass on this machine
  (base MATLAB plus Gurobi), where they ran before.
- **FR-009**: No change to public interfaces of existing functions (Principle II).
- **FR-010**: Commits with the maintainer identity, no co-author line, only this feature's files;
  branch pushed to the maintainer's fork.

### Key Entities

- **Replacement function**: MathWorks name, new name, supported syntaxes, algorithm source.
- **Reference value**: source (MathWorks doc, SciPy version, MathWorks function), input, value,
  tolerance.
- **Review finding**: function, finding, resolution.

## Success Criteria *(mandatory)*

- **SC-001**: 0 calls to `gcp`, `parpool` or the 16 replaced statistics functions remain in
  `src/` outside `old/` and `deprecated/`.
- **SC-002**: Every new test passes on base MATLAB; parity sections pass wherever the toolbox is
  installed.
- **SC-003**: Every replacement matches its references within the tolerance stated in its test.
- **SC-004**: Every Codex finding is fixed or answered in `review.md`.
- **SC-005**: Existing tests of changed call-site files pass as before.

## Assumptions

- This machine has the Parallel Computing Toolbox but not the Statistics, Optimization or Curve
  Fitting toolboxes. SciPy 1.16 is the independent reference for the statistics functions, and
  the MathWorks documentation is the authority for semantics. Statistics parity sections
  therefore skip here and run on any installation that has the toolbox.
- The parallel helpers decide availability through one small function; the test of the
  "no toolbox" behaviour writes a stand-in for that function to a temporary folder at run time,
  puts it first on the path for that section only and removes it afterwards (a committed
  fixture would be on the path in every session, because `initCobraToolbox` adds `test/`
  recursively, and would silently disable parallel computing), so both branches are tested on
  this machine.
- `old/` folders are legacy and left unchanged.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-004 | test of each parallel helper (with and without pool) | `src/base/utilities/toolboxFree/` helpers |
| US2 / FR-003, FR-005 | `test<CobraName>.m` per replacement | `src/base/utilities/toolboxFree/cobra*.m` |
| US3 / SC-001 | scan of `src/` for remaining calls | changed call-site files |
| US4 / FR-007 | `review.md` | — (no source function) |
| FR-008 / SC-005 | existing tests of changed files | changed call-site files |
