# Implementation Plan: Remove local machine details from older feature records

**Branch**: `20261104-201445-scrub-local-paths` | **Date**: 2026-11-04 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/20261104-201445-scrub-local-paths/spec.md`

## Summary

Edit 19 published files so they no longer hold personal machine details. Records and receipts get
line-level replacements; receipts also get a dated redaction note. The six benchmark scripts replace
fixed paths with paths derived from their own location, the in-repo `bench/ref` folder, and two
environment variables for private inputs. No benchmark logic changes. See [research.md](research.md)
for each decision and [quickstart.md](quickstart.md) for validation.

## Technical Context

**Language/Version**: MATLAB (benchmark scripts), Markdown (records)

**Primary Dependencies**: None new

**Storage**: Files in the repository

**Testing**: Scan, script checks and diff review in `quickstart.md`. Nothing under `test/` changes

**Target Platform**: Any clone; the benchmark scripts keep their existing Linux-only `/proc` use

**Project Type**: Documentation and tooling maintenance

**Performance Goals**: N/A

**Constraints**: Added lines must not repeat a removed detail; MATLAB runs go through the guarded
launcher, one at a time

**Scale/Scope**: 19 files, about 30 lines

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: No formulation, solver or interface change. PASS.
- **Testing and reproducibility**: No function under test, so no new test. The scripts become more
  reproducible, because they no longer depend on one machine. PASS.
- **User experience and diagnostics**: A missing private input stops with a message naming the
  environment variable. PASS.
- **Performance and numerical integrity**: Benchmark logic, seeds and output formats are unchanged.
  Recorded results are not edited. PASS.
- **External-solver configuration audit**: No solver parameter touched. N/A.
- **Spec-driven scope control**: Edit only the 19 files listed in the spec. `src`, `test`, other
  contributors' records and `external/` are read-only. `deprecated/_testTopology/loop3b_neg_eq.ext`
  is named by the feature, as Principle V requires. PASS.
- **MATLAB coding standards**: Added lines use `fullfile`, `fileparts`, `getenv` and `error` with
  identifiers, and no toolbox function. PASS.
- **Parameter-setting fidelity**: N/A.
- **Artifact placement**: New files stay in the feature directory. PASS.
- **Receipts**: Redaction is limited to personal data and marked, as the Implementation Receipt
  Ledger requires. PASS.
- **Implementation gate (Principle VI)**: The scripts are source-controlled scripts, so editing them
  waits for an explicit implementation command. PASS.

Re-check after design: PASS, no violations.

## Project Structure

### Documentation (this feature)

```text
specs/20261104-201445-scrub-local-paths/
├── spec.md
├── plan.md
├── research.md
├── quickstart.md
├── tasks.md
├── checklists/requirements.md
└── agent-runs/<UTC>-scrub-local-paths/implementation-receipt.md
```

### Source Code (repository root)

No source code changes. Edited files are listed in the spec's Scope section.

**Structure Decision**: One feature directory, based on `upstream/develop` so that it merges
independently of the coverage feature.

## Complexity Tracking

No violations.
