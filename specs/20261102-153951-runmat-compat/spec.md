# Feature Specification: RunMat compatibility of COBRA Toolbox source

**Feature Branch**: `20261102-153951-runmat-compat`

**Created**: 2026-11-02

**Status**: Draft

**Input**: User description: "Make the necessary fixes to the cobra toolbox code" — so that the COBRA Toolbox
test suite (`test/testAll.m`) can be run under RunMat, an independent MATLAB-compatible runtime, and the
number of passing tests measured. Requested after an attempted run of `testAll` under RunMat
(branch `feature/clean-room-matlab-builtins` @ `ebc6509f3`, version 0.6.2) on 2026-11-02 executed no test.

## Clarifications

### Session 2026-11-02

- Q: Are the 289 vendored, non-submodule files under `external/` in scope? → A: No. Exclude `external/`
  (FR-007); leave those folders off RunMat's path for the measurement (FR-014).
- Q: For functions RunMat lacks, add workarounds? → A: Explicit calls only, no RunMat-specific fallbacks (FR-008).
- Q: What counts as the measurement run? → A: `testAll` under RunMat with failing submodule (and, per Q1,
  `external/`) folders off the path; dependent tests reported as not runnable (FR-014).
- Q (after research, see research.md R3): How should the work be bounded, given that each layer of fixes exposes
  the next and about 110 remaining failures are RunMat parser gaps? → A: Bounded mechanical slice. Only
  machine-verifiable rewrites (FR-001 to FR-005, FR-009); everything else is reported as a RunMat defect. The
  feature does not promise that `testAll` runs under RunMat; it measures how far it gets (US2, SC-004).

## Background (observed on 2026-11-02, fork @ `467094a5d`)

The attempted run is the evidence for this feature. RunMat compiles each file before running it and
rejects the whole run if any source file on its search path fails to compile.

- `testAll.m` stopped before any test at three constructs that MATLAB accepts:
  - a call to a function with no arguments written without parentheses (`initCobraToolbox;`, `exit`) — RunMat
    resolves such a bare name when compiling, against the script's own folder only;
  - a variable named after a short-circuited `exist(..., 'var') &&` test (`PERFORMANCE_REPORT`) that MATLAB
    never evaluates;
  - `initCobraToolbox.m` refers to `prefdir`, which RunMat does not provide.
- RunMat's test runner, given the toolbox folders as its search path, reported 1,711 files it could not compile.
  Of those, **1,474 are files this repository owns**: 1,059 in `src/`, 289 in vendored `external/` folders that are
  not git submodules, and 126 in `test/`. The other 237 are inside git submodules (separate repositories).
- The owned-file failures are dominated by valid MATLAB that RunMat does not parse:
  - 970 function files whose functions have no closing `end`;
  - 138 cell literals and 37 matrix literals continued across lines without `...`;
  - 25 `try` blocks with no `catch`;
  - about 207 names RunMat cannot resolve when compiling: bare-name calls, variables created by `load`
    without an output, and functions RunMat lacks such as `ispc`.
- RunMat's compiler crashed (an internal panic) on 8 files: 2 owned files in
  `src/analysis/sampling/BarrierRound/` and 6 in the `external/analysis/PolytopeSamplerMatlab` submodule.

Most of these are RunMat defects, not COBRA defects. This feature changes COBRA only by rewriting such
constructs into equivalent, equally valid MATLAB that RunMat also accepts; it does not change MATLAB behaviour.
The RunMat defects themselves are reported to the RunMat maintainers separately and are out of scope here.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Owned source compiles under RunMat (Priority: P1)

A developer evaluating RunMat as a runtime for the COBRA Toolbox points RunMat's checker at the toolbox and
gets no compile errors from files this repository owns, so the remaining failures are RunMat's (or a
submodule's) and can be reported precisely.

**Why this priority**: RunMat refuses to run any test while any file on its path fails to compile, so this is
the prerequisite for every other measurement. It is also the bulk of the change.

**Independent Test**: Run RunMat's test-runner discovery over `src/` and `test/` and count failures by
category; run MATLAB's code analyzer and the MATLAB test suite before and after and compare.

**Acceptance Scenarios**:

1. **Given** the fork at this feature's branch, **When** RunMat's test-runner discovery is run over `src/` and
   `test/`, **Then** no in-scope file reports an error of a rewritten category (SC-001).
