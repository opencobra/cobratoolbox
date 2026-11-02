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
