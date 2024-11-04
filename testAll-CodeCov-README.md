
# TestAll and Code Cov CI - GitHub Actions Workflow

This repository contains the **Code Cov CI** GitHub Actions workflow, which automates the process of running MATLAB tests and generating code coverage reports using Codecov. The workflow is triggered on pushes and pull requests to the `develop` branch.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Workflow Breakdown](#workflow-breakdown)
  - [Trigger Configuration](#trigger-configuration)
  - [Jobs Definition](#jobs-definition)
  - [Steps Breakdown](#steps-breakdown)
- [Project Structure](#project-structure)
- [Benefits](#benefits)
- [License](#license)

## Overview

The **Code Cov CI** workflow automates testing and code coverage. It ensures that code changes are tested and that code coverage metrics are updated automatically.

## Prerequisites

- **MATLAB R2022a**: The workflow uses MATLAB R2022a. Ensure your code is compatible with this version.
- **Codecov Account**: Sign up for a [Codecov](https://codecov.io/) account to access code coverage reports.
- **Codecov Token**: Obtain a `CODECOV_TOKEN` from Codecov for authentication.

## Setup Instructions

1. **Clone the Repository** (if not already):

   ```bash
   git clone https://github.com/your-username/your-repository.git
   ```

2. **Add the Workflow File**:

   - Save the provided workflow YAML file as `.github/workflows/codecov.yml` in your repository.

3. **Store Codecov Token**:

   - In the repository, go to **Settings** > **Secrets and variables** > **Actions**.
   - Click on **New repository secret**.
   - Add `CODECOV_TOKEN` as the name and paste your Codecov token as the value.

4. **Organize Your Project**:

   - **Source Code**: MATLAB source code in the `src` directory, which it aready is.
   - **Tests**: Place test files in the `test` directory. Ensure `testAll.m` is in this directory.

5. **Push Changes**:

   ```bash
   git add .
   git commit -m "Add Code Cov CI workflow"
   git push origin develop
   ```

## Workflow Breakdown

### Trigger Configuration

The workflow is triggered on push events and pull requests to the `develop` branch.

```yaml
on:
  push:
    branches: [develop]
  pull_request:
    branches: [develop]
```

### Jobs Definition

The workflow defines a job named `test` that runs on the latest Ubuntu environment.

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
```

### Steps Breakdown

1. **Checkout Repository**

   Checks out your repository code so the workflow can access it.

   ```yaml
   - uses: actions/checkout@v3
   ```

2. **Set Up MATLAB**

   Installs MATLAB R2022a on the runner to execute MATLAB scripts and functions.

   ```yaml
   - name: Set up MATLAB
     uses: matlab-actions/setup-matlab@v1
     with:
       release: R2022a
   ```

3. **Run MATLAB Tests and Generate Coverage**

   Executes the specified MATLAB test and generates a code coverage report in Cobertura XML format.

   ```yaml
   - name: Run MATLAB tests and generate coverage
     run: |
       matlab -batch "import matlab.unittest.TestRunner; \
       import matlab.unittest.plugins.CodeCoveragePlugin; \
       import matlab.unittest.plugins.codecoverage.CoberturaFormat; \
       runner = TestRunner.withTextOutput; \
       runner.addPlugin(CodeCoveragePlugin.forFolder('src', 'Producing', CoberturaFormat('coverage.xml'))); \
       results = runner.run(testsuite('test/testAll.m')); \
       assertSuccess(results);"
   ```

4. **Upload Coverage to Codecov**

   Uploads the generated code coverage report to Codecov for analysis.

   ```yaml
   - name: Upload coverage to Codecov
     run: |
       bash <(curl -s https://codecov.io/bash) -f coverage.xml -F matlab
     env:
       CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}
   ```


## Project Structure

Organize your project as follows:

```
your-repository/
├── .github/
│   └── workflows/
│       └── codecov.yml
├── src/
│   └── (MATLAB source code)
├── test/
│   └── testAll.m
├
└── (Other project files)
```