2. **Given** the same files, **When** MATLAB's code analyzer is run on each changed file, **Then** it reports no
   syntax error and no message that was not reported before the change.
3. **Given** MATLAB R2024b or newer, **When** `test/testAll.m` is run before and after the change in the same
   environment, **Then** the set of passing, failing and skipped tests is identical.

---

### User Story 2 - The test-suite entry point runs under RunMat (Priority: P2)

A developer runs `test/testAll.m` (with `COBRA_CI=1`) under RunMat and it reaches the loop over test files and
reports a result per test, instead of stopping during start-up.

**Why this priority**: it turns "how many COBRA tests pass under RunMat" into a number.

**Independent Test**: Run `testAll` under RunMat and confirm it prints a per-test result and a summary line.

**Acceptance Scenarios**:

1. **Given** RunMat and this branch, **When** `testAll.m` is run with `COBRA_CI=1`, **Then** it gets past start-up
   (`initCobraToolbox`) and runs each verified test, reporting passed/failed/skipped counts, or stops only at a
   RunMat defect that is recorded in this feature's report with a reproducer.
2. **Given** MATLAB, **When** `testAll.m` and `initCobraToolbox` are run, **Then** their behaviour and output are
   unchanged (User Story 1, scenario 3).

---

### User Story 3 - A reproducible measurement and report (Priority: P3)

The maintainer gets a short report: the number of COBRA tests passing under RunMat, the number failing grouped
by cause, and the list of RunMat defects found with one minimal reproducer each, ready to send to the RunMat
maintainers.

**Why this priority**: it is the deliverable the user asked for, but it depends on stories 1 and 2.

**Independent Test**: The report's counts can be regenerated by re-running the documented command.

**Acceptance Scenarios**:

1. **Given** stories 1 and 2 are complete, **When** the documented command is run, **Then** it reproduces the
   reported pass/fail/skip counts.

---

### Edge Cases

- A function file that mixes `end`-terminated and unterminated functions, or contains nested functions: only
  files whose functions are all unterminated are rewritten; any other file is listed for manual review.
- A newline inside a cell or matrix literal that is preceded by `;`, `,` or a comment: the rewrite must keep the
  same rows and columns.
- `function` or `end` text inside comments, strings or block comments must not be treated as code.
- A bare name that is a variable created by `load`, `eval` or `assignin` rather than a function call: rewritten
  only if the rewrite is behaviour-preserving (for example capturing `load` output explicitly); otherwise listed.
- Files that are generated, binary-adjacent (MEX wrappers) or in `deprecated/`: excluded unless they block the
  test-suite run.
- Non-UTF-8 source files (8 files are Latin-1): see FR-009.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Every owned `.m` file in scope whose functions lack a closing `end` MUST have one added to each
  function, and only when every function in the file lacks one.
- **FR-002**: In every in-scope file, whitespace that MATLAB reads as an element separator inside a cell literal
  MUST become an explicit comma, and a newline that MATLAB reads as a row break inside a cell or matrix literal
  MUST be preceded by an explicit `;`. MATLAB's parse tree of each rewritten file MUST be unchanged; a file whose
  tree changes is reverted and listed. This also covers files RunMat accepts but reads differently (research.md
  R2, defect D1).
- **FR-003**: Every `try` block in scope with no `catch` MUST gain an empty `catch`, which MATLAB treats the same.
- **FR-004**: Every no-argument call written as a bare name, in a file in scope, that RunMat reports as an
  undefined name MUST be written with explicit parentheses (`name()`), but only where the name is a function in
  MATLAB and is never assigned, loaded or created by `eval` in that file. Undefined names that are variables
  created by `load` without an output, or `java.*`/`py.*`/`parallel.*` references, are not rewritten; they are
  reported.
- **FR-005**: `test/testAll.m` MUST NOT refer, outside a guard that MATLAB evaluates, to a variable that may not
  exist; the never-evaluated `PERFORMANCE_REPORT` reference MUST be rewritten so the expression's value in MATLAB
  is unchanged.
- **FR-006**: The 2 owned files that crash RunMat's compiler MUST be examined. Each MUST either be rewritten to an
  equivalent form that does not trigger the crash, or be listed in the report with a reproducer if no small
  equivalent rewrite exists.
- **FR-007**: The 289 vendored files under `external/` that fail to compile under RunMat are out of scope and
  MUST NOT be changed (Principle V: `external/` is read-only). They are reported, and the measurement run handles
  them as in FR-014.
