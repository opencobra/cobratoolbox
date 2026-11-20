# Pull request description: changes since it was opened

Written for the opencobra maintainers reviewing the pull request. Replace the summary sentence
"**No file under `src/` is changed.**" with the paragraph below, and add the section after it.

---

One file under `src/` changes: `lrsRun` (see "Changes after review" below). Every other change is
tests and records.

## Changes after review

- **CI failures fixed.** CI failed ten new tests that passed locally:
  - **testLrsRun:** the CI machine has no `redund`. Fixed in `lrsRun` itself, as described below.
  - **Eight c13 tests:** they depended on solver files that `generateIsotopomerSolver` writes and
    `.gitignore` excludes. Each test now generates the solver itself, and puts back any solver files
    that were there before.
  - **testParse_Atomic_Weights_and_Isotopic_Compositions_for_All_Elements:** its name was longer
    than MATLAB's 63-character limit, so the file now has the 63-character name MATLAB itself uses.
- **`lrsRun` no longer needs the program `redund`.** With `param.redund = 0` it removes redundant
  facets by running `lrs` again, with lrs's own `redund 0 0` option, on a temporary copy of the
  facet output. Since lrslib 7, `redund` is the same program as `lrs`, and COBRA's own lrslib for
  Linux ships no `redund`. On the test inputs the result is identical to what `redund` produces. The
  interface, file names and error identifier are unchanged. `testLrsRun` now needs only `lrs`, so CI
  runs it instead of skipping it.
- **Constitution 1.9.0 and 1.10.0** (`.specify/memory/constitution.md`): new Principle XI,
  minimal dependence on third-party toolboxes and proprietary applications. Options are taken in
  this order:
  1. base MATLAB;
  2. a free component already shipped or required;
  3. our own clean reimplementation;
  4. only then a proprietary dependency, which the plan must justify and the tests must declare.
