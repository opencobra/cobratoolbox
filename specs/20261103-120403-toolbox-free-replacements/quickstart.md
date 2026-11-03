# Quickstart

1. `initCobraToolbox(false)`; from `test/`: `runScriptFile('<test>')` → passed, for every test in
   `test/verifiedTests/base/testToolboxFree/`.
2. `python3` on each script in `specs/20261103-120403-toolbox-free-replacements/references/`
   reproduces the SciPy reference values used in the tests.
3. Scan: no call to `gcp`, `parpool` or a replaced statistics function remains in `src/` outside
   `old/`/`deprecated/`.
4. Re-run existing tests of changed call-site files.
