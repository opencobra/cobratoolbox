# Quickstart: validating the RunMat initialisation mode

From the repository root on branch `20261104-001324-runmat-init-mode`. `F=specs/20261104-001324-runmat-init-mode`.

## Prerequisites
- MATLAB R2026a.
- The RunMat v0.6.2 binary, with `libhdf5.so.103` linked into an otherwise empty folder `H5`. Set
  `RUNMAT=<binary>` and `RUNMAT_LIBS=$PWD/H5`. See the quickstart of `specs/20261102-153951-runmat-compat`.

## 1. MATLAB: modes and interface (SC-004, FR-001, FR-003, FR-014)
```matlab
cd test; runTestSuite  % or: COBRA_TESTS=testInitCobraToolbox testAll
```
Expected: `testInitCobraToolbox` passes, including its `'runmat'`-mode and banner-link checks.

## 2. MATLAB: PERFORMANCE_REPORT unchanged (FR-007)
Run the four cases in MATLAB, as in the previous feature's T017: `COBRA_PERF` set or not, crossed with the
variable absent, empty, false or true. The old and new values must be equal.

## 3. RunMat: debt re-check (SC-005, SC-006)
```bash
LD_LIBRARY_PATH=$RUNMAT_LIBS test/runtimeCompatibility/RunMat/recheckRunMat.sh $RUNMAT
```
Expected: one line per defect, with every one *still needed* under v0.6.2, and exit status 0 (markers match the
register).

## 4. RunMat: start-up measurement (SC-001, SC-002)
```bash
COBRA_RUNMAT=1 RUNMAT=$RUNMAT RUNMAT_LIBS=$RUNMAT_LIBS \
  specs/20261102-153951-runmat-compat/tools/runmat_testall.sh <full clone> $F/reports/runmat-testAll.txt
```
Expected: the stopping point is the first toolbox call in `initCobraToolbox`, with an error listed under
*Blocking defects* (D27, D28 or D29).

## 5. MATLAB: suite unchanged (SC-003)
`COBRA_CI=1 matlab -batch "cd test; testAll"` on a full clone, before and after. Then compare:
```bash
python3 specs/20261102-153951-runmat-compat/tools/compare_testall.py compare before.csv after.csv
```
Expected: no difference.

## 6. Analyzer and paths (SC-007, FR-015)
- Run `analyzerSnapshot` on the two files before and after; no new identifier is allowed.
- `git diff --name-only develop HEAD` lists nothing under `external/`, `deprecated/` or a submodule path.
