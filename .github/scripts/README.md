# Change-based CI test selection

`select_tests.py` picks the subset of `test/verifiedTests/**/test*.m` relevant to
a pull request's changed files, so CI stops re-running the whole MATLAB suite on
every PR. It is invoked by the **Analyze changed files and select relevant tests**
step in `.github/workflows/testAllCI_step1.yml`.

## How selection works

1. Index every `src/**/*.m` by its function name (== filename, per MATLAB).
2. Build a reverse-dependency graph: a file "depends on" a src function if its
   text mentions that name as a token. (Comments are *not* stripped — an extra
   edge only runs more tests, which is safe; a missed edge would not be.)
3. From the PR's changed **src** files, walk the reverse edges transitively to
   reach every `test*.m` that uses them directly or indirectly.
4. Changed `test*.m` files are always included directly.

The analysis **over-approximates**: it errs toward running more tests, never
fewer, so it will not silently skip a test that should have run.

## When the FULL suite runs anyway (conservative policy)

- the PR carries a **`ci-full`** label (`COBRA_FORCE_FULL`);
- a PR targets `master` (release baseline — enforced in the workflow);
- a changed path is core/shared: `src/base/**`, `initCobraToolbox.m`, the test
  harness (`test/*.m`), `.github/**`, `external/**`, `codecov.yml`;
- a changed `src/` file cannot be indexed;
- the selected set already reaches ≥ 90% of the suite (`FULL_FRACTION`);
- `BASE_REF` is empty (manual / `workflow_dispatch`) or the script errors.

If only non-code paths changed (docs, tutorials, …) and nothing reaches a test,
`mode=none` and the MATLAB + report steps are skipped.

## Coverage gate interaction

Because a selective run exercises only part of `src`, overall **project**
coverage drops versus the full-suite base. `codecov.yml` therefore makes the
**project** status *informational* and gates on **patch** coverage (the lines the
PR changed) instead. If the selector missed the relevant test, patch coverage
falls — a built-in check on the selector.

## Run it locally

```bash
git diff --name-only --diff-filter=ACMRT origin/develop...HEAD > changed.txt
python3 .github/scripts/select_tests.py --changed changed.txt --root .
# machine output on stdout (mode/run_tests/test_filter); summary on stderr
```
