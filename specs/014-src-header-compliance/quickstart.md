# Quickstart & Validation: src/ Function Header Documentation Compliance

Runnable scenarios that prove the feature works end-to-end. Rules and data structures
are defined in [`contracts/header-rules.md`](./contracts/header-rules.md) and
[`data-model.md`](./data-model.md); this file is the run/verify guide only.

## Prerequisites

- MATLAB R2024b+ available (via the MATLAB MCP server or a local install), headless-
  capable. No solver, internet, or GUI is required.
- Repo initialised for path resolution as usual (`initCobraToolbox` not required for the
  checker, which only reads files, but `test/testAll.m` context applies in CI).
- Python doc toolchain (only for the secondary Sphinx-parse check, SC-004):
  `documentation/requirements.txt` (`sphinxcontrib-matlabdomain==0.18.0`).

## Scenario 1 — Checker runs and reports (US1 / FR-001, FR-002)

```matlab
% from repo root, in MATLAB
addpath(genpath('test/verifiedTests/documentation'));
report = testHeaderCompliance('report');   % returns a ComplianceReport struct
disp(report.perDomain);                     % per-domain files / violations
```

Expected: a `ComplianceReport` (see data-model.md) listing violations by file, rule, and
domain, plus totals and the excluded-vendored set. Re-running yields the identical
report (reproducible). The committed baseline lives at `reports/baseline.md`.

## Scenario 2 — CI gate passes only when in-scope headers are clean (US1 / FR-013, SC-007)

```matlab
results = runtests('test/verifiedTests/documentation/testHeaderCompliance.m');
assert(all([results.Passed]));   % passes iff zero error-severity in-scope violations
```

Negative check: temporarily break one in-scope header (e.g. delete an `OUTPUTS:` line in a
scratch copy) → the test FAILS naming the file and rule id. Restore → it passes. This
demonstrates the standing gate.

## Scenario 3 — Every input/output documented for a domain (US2 / FR-003–FR-007)

```matlab
report = testHeaderCompliance('report', 'src/base');   % scope to one domain/folder
assert(isempty(report.violations([report.violations.severity] == "error")));
```

Expected after remediation of `src/base`: zero error-severity violations; a manual spot
check of a few functions shows each input and output on its own dedicated header line
with correct 4-space indentation and colons.

## Scenario 4 — Struct fields the function uses are documented (US3 / FR-006)

Pick a function that reads model fields, e.g. inspect a remediated header:

```matlab
help src/analysis/FBA/optimizeCbModel      % model input lists .S, .lb, .ub, .c, .b, ...
```

Expected: the struct argument lists each field the body reads/writes as
`* .field - description`, with meanings consistent with `COBRAModelFields.rst` and the
code's usage — and NOT the entire model schema, only the used fields.

## Scenario 5 — Behaviour preserved: comments-only diff (FR-008, SC-005)

```bash
# per changed file (and across the whole feature branch), executable lines are unchanged
git diff --stat develop..HEAD -- 'src/**/*.m'          # shows churn
test/verifiedTests/documentation/checkCommentsOnly.sh develop HEAD               # (feature helper) exits non-zero
                                                        # if any non-comment line changed
```

Expected: the comments-only verifier passes for every changed `src/*.m` file — zero
executable-line changes. (The verifier compares non-comment/non-blank lines pre/post.)

## Scenario 6 — Sphinx parse succeeds (SC-004)

```bash
cd documentation
make html 2>&1 | tee /tmp/sphinx.log
grep -Ei 'error|failed to parse|WARNING: .*signature' /tmp/sphinx.log || echo "no header-format errors"
```

Expected: no header-format / signature-parse errors attributable to audited functions.

## Definition of done (maps to Success Criteria)

- [ ] `testHeaderCompliance` reports **0** error-severity in-scope violations (SC-001, SC-002, SC-003).
- [ ] The test is wired into `test/testAll.m` and passes in CI headless (SC-007).
- [ ] Comments-only verifier passes for every changed file (SC-005).
- [ ] Sphinx parse shows no header-format errors (SC-004).
- [ ] `reports/baseline.md` and a post-remediation report record per-domain before/after (SC-006).
