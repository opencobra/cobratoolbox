# 🚀 Continuous Integration and Test Reporting for Cobra Toolbox

## 📌 Overview

This repository implements a GitHub Actions workflow to automate testing and reporting for pull requests. The setup consists of two workflows:

1. **`testAllCI_step1`** - Runs MATLAB tests and uploads the test results as artifacts.
2. **`testAllCI_step2`** - Retrieves test results and comments on the corresponding pull request.

This design ensures security while allowing test reports to be posted on pull requests, including those from forked repositories.

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

## ✅ Conclusion

By structuring the workflows this way, we achieve the following:

- **Secure execution** without exposing repository write access to forked pull requests.
- **Successful test execution** and result upload.
- **Seamless commenting** on pull requests with test results while mitigating security risks.

This approach balances **security** and **functionality**, making it a robust solution for continuous integration in repositories that accept contributions from forks. 🚀
