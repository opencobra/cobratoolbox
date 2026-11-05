# Implementation Plan: RunMat initialisation mode with recorded compatibility debt

**Branch**: `20261104-001324-runmat-init-mode` | **Date**: 2026-11-04 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/20261104-001324-runmat-init-mode/spec.md`

## Summary

`initCobraToolbox` gains a `'runmat'` value for its existing `mode` argument.
- It follows `'agent'` mode's flow, which is silent and skips git, network access, solver probing and path
  saving.
- Its only additions are registered RunMat workarounds for the root folder (D6, D24) and `prefdir` (D10).

`test/testAll.m` gains an opt-in, `COBRA_RUNMAT=1`, which:
- finds the root folder without `which`;
- calls `initCobraToolbox(false, 'runmat')`;
- skips the final `exit`.

Changes made in every mode:
- Two MATLAB-equivalent rewrites remove RunMat failures and are not debt: `{}` becomes `cell(0, 0)` (D26), and
  `genpath` of a folder that may be missing is guarded (D25).
- `PERFORMANCE_REPORT` is read through `eval` inside its guard (D5). This is a compile-time debt entry under the
  VIII-Runtime exception.

The debt record lives in `test/runtimeCompatibility/RunMat/`:
- a register of the workarounds and of the blocking defects that have no workaround (D26–D29);
- reproducers, each with the MATLAB output it should give;
- `recheckRunMat.sh`, which reports whether each entry is still needed or removable, and checks markers against
  the register one to one.

Research (research.md R2) showed that RunMat v0.6.2 cannot run toolbox functions that read `nargin` or a global,
or that are called with fewer arguments than declared (D27–D29). Success under RunMat is therefore measured as
reaching the first toolbox call and stopping on a registered defect (spec SC-001, SC-002). The previous
feature's report gets an erratum: its "D6 at `testAll.m:55`" was a misreported D26.

## Technical Context

**Language/Version**: MATLAB R2026a (reference). RunMat v0.6.2 is the runtime under test, built from
`feature/clean-room-matlab-builtins` @ `ebc6509f3`. It needs `libhdf5.so.103`, linked on its own from
`~/anaconda3/lib`. Bash and Python 3 (standard library) for the re-check script.

**Primary Dependencies**: none new. The previous feature's tools are reused: `runmat_testall.sh`,
`compare_testall.py`, `analyzerSnapshot.m` and the reproducers.

**Storage**: Markdown register and plain-text expected outputs in the repository.

**Testing**:
- MATLAB: `testInitCobraToolbox.m` (renamed from `testInitCobraToolboxAgentMode.m`), and the full `testAll` before
  and after (SC-003).
- RunMat: `recheckRunMat.sh`, and `runmat_testall.sh` with `COBRA_RUNMAT=1`.

**Target Platform**: Linux (development and CI). In MATLAB, `'runmat'` mode is platform-independent.

**Project Type**: MATLAB toolbox (library), start-up entry point and test harness.

**Performance Goals**: none. `'runmat'` mode is no slower than `'agent'` mode in MATLAB.

**Constraints**:
- MATLAB behaviour of `'default'` and `'agent'` modes is unchanged (Principle II).
- Workarounds stay in the two start-up files (FR-015).
- No path under `external/`, `deprecated/` or a submodule changes.

**Scale/Scope**:
- 2 source files: `initCobraToolbox.m` and `test/testAll.m`; plus one MATLAB-equivalent `{}` -> `cell(0, 0)` in
  the test helper `test/verifyCobraFunctionError.m` (FR-016, Gate 3).
- 1 test file, renamed and extended.
- 1 new folder under `test/` with the register, about 12 reproducers and the re-check script.
- An erratum in the previous feature's report.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Checked against constitution v1.8.0.

- **Scientific code quality**: no model, solver or numerical code changes. The initialisation contract is a
  public interface (Principle II). New `mode` value: `'default'` and `'agent'` are unchanged and the default mode
  stays `'default'`. **PASS**
- **Testing and reproducibility**: narrowest first.
  1. `testInitCobraToolbox.m` (MATLAB): `'runmat'` vs `'agent'` mode, the error for `updateToolbox`+`'runmat'`,
     the invalid-mode message, and the banner hyperlink.
  2. The four-case `PERFORMANCE_REPORT` check (MATLAB).
  3. `recheckRunMat.sh` (RunMat).
  4. `runmat_testall.sh` with `COBRA_RUNMAT=1` (RunMat).
  5. The full MATLAB `testAll`, before and after, compared with `compare_testall.py` (SC-003).

  **PASS**
- **User experience and diagnostics**: `'runmat'` mode prints `'agent'` mode's single summary line. The error
  for `updateToolbox=true` with `'runmat'` names the combination. The invalid-mode message lists `'runmat'`.
  **PASS**
- **Performance and numerical integrity**: N/A. No solver path changes, and no diagnostic is made skippable.
- **External-solver configuration audit**: N/A. No solver is invoked.
- **Spec-driven scope control**:
  - Edit: `initCobraToolbox.m`, `test/testAll.m`, `test/verifyCobraFunctionError.m` (line 35 only, FR-016),
    `test/verifiedTests/base/testInstall/` (rename and extend),
    `test/runtimeCompatibility/RunMat/` (new), and the erratum in
    `specs/20261102-153951-runmat-compat/reports/`.
  - Read-only: `external/`, `deprecated/`, submodules, and every other `src/` file.
  - No new dependency. **PASS**
- **MATLAB coding standards**:
  - VII-A: no `evalc` is added. `eval('PERFORMANCE_REPORT')` reads one variable, captures no output and
    suppresses nothing.
  - VII-B: warnings stay visible.
  - VII-C: no new `try/catch`.
  - VII-D: no `nargin` is added. `mode` already uses `exist`.
  - VII-E: the `initCobraToolbox` header documents `'runmat'` and points to the register.
  - VII-F: the MATLAB best-practice skill is applied at implementation.

  **PASS**
- **Parameter-setting fidelity**: N/A. No ported or literate output.
- **Alternative-runtime debt**: VIII-Runtime applies. Register entries planned:
  - Workarounds: D5 (`testAll`, compile-time), D6 and D24 (`initCobraToolbox` root, `testAll` root), D10
    (`initCobraToolbox` `prefdir`, `testAll` `exit`).
  - Blocking defects without a workaround: D26 outside the two files, D27, D28, D29.

  D23 (`usejava`) has no entry, because `'runmat'` mode never reaches the banner. **PASS**, with the compile-time
  exception used for D5.
- **Artifact placement**:
  - The register, reproducers and re-check script go in `test/runtimeCompatibility/RunMat/` (IX role map,
    v1.8.0).
  - The test stays in `test/verifiedTests/base/testInstall/`.
  - Measurement logs go in the feature folder.

  **PASS**

Post-design re-check: unchanged, **PASS**.

## Project Structure

### Documentation (this feature)

```text
specs/20261104-001324-runmat-init-mode/
├── spec.md, plan.md, research.md, data-model.md, quickstart.md, tasks.md
├── contracts/
│   ├── initCobraToolbox-mode.md      # the 'runmat' mode contract
│   ├── testAll-runmat-switch.md      # the COBRA_RUNMAT contract
│   └── debt-register.md              # register rows and re-check output
├── checklists/requirements.md
├── human-loop.md
├── reports/                          # RunMat measurement logs (implementation)
└── agent-runs/<UTC>-runmat-init-mode/implementation-receipt.md
```

### Source Code (repository root)

```text
initCobraToolbox.m                                   # 'runmat' mode; {} -> cell(0, 0); docs genpath guard; banner link restored
test/testAll.m                                       # COBRA_RUNMAT switch; eval read of PERFORMANCE_REPORT; {} -> cell(0, 0)
test/verifyCobraFunctionError.m                      # {} -> cell(0, 0) on line 35 (FR-016)
test/verifiedTests/base/testInstall/
└── testInitCobraToolbox.m                           # renamed from testInitCobraToolboxAgentMode.m, extended
test/runtimeCompatibility/RunMat/
├── debtRegister.md
├── recheckRunMat.sh
└── repro/<D5|D6|D10|D24|D26|D27|D28|D29>/<id>.m, expected.txt
```

**Structure Decision**:
- The source changes stay in the two start-up files.
- Every new file lives under the test role (`test/`), as constitution IX v1.8.0 requires.
- The previous feature's `reports/repro/` stays as its historical record. The register's reproducers are copies
  that the re-check owns.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| `eval('PERFORMANCE_REPORT')` in `test/testAll.m`, active in every mode (VIII-Runtime compile-time exception) | RunMat rejects the whole file at compile time (D5), so a run-time opt-in cannot avoid it | Removing the `PERFORMANCE_REPORT` workspace switch would be a user-visible change (Principle II). `evalin('caller', ...)` is equally text-evaluated and less clear in a script. |
