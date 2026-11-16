# Reference environment (T002)

- MATLAB R2025a, Gurobi as the only commercial solver, no paid MATLAB toolboxes; MATLAB sessions
  started through a memory-capped wrapper, at most three at a time.
- `test/models` checkout synced on 2026-11-13 from 11da48e to the commit recorded by the branch,
  75c070d01 (local working copy only; the submodule pointer is not committed). After the sync all
  37 files in `test/models/mat/` are MAT files (before it, `Recon3DModel_301_xomics_input.mat` was an
  HTML page from a failed download).
- External programs on the reference machine (T008; corrected in wave 05): `lrs`, `java`, `python3` (3.12),
  `git`, `curl` are installed; `cxcalc` (ChemAxon), `babel`, GAMS, conda and `python2` are not.
  Tests that need an installed program declare it with `prepareTest('requiredSoftwares', {...})`, so
  they run here and skip where the program is missing. Tests never use the internet.
- Open Babel (`obabel`) is installed but cannot run from MATLAB's `system()`: MATLAB's bundled
  libstdc++ lacks GLIBCXX_3.4.32, which obabel needs (found in wave 05). It counts as not available;
  `prepareTest('requiredSoftwares', {'obabel'})` would not skip, because it only checks `which`.
- `initCobraToolbox` removes the `src/analysis/thermo/*/new` folders from the MATLAB path, so files
  there are shadowed by their `old/` copies and are excluded as not on the path.
- Coverage sessions (tools/run_coverage.sh): at most ~110 tests per session and one session of the
  lead at a time; each session gets a private TMPDIR and an idle cap (default 900 s). Reason: on
  R2025a a long coverage session of the Tier 1 set stalls (MATLAB's `Connector[#1]` thread at 100%,
  no system call, memory far below the cap) around the 125th test; alone or in shorter sessions the
  same tests pass, and so do all of them in one session without coverage (checked 2026-11-16).