- **FR-008**: For functions RunMat lacks entirely (for example `prefdir`, `ispc`, `exit`) or implements differently
  (`which` returning text instead of empty), COBRA MUST only make the call explicit (`name()`, FR-004). No
  RunMat-specific fallback or runtime detection MAY be added; the resulting run-time failures are RunMat defects
  for the report.
- **FR-009**: Of the 8 Latin-1 source files, the one in scope
  (`test/tutorialDerived/analysis/rMTA/tutorial_rMTA.m`) MUST be re-encoded as UTF-8 with identical characters;
  the other 7 are in `external/` or a submodule and are out of scope (FR-007, FR-013).
- **FR-010**: No change MAY alter a public interface, a model field, solver behaviour, warning or error text, or
  numerical output (Principle II).
- **FR-011**: Every changed file MUST pass MATLAB's code analyzer with no new message, and the MATLAB test suite
  result MUST be unchanged (FR-010 evidence).
- **FR-012**: The rewrite MUST be done by a reviewable, re-runnable script kept with this feature's artefacts, so
  the same mechanical change can be reviewed category by category and reapplied after merging `develop`.
- **FR-013**: Files inside git submodules (`.gitmodules`) MUST NOT be changed; their failures are reported only.
- **FR-014**: The measurement run MUST execute `testAll` under RunMat with every folder that holds an out-of-scope
  file failing RunMat compilation (submodules and `external/`) left off the search path, and with in-scope files
  that still fail after this feature's rewrites set aside in a scratch copy (never in the repository). Tests that then fail
  because they need those folders MUST be reported as not runnable for that reason, separately from other
  failures.

### Key Entities

- **Owned file in scope**: a `.m` file tracked by this repository (not in a submodule) under `src/`, `test/` or
  the repository root. `external/`, `deprecated/` and submodules are out of scope.
- **Rewrite category**: one of the mechanical, MATLAB-equivalent transformations in FR-001 to FR-005 and FR-009.
- **RunMat defect record**: a RunMat behaviour that differs from MATLAB, with a minimal reproducer and the count
  of COBRA files affected.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 0 in-scope files report a RunMat compile error of the rewritten categories (unterminated function,
  literal separator, `try` without `catch`, rewritable bare call). The total RunMat runner discovery error count
  for `src/` and `test/` falls from the 1,186 baseline, and the residue is classified in the report.
- **SC-002**: MATLAB's code analyzer reports 0 new messages and 0 syntax errors on the changed files.
- **SC-003**: The MATLAB `testAll` pass/fail/skip sets before and after the change are identical.
- **SC-004**: Under RunMat, `testAll` reaches the per-test loop and reports a pass/fail/skip count for the
  verified tests, or every remaining start-up blocker is a RunMat defect with a reproducer in the report.
- **SC-005**: The report lists every RunMat defect found, with the number of COBRA files affected and a
  reproducer of at most 10 lines each.

## Assumptions

- RunMat's behaviour is taken from the build of `feature/clean-room-matlab-builtins` @ `ebc6509f3` (0.6.2, built
  without the OCCT and CUDA features); later RunMat builds may need fewer rewrites.
- `deprecated/`, `tutorials/` and `papers/` (the last two are submodules) are out of scope.
- Fixing RunMat is out of scope; RunMat defects are reported to its maintainers.
- The MATLAB baseline is the existing CI environment (R2024b or newer, headless Linux). The local reference run
  uses MATLAB R2026a.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1-1 / FR-001–004, FR-009, SC-001 | RunMat runner discovery over `src/` and `test/` (`tools/runmat_discovery.sh`) | — (no source function; all in-scope files) |
| US1-2 / FR-011, SC-002 | MATLAB code analyzer before/after comparison (script in this feature) | — (no source function) |
| US1-3 / FR-010, SC-003 | `test/testAll.m` under MATLAB, before and after | — (whole verified test suite) |
| US2-1 / FR-005, FR-008, SC-004 | `test/testAll.m` under RunMat with `COBRA_CI=1` | `test/testAll.m`, `initCobraToolbox.m` |
| US2-2 / FR-010 | `test/testAll.m` under MATLAB | `test/testAll.m`, `initCobraToolbox.m` |
| US3-1 / FR-006, FR-013, SC-005 | Report regenerated by the documented command | — (no source function) |
