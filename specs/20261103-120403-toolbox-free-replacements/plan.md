# Implementation Plan: Plain-MATLAB replacements for paid-toolbox functions (first slice)

**Branch**: `20261103-120403-toolbox-free-replacements` | **Date**: 2026-11-03 | **Spec**: [spec.md](spec.md)

## Summary

Add parallel-pool helpers and 17 `cobra*` statistics replacements in
`src/base/utilities/toolboxFree/`, switch the call sites outside `old/`/`deprecated/`, test each
replacement against MathWorks documentation, SciPy references and (where installed) the
MathWorks function, have Codex review the code, and re-run existing tests of changed files.

## Technical Context

**Language/Version**: MATLAB R2025a (base + Parallel Computing); Python 3 with SciPy 1.16 for
references. **Primary Dependencies**: none new. **Storage**: none. **Testing**: Tier-1 tests,
`runScriptFile`, coverage helper; parity sections guarded by toolbox availability.
**Target Platform**: headless Linux CI, any MATLAB ≥ R2024b. **Project Type**: MATLAB library.
**Performance Goals**: replacements within a small factor of the toolbox functions for the
call-site sizes. **Constraints**: no shadowing, no interface change, no copied MathWorks code.
**Scale/Scope**: 21 new functions, ~70 call-site files, 21 new tests.

## Constitution Check

*GATE: passed before research; re-checked after design: still passes.*

- **Scientific code quality**: statistical semantics reproduced from documented formulas (R1).
- **Testing and reproducibility**: one Tier-1 test per new function; references documented
  (R2); existing tests of changed files re-run.
- **User experience and diagnostics**: unsupported options raise errors naming the option;
  helpers print nothing.
- **Performance and numerical integrity**: tolerances justified per reference source.
- **External-solver configuration audit**: N/A (no solver).
- **Spec-driven scope control**: new folder `src/base/utilities/toolboxFree/`, call-site lines
  only, tests under `test/verifiedTests/base/testToolboxFree/`.
- **MATLAB coding standards**: openCOBRA headers; `exist`/`isempty` optional arguments; no
  `evalc`; warnings visible.
- **Backward compatibility**: identical results with the toolbox installed (parity), no
  interface change (Principle II).
- **Artifact placement**: new subfolder under `src/base/utilities/` (Principle IX).

## Project Structure

```text
src/base/utilities/toolboxFree/   isParallelToolboxAvailable, getParallelPool, openParallelPool,
                                  closeParallelPool, cobra*.m (17)
test/verifiedTests/base/testToolboxFree/  test<Name>.m (one per new function), fixtures/
specs/20261103-120403-toolbox-free-replacements/  research, semantics, references/, review.md
```

## Complexity Tracking

No constitution violations; nothing to justify.
