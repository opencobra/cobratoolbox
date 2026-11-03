# Quickstart: re-running the RunMat-compatibility rewrite and its checks

All commands run from the repository root of this feature's branch. `F=specs/20261102-153951-runmat-compat`.

## Prerequisites
- MATLAB R2024b or newer, for `mtree`, `checkcode` and the test suite.
- Python 3 (standard library only).
- A RunMat binary, for measurement only. Built here from `feature/clean-room-matlab-builtins` @ `ebc6509f3` with:

  ```
  HDF5_DIR=<hdf5> cargo build --release -p runmat --no-default-features --features "gui,blas-lapack,wgpu,jit"
  ```

  The default OCCT feature needs CMake. At run time, set `LD_LIBRARY_PATH` to the HDF5 library folder.

## In-scope file list
`python3 $F/tools/scope_files.py > $F/reports/scope.txt` lists every tracked `.m` file under `src/`, `test/`
and the root `initCobraToolbox.m`, excluding `.gitmodules` paths, `external/` and `deprecated/`.

## One category
1. Copy the in-scope files to a "before" folder (the verification needs the originals).
2. Run the tool on the candidate list:
   - `python3 $F/tools/add_function_ends.py FILE...`
   - `python3 $F/tools/explicit_separators.py FILE...`
   - `python3 $F/tools/add_empty_catch.py FILE...`
   - `python3 $F/tools/explicit_calls.py --names NAMES FILE...`
3. Verify in MATLAB:
   ```matlab
   addpath([pwd filesep 'specs/20261102-153951-runmat-compat/tools'])
   parseTreeEquivalence(beforeRoot, pwd, listFile, outJson)   % FR-001, FR-002
   analyzerSnapshot(listFile, outJson)                        % FR-011, compare with the before snapshot
   ```
4. Revert every file that fails, and list it in `$F/reports/rejected-<category>.txt`.
5. Re-measure with `$F/tools/runmat_discovery.sh ROOT OUT` (RunMat runner discovery over `src/` and `test/`).

## MATLAB suite comparison (SC-003)
Run with `COBRA_CI=1 matlab -batch "cd test; testAll"` before and after, and keep each `resultTable` as
`$F/baseline/testAll-before.csv` and `$F/reports/testAll-after.csv`. The two must list the same tests with the
same `Passed`/`Failed`/`Skipped` values.

## testAll under RunMat (T019)
Use a full clone with submodules, not a git worktree (`initCobraToolbox` fails where `.git` is a file):

```bash
git clone --no-checkout <cobra main checkout> CLONE && git -C CLONE checkout <branch>
# point each submodule.<name>.url at a local copy in CLONE/.git/config, then
git -C CLONE -c protocol.file.allow=always submodule update --init
RUNMAT=<runmat binary> RUNMAT_LIBS=<HDF5 lib folder> $F/tools/runmat_testall.sh CLONE $F/reports/runmat-testAll.txt
```

The tool copies CLONE, sets aside every file RunMat cannot compile (except the entry points `test/testAll.m` and
`initCobraToolbox.m`), runs `COBRA_CI=1 runmat run test/testAll.m` with a time limit (`TIME_LIMIT`, default 4h),
and writes the summary to OUT: the files set aside by reason, then either the per-test results (also as `OUT.csv`)
or the stopping point. `COBRA_TESTS` selects tests as under MATLAB. `SHIMS=<folder>` supplies functions RunMat
lacks; such a run is not a measurement of COBRA under RunMat alone, and its summary names the shims.

## RunMat binary and libraries
The binary links `libhdf5.so.103`. If no system copy exists, link only that library into an empty folder and
pass it, so that no other conda libraries are loaded:

```bash
mkdir -p H5 && ln -s ~/anaconda3/lib/libhdf5.so.103* H5/
RUNMAT=<runmat binary> RUNMAT_LIBS=$PWD/H5 ...
```

## Analyzer comparison over all changed files (SC-002, T031)
```bash
git diff --name-only <feature base> HEAD -- src test initCobraToolbox.m | grep '\.m$' > changed.txt
```
```matlab
addpath([pwd filesep 'specs/20261102-153951-runmat-compat/tools'])
analyzerSnapshot('changed.txt', 'specs/20261102-153951-runmat-compat/reports/analyzer-after.json')
```
Then compare each file's identifiers with `$F/baseline/analyzer-before.json`. A file passes when no identifier
occurs more often than in the baseline. The feature base is `467094a5d`. A file also changed on another branch
is compared at its feature-branch version (`git show <feature branch>:<path>`).

## Path check (FR-007, FR-013, T032)
```bash
git diff --name-only develop HEAD | grep -E '^(external|deprecated)/'          # must print nothing
for s in $(git config -f .gitmodules --get-regexp '\.path$' | awk '{print $2}'); do
  git diff --name-only develop HEAD | grep -E "^$s(/|$)"; done                     # must print nothing
```

## Entry points under RunMat after US2
Replace `test/testAll.m` and `initCobraToolbox.m` in an existing `runmat_testall.sh` work tree (`WORK/tree`) and
run `COBRA_CI=1 runmat run --color never test/testAll.m` there. The result is recorded in
`$F/reports/runmat-testAll-after-us2.txt`.

## Defect reproducers (SC-005)
Each `$F/reports/repro/<id>/` is a separate folder. Run it from inside that folder, because RunMat compiles every
file in the folder:
`runmat run --color never <id>.m`. For D11, use `runmat test --list --path=. tests` instead.
In MATLAB, `cd` into the same folder and run `<id>` to see the expected result. The report is
`$F/reports/runmat-compat-report.md`.
