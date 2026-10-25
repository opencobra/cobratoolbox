# Implementation Plan: Known-defects registry for test headers

**Branch**: none (work stays on `develop`) | **Date**: 2026-10-12 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/20261012-121035-known-defects-registry/spec.md`

## Summary

Implement Constitution III-Defects. A small Python tool in `.github/scripts/` reads the
standard defect entries from test headers ([contract](contracts/defect-entry-format.md)),
validates them, and writes the generated registry `test/known-defects.md`; its `--check` mode
fails when the registry is stale and runs as a CI step without MATLAB. The 5 pilot and 50
batch-2 test headers are rewritten (comments only) into the standard format so the first
registry contains every known defect.

## Technical Context

**Language/Version**: Python 3 standard library only (CI already runs `python3` for
`select_tests.py`; no MATLAB needed). Tested here with Python 3.12.

**Primary Dependencies**: none beyond the standard library (`re`, `argparse`, `pathlib`,
`unittest`).

**Storage**: the generated file `test/known-defects.md`.

**Testing**: `unittest` tests in `.github/scripts/test_known_defects.py` run in the same CI
job; plus the 55 MATLAB tests re-run through the harness runner after the header rewrite.

**Target Platform**: developer machines and the existing self-hosted CI runner.

**Project Type**: CI/documentation tooling plus comment-only edits of test files.

**Performance Goals**: under 10 seconds on the full test tree (it scans about 340 files).

**Constraints**: deterministic output (stable ordering, no timestamps, `\n` line endings,
independent of working directory and directory order); no change under `src/`; no change to
any test assertion.

**Scale/Scope**: about 340 test files scanned, 55 headers rewritten, 1 registry, 1 script, 1
unit-test file, 1 README section, 1 workflow step.

## Constitution Check

*GATE: passed before research; re-checked after design: still passes.*

- **Scientific code quality**: no formulation, solver or interface touched; `src/` read-only.
- **Testing and reproducibility**: Principle III and III-Defects apply. The tool has its own
  automated tests (FR-010); the 55 MATLAB tests are re-run through the harness runner to prove
  the header rewrite changed no behaviour. Commands in [quickstart.md](quickstart.md).
- **User experience and diagnostics**: the tool prints errors as `file:line: message`, and the
  check prints the exact command to regenerate.
- **Performance and numerical integrity**: N/A for numerics; runtime bound stated above.
- **External-solver configuration audit**: N/A, no solver.
- **Spec-driven scope control**: edit `.github/scripts/` (new files, README), one workflow
  step, `test/known-defects.md` (generated), and comment lines of 55 test files. Read-only:
  all of `src/`.
- **MATLAB coding standards**: applies to the 55 edited files only in that no code line may
  change; verified by comparing the non-comment lines before and after.
- **Parameter-setting fidelity**: N/A.
- **Artifact placement**: script and its tests beside the existing CI scripts
  (`.github/scripts/`); registry under `test/` (test-suite role, Principle IX); no new
  top-level folder. The generated registry is a tracked file, not hidden output.

## Project Structure

### Documentation (this feature)

```text
specs/20261012-121035-known-defects-registry/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/defect-entry-format.md
└── tasks.md          # created by /speckit-tasks
```

### Source Code (repository root)

```text
.github/
├── scripts/
│   ├── known_defects.py          # new: generator + --check
│   ├── test_known_defects.py     # new: unit tests (unittest)
│   └── README.md                 # edited: new section
└── workflows/testAllCI_step1.yml # edited: one new step
test/
├── known-defects.md              # new, GENERATED
└── verifiedTests/**/test*.m      # 55 headers edited (comments only)
```

**Structure Decision**: single Python module with a pure parsing/rendering core and a thin
command-line layer, so the unit tests exercise the core directly.

## Complexity Tracking

No constitution violations; nothing to justify.
