# 🚀 Continuous Integration and Test Reporting for Cobra Toolbox

## 📌 Overview

This repository implements a GitHub Actions workflow to automate testing and reporting for pull requests. The setup consists of two workflows:

1. **`testAllCI_step1`** - Runs MATLAB tests and uploads the test results as artifacts.
2. **`testAllCI_step2`** - Retrieves test results and comments on the corresponding pull request.

This design ensures security while allowing test reports to be posted on pull requests, including those from forked repositories.

`testAllCI_step1` runs on a **self-hosted, MATLAB-licensed runner** and, beyond
running the tests, now also:

- **selects only the tests relevant to a PR** via a dependency analysis of the
  changed files, instead of re-running the whole suite every time
  (see [Change-Based Test Selection](#-change-based-test-selection-dependency-analysis));
- **cancels superseded runs** of the same PR through a concurrency group
  (see [Concurrency](#-concurrency-one-run-per-pr));
- **computes code coverage** (patched MOcov + jsonlab) and uploads it to Codecov,
  gated on **patch** coverage (see [Code Coverage Gating](#-code-coverage-gating));
- resolves a **fast/full execution mode** (see [Execution Modes](#-execution-modes-fastfull)).

---

## ⚠️ Important Note

These workflows should be implemented on the **default branch** of the repository (either `master` or `main` in newer repositories) to ensure proper execution and integration. Running workflows on other branches may lead to unexpected behavior, security issues, or failure to post comments on pull requests.

---

## 🔐 Handling Forked Repositories: Why Two Workflows?

When a pull request originates from a fork, the `pull_request` event runs in the context of the fork, meaning it does not have permission to write to the base repository. This prevents the workflow from posting comments on the pull request.

Using `pull_request_target` instead of `pull_request` would allow commenting on forked pull requests, but it introduces a significant security risk: the workflow would run with write permissions on the base repository, allowing potential malicious code execution.

To mitigate this, we split the workflow into two:

- **The first workflow (`testAllCI_step1`)** only has read permissions and runs the tests.
- **The second workflow (`testAllCI_step2`)** is triggered by the first workflow’s completion and runs in the base repository’s context, allowing it to post a comment securely.

---

## 🔄 Step-by-Step Workflow Execution

### **1️⃣ testAllCI_step1: Running Tests and Uploading Artifacts**

This workflow is triggered when a pull request is opened, synchronized, or reopened on the `develop` or `master` branches. It performs the following steps:

- **Check out merged PR code**:

```yaml
- name: Check out merged PR code
  uses: actions/checkout@v4
```

- **Run MATLAB Tests**:

```yaml
- name: Run MATLAB Tests
  run: |
    matlab -batch "run('initCobraToolbox.m'); run('test/testAll.m');"
```

- **Convert JUnit to CTRF format**:

```yaml
- name: Convert JUnit to CTRF
  run: |
    npx junit-to-ctrf ./testReport.junit.xml -o ./ctrf/ctrf-report.json
```

- **Upload CTRF Artifact**:

```yaml
- name: Upload CTRF Artifact
  uses: actions/upload-artifact@v4
  with:
    name: testReport
    path: ./ctrf/ctrf-report.json
```

- **Save PR Number and Upload as an Artifact**:
  To ensure that `testAllCI_step2` can correctly comment on the corresponding pull request, we save the PR number as an artifact in `testAllCI_step1`. Since `testAllCI_step2` is triggered by `testAllCI_step1` using `workflow_run`, it does not have direct access to the PR metadata. Uploading the PR number as an artifact allows `testAllCI_step2` to retrieve and use it for posting test results in the correct pull request.


```yaml
- name: Save PR Number
  run: echo "PR_NUMBER=${{ github.event.pull_request.number }}" >> $GITHUB_ENV

- name: Upload PR Number as Artifact
  run: echo $PR_NUMBER > pr_number.txt
  shell: bash

- name: Upload PR Number Artifact
  uses: actions/upload-artifact@v4
  with:
    name: pr_number
    path: pr_number.txt
```

Since this workflow only requires read permissions, it avoids potential security risks when dealing with external contributions from forked repositories.

---

### **2️⃣ testAllCI_step2: Downloading Artifacts and Posting Results**

This workflow is triggered when `testAllCI_step1` completes successfully. It follows these steps:

- **Download Test Report Artifact**:
Since GitHub Actions does not allow direct artifact downloads across workflows using `actions/download-artifact`, we use `dawidd6/action-download-artifact@v8` instead. This repository enables downloading artifacts from a previous workflow run by specifying the `run_id`, which is essential when handling artifacts between separate workflows. It follows these steps:
```yaml
- name: Download CTRF Artifact
  uses: dawidd6/action-download-artifact@v8
  with:
    name: testReport
    run_id: ${{ github.event.workflow_run.id }}
    path: artifacts
```

- **Download PR Number Artifact**:

```yaml
- name: Download PR Number Artifact
  uses: dawidd6/action-download-artifact@v8
  with:
    name: pr_number
    run_id: ${{ github.event.workflow_run.id }}
    path: pr_number
```

- **Read PR Number**:

```yaml
- name: Read PR Number
  id: read_pr_number
  run: |
    PR_NUMBER=$(cat pr_number/pr_number.txt)
    echo "PR_NUMBER=$PR_NUMBER" >> $GITHUB_ENV
```

- **Publish Test Report**:

The `cobra-report` format is exclusively designed for COBRA Toolbox by COBRA developers and contributed to the `ctrf-io` repository.

```yaml
- name: Publish Test Report
  uses: ctrf-io/github-test-reporter@v1.0.6
  with:
    report-path: 'artifacts/ctrf-report.json'          
    community-report: true
    community-report-name: 'cobra-report'
    issue: ${{ env.PR_NUMBER }}
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## ⚡ Change-Based Test Selection (Dependency Analysis)

Re-running the **entire** MATLAB suite on every pull request is wasteful: the
single self-hosted runner serializes jobs, so a full run can take hours and block
every other PR. `testAllCI_step1` therefore analyses each PR's changed files and
runs **only the tests that depend on them**.

### How it works

A pre-MATLAB step — **"Analyze changed files and select relevant tests"** — runs
`.github/scripts/select_tests.py`, which performs a static, token-based **reverse
dependency analysis** over `src/` and `test/`:

1. Every `src/**/*.m` is indexed by its function name (== filename, per MATLAB).
2. A file "depends on" a source function if its text references that name as a
   token. (Comments are intentionally **not** stripped — an extra edge only makes
   us run *more* tests, which is safe; a missed edge would not be.)
3. Starting from the PR's changed `src/` files, the analysis walks the reverse
   edges transitively to reach every `test*.m` that uses them, directly or through
   intermediate source functions. Changed `test*.m` files are always included.

The analysis **over-approximates** — it errs toward running more tests, never
fewer — so it will not silently skip a test that should have run.

The selected tests are passed to MATLAB as a `runTestSuite()` regexp in the
`COBRA_TESTS` environment variable. `test/testAll.m` reads it:

```matlab
testFilter = getenv('COBRA_TESTS');
if isempty(testFilter)
    [result, resultTable] = runTestSuite();          % full suite
else
    [result, resultTable] = runTestSuite(testFilter); % selected tests only
end
```

The workflow step exposes three outputs, consumed by later steps via
`steps.select.outputs`:

| Output        | Meaning                                                        |
| ------------- | -------------------------------------------------------------- |
| `mode`        | `full` \| `selective` \| `none`                                |
| `run_tests`   | `true` \| `false` (when `false`, the MATLAB + report steps are skipped) |
| `test_filter` | the `runTestSuite()` regexp (empty when `full`)                |

### When the FULL suite runs anyway (conservative, fail-safe policy)

To avoid ever missing a needed test, the full suite runs when **any** of these hold:

- the PR carries a **`ci-full`** label (`COBRA_FORCE_FULL`);
- the PR targets **`master`** (release baseline must stay thorough);
- a changed path is **core/shared**: `src/base/**`, `initCobraToolbox.m`, the test
  harness (`test/*.m`), `.github/**`, `external/**`, or `codecov.yml`;
- a changed `src/` file cannot be indexed;
- the selection already reaches **≥ 90%** of the suite (`FULL_FRACTION`);
- `BASE_REF` is empty (manual / `workflow_dispatch`) or the selector errors.

If only non-code paths changed (docs, tutorials, …) and nothing reaches a test,
`mode=none` and the MATLAB run is skipped entirely.

### Running the selector locally

```bash
git diff --name-only --diff-filter=ACMRT origin/develop...HEAD > changed.txt
python3 .github/scripts/select_tests.py --changed changed.txt --root .
# machine output (mode / run_tests / test_filter) on stdout; a summary on stderr
```

See `.github/scripts/README.md` for the full contract.

---

## 🔁 Concurrency: One Run per PR

The self-hosted runner processes one job at a time, so pushing several times to a
PR used to pile up redundant queued runs behind each other. A concurrency group
now cancels the in-flight run for a PR when a new commit is pushed:

```yaml
concurrency:
  group: cobratoolboxCI-${{ github.event.pull_request.number || github.ref }}
  cancel-in-progress: true
```

The group is keyed on the **PR number**, so different PRs never cancel each other —
only superseded runs of the *same* PR are cancelled.

---

## 🏃 Execution Modes (fast/full)

Independently of *which* test files are selected, each test can run in a `fast` or
`full` mode (feature "testAll performance modes"), resolved by
`getCobraTestMode()` and announced by `testAll.m`:

- **fast** (default on PRs to `develop`) — quick feedback on the VM;
- **full** — PRs targeting `master` run the complete breadth so the coverage-gate
  baseline stays thorough.

Set `COBRA_TEST_MODE=full` to force the complete suite locally.

---

## 📊 Code Coverage Gating

`testAllCI_step1` runs inside a `matlab-cov` Docker image that bakes a **patched
MOcov + jsonlab** (with `MOCOV_PATH`/`JSONLAB_PATH` set in the image ENV) so
`test/testAll.m` computes coverage and emits `coverage.xml` / `coverage.json`.
Coverage is **best-effort**: a failure of the coverage tooling is surfaced as a
warning but never fails the (already reported) test run. The report is always
uploaded as an artifact and, best-effort, to Codecov.

Because a **selective** run exercises only part of `src/`, overall **project**
coverage drops versus the full-suite base. `codecov.yml` therefore makes the
**project** status *informational* (reported, never blocking) and gates on
**patch** coverage — the lines the PR actually changed:

```yaml
coverage:
  status:
    project:
      default:
        informational: true
    patch:
      default:
        target: auto
        threshold: 10%
        informational: false
```

This is also a built-in check on the selector: if it missed the test that
exercises the changed code, patch coverage falls and the gate flags it.

---

## ✅ Conclusion

By structuring the workflows this way, we achieve the following:

- **Secure execution** without exposing repository write access to forked pull requests.
- **Successful test execution** and result upload.
- **Seamless commenting** on pull requests with test results while mitigating security risks.

This approach balances **security** and **functionality**, making it a robust solution for continuous integration in repositories that accept contributions from forks. 🚀
