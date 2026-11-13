# Reference environment (T002)

- MATLAB R2025a, Gurobi as the only commercial solver, no paid MATLAB toolboxes; MATLAB sessions
  started through a memory-capped wrapper, at most three at a time.
- `test/models` checkout synced on 2026-11-13 from 11da48e to the commit recorded by the branch,
  75c070d01 (local working copy only; the submodule pointer is not committed). After the sync all
  37 files in `test/models/mat/` are MAT files (before it, `Recon3DModel_301_xomics_input.mat` was an
  HTML page from a failed download).
- External programs on the reference machine (T008): `obabel`, `lrs`, `java`, `python3` (3.12),
  `git`, `curl` are installed; `cxcalc` (ChemAxon), `babel`, GAMS, conda and `python2` are not.
  Tests that need an installed program declare it with `prepareTest('requiredSoftwares', {...})`, so
  they run here and skip where the program is missing. Tests never use the internet.
