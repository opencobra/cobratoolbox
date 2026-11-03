# Implementation Plan: RunMat compatibility of COBRA Toolbox source

**Branch**: `20261102-153951-runmat-compat` | **Date**: 2026-11-02 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/20261102-153951-runmat-compat/spec.md`

## Summary

Rewrite MATLAB constructs that RunMat rejects or misreads into equivalent forms that both runtimes accept, in
`src/`, `test/` and `initCobraToolbox.m` only. The scope is a bounded mechanical slice (spec Clarifications):
- function terminators (FR-001);
- explicit literal separators (FR-002);
- empty `catch` (FR-003);
- explicit `name()` calls (FR-004);
- the `testAll` guard (FR-005);
- one UTF-8 re-encoding (FR-009).

Each category is applied by a re-runnable script kept in this feature. Each rewritten file is accepted only if
MATLAB reads it identically: an unchanged parse tree for FR-001/FR-002, a category argument for the rest, and a
code analyzer that gains no message. RunMat runner discovery is then re-measured, `testAll` is run under RunMat
as far as it goes, and a defect report for the RunMat maintainers is written. MATLAB `testAll` before and after
is the end-to-end check that nothing changed.

## Technical Context

**Language/Version**: MATLAB (baseline R2024b+, local reference R2026a). Rewrite tools in Python 3 (standard
library only), kept under `specs/<feature>/tools/` and never shipped in `src/`.

**Primary Dependencies**: MATLAB `mtree` and `checkcode`, for verification only. RunMat 0.6.2
(`feature/clean-room-matlab-builtins` @ `ebc6509f3`, built without OCCT/CUDA), for measurement only.

**Storage**: N/A.

**Testing**: the existing harness `test/testAll.m` under MATLAB, before and after, compared by test name and
status. The tools' own checks are `parseTreeEquivalence.m` and `analyzerSnapshot.m`. RunMat runner discovery
uses `runmat test --list`.

**Target Platform**: headless Linux (as CI).

**Project Type**: library source maintenance (mechanical refactor with no behaviour change).

**Performance Goals**: none; no runtime behaviour changes.

**Constraints**:
- MATLAB behaviour unchanged (FR-010);
- `external/`, `deprecated/` and submodules untouched (FR-007, FR-013);
- no RunMat-specific code (FR-008).

**Scale/Scope** (from research.md):
- about 765 files gain function terminators;
- 141 files gain explicit separators (3,406 commas and 6,200 semicolons before the 6 rejected files are removed);
- 44 files gain an empty `catch`;
- an estimated 100 to 150 files gain `name()`;
- `testAll.m` and 1 re-encoded file.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: No model, solver or numerical code changes meaning. Every rewrite is syntax-only.
  The parse-tree identity check (FR-001/FR-002) proves MATLAB reads those files identically. The category
  arguments in research.md R5 cover FR-003/FR-004. Principle I is satisfied, provided no file is accepted
  without passing its check.
- **Testing and reproducibility**:
  - MATLAB `testAll` with `COBRA_CI=1` runs before (baseline, recorded under `baseline/`) and after; the
    pass/fail/skip sets must be identical (SC-003).
  - Per file: parse-tree equivalence and the analyzer comparison.
  - No new test file is needed, because no behaviour changes (Principle III: no behavioural change). The tools'
    checks plus the unchanged suite are the reproducibility evidence.
- **User experience and diagnostics**: No warning, error text or console output changes. An added empty `catch`
  keeps the current behaviour of swallowing errors, which `try` without `catch` already has. Principle VII-C
  (propagate `ME` with its stack) applies to new or changed handlers, but changing those handlers to report
  errors would alter behaviour (FR-010). It is recorded in Complexity Tracking.
- **Performance and numerical integrity**: N/A (no runtime change).
- **External-solver configuration audit**: N/A (no solver invoked or changed).
- **Spec-driven scope control**:
  - Edited: `src/**/*.m`, `test/**/*.m` (outside submodule paths) and `initCobraToolbox.m`, only by the four
    tools and the hand edit for FR-005.
  - Read-only: `external/`, `deprecated/`, every `.gitmodules` path, `binary/`, `tutorials/`, `papers/`.
  - No new dependency in shipped code.
  - The main checkout's uncommitted change to `greedyExtremeRayBasis.m` on `089-large-model-solver-speed` is not
    part of this feature. That file is in the R1 set, so merging will need care (Risks).
- **MATLAB coding standards**:
  - No `evalc`, no warning suppression and no `nargin` changes.
  - VII-C exception: the empty `catch` added under FR-003 (Complexity Tracking).
  - VII-F: the MATLAB best-practice skills (`matlab-review-code`, MATLAB MCP `check_matlab_code`) are consulted
    in verification.
- **Parameter-setting fidelity**: N/A.
- **Artifact placement**:
  - Tools, baseline and reports go under `specs/20261102-153951-runmat-compat/` (`tools/`, `baseline/`,
    `reports/`).
  - The RunMat build, scratch copies and logs stay outside the repository.
  - Nothing new is created under `src/` or `test/`.

Result: **PASS** with one tracked exception (VII-C, below).

## Project Structure

### Documentation (this feature)

```text
specs/20261102-153951-runmat-compat/
├── spec.md
├── research.md              # Phase 0 (written during planning)
├── plan.md                  # this file
├── quickstart.md            # how to re-run every tool and measurement
├── tasks.md                 # /speckit-tasks
├── human-loop.md
├── checklists/requirements.md
├── tools/
│   ├── add_function_ends.py       # FR-001
│   ├── explicit_separators.py     # FR-002
│   ├── add_empty_catch.py         # FR-003 (to write)
│   ├── explicit_calls.py          # FR-004 (to write)
│   ├── parseTreeEquivalence.m     # verification (FR-010/FR-011)
│   ├── analyzerSnapshot.m         # verification (FR-011)
│   └── runmat_discovery.sh        # RunMat runner discovery measurement (to write)
├── baseline/                # MATLAB testAll results and analyzer snapshot before the change
└── reports/                 # per-category file lists, rejected files, RunMat defect report, final counts
```

### Source Code (repository root)

```text
src/**/*.m             # rewritten in place by the tools (no new files)
test/**/*.m            # rewritten in place (submodule paths such as test/models excluded)
test/testAll.m         # FR-005 hand edit (PERFORMANCE_REPORT expression) plus FR-004 bare calls
initCobraToolbox.m     # FR-004 bare calls only (for example prefdir -> prefdir())
```

**Structure Decision**: in-place rewrites of existing files. Each category is one commit, so the diff can be
reviewed and reverted per category, and reapplied with the same tool after merging `develop`.

## Phase design

1. **Baseline**: record MATLAB `testAll` results, the analyzer snapshot of in-scope files and RunMat discovery.
2. **Category commits, in order**: FR-009 re-encoding → FR-001 terminators → FR-002 separators → FR-003 empty
   `catch` → FR-004 explicit calls → FR-005 `testAll` guard. Each step: run the tool, verify (parse tree or
   category check, plus analyzer), revert rejects, re-measure discovery, commit. FR-001 is re-run after FR-002
   and FR-003, because unterminated files surface late (research.md R3).
3. **FR-006**: reduce the 2 RunMat crash files to a minimal construct. Rewrite only if an equivalent small change
   exists that passes parse-tree identity; otherwise record it as defect D7.
4. **Measurement**: run `testAll` under RunMat (FR-014 scratch copy, with failing out-of-scope folders off the
   path and residual in-scope failures set aside); record how far it gets and the counts.
5. **After**: run MATLAB `testAll` and compare with the baseline (SC-003); write the report (SC-005).

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Principle VII-C: the empty `catch` added by FR-003 does not propagate `ME` with its stack | `try` without `catch` already swallows errors; an empty `catch` is the only equivalent form | Adding reporting or rethrowing would change behaviour (FR-010, Principle II) |
| Principle V: a mechanical diff across about 1,000 files | RunMat rejects the whole run while any file fails | Rewriting only the files that `testAll` reaches first is not possible, because RunMat compiles every file on its path |

## Risks

- **Merge friction**: the large diff will conflict with open branches, including the main checkout's
  uncommitted `greedyExtremeRayBasis.m`. Mitigation: one commit per category, each re-runnable by tool.
- **Lexer misreads**: caught by parse-tree identity (6 of 147 in research) and reverted.
- **MATLAB `testAll` runtime** of more than 60 minutes, twice: unavoidable; it runs in the background.
- **RunMat may still not start `testAll`** after the slice (defects D4/D6/D10). This is accepted per the
  Clarification; the measured stopping point is the result.
