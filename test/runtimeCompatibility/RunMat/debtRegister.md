# RunMat compatibility debt register

The rules for this register, the markers and the re-check are in the constitution, Principle VIII-Runtime
(`.specify/memory/constitution.md`). This file lists the debt; it does not restate those rules.

- **Runtime**: RunMat (https://github.com/runmat-org/runmat), measured with v0.6.2 (`feature/clean-room-matlab-builtins` @ `ebc6509f3`).
- **Marker**: `% RUNTIME-DEBT(RunMat:<id>)`, one row below per marker occurrence.
- **Reproducers**: `repro/<id>/`. Each `expected.txt` is the MATLAB R2026a output.
- **Re-check**: `recheckRunMat.sh <runmat binary> [repository root]`.
- **Defect IDs**: from `specs/20261102-153951-runmat-compat/reports/runmat-compat-report.md` (D1–D22) and
  `specs/20261104-001324-runmat-init-mode/research.md` (D23–D29).
- **Origin**: feature `specs/20261104-001324-runmat-init-mode`.

## Workarounds

| Defect | File | Construct | MATLAB behaviour replaced | Removal condition | Reproducer |
|---|---|---|---|---|---|
| D6 | `initCobraToolbox.m` | `CBTDIR = fileparts(char(mfilename('fullpath')))` when `runmatMode` | `CBTDIR = fileparts(which('initCobraToolbox'))` | `repro/D6` and `repro/D24` both report removable; then use the `which` line in every mode | `repro/D6/` |
| D24 | `initCobraToolbox.m` | `char(...)` around `mfilename('fullpath')` in the same line | `mfilename` already returns `char` in MATLAB | removed together with the D6 row | `repro/D24/` |
| D10 | `initCobraToolbox.m` | `defaultSavePathLocation = ''` when `runmatMode` | `fullfile(prefdir(), 'pathdef.m')`; the value is used only when saving the path, which agent and runmat modes skip | `repro/D10` reports removable | `repro/D10/` |

## Blocking defects without a workaround

| Defect | Effect on COBRA | Files affected | Reproducer |
|---|---|---|---|
| D26 | Any `{}` (empty cell literal) fails at run time with `cell literal rows realize different widths`, reported at a wrong location. Removed from `initCobraToolbox.m` by the MATLAB-equivalent rewrite `cell(0, 0)`, which is not debt. Elsewhere it stops the first toolbox function that uses it. | 417 (`grep '{\s*}'`) | `repro/D26/` |
| D27 | A function reached through the search path that reads `nargin` fails to compile (`local may be read before it is assigned`). It stops `initCobraToolbox` at its first toolbox call. | 421 (`grep nargin`) | `repro/D27/` |
| D28 | A function reached through the search path that reads a `global` it does not assign fails to compile. This affects the solver registry and environment globals. | 323 (`grep '^\s*global'`) | `repro/D28/` |
| D29 | Calling a function with fewer arguments than it declares raises `Not enough input arguments`, even when the function guards optional inputs with `exist('x', 'var')` (constitution VII-D). | 447 (`grep "exist('x', 'var')"`) | `repro/D29/` |
