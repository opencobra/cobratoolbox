
# Code Cov CI - GitHub Actions Workflow

This repository contains the **Code Cov CI** GitHub Actions workflow, which automates the process of running MATLAB tests and generating code coverage reports using Codecov. The workflow is triggered on pushes and pull requests to the `develop` branch.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Workflow Breakdown](#workflow-breakdown)
  - [Trigger Configuration](#trigger-configuration)
  - [Jobs Definition](#jobs-definition)
  - [Steps Breakdown](#steps-breakdown)
- [Codecov Integration](#codecov-integration)
- [Project Structure](#project-structure)
- [Benefits](#benefits)
- [License](#license)

## Overview

The **Code Cov CI** workflow automates testing and code coverage reporting for your MATLAB project. It ensures that your code changes are tested and that code coverage metrics are updated automatically.

## Prerequisites

- **MATLAB R2022a**: The workflow uses MATLAB R2022a. Ensure your code is compatible with this version.
- **GitHub Repository**: Your project should be hosted in a GitHub repository.
- **Codecov Account**: Sign up for a [Codecov](https://codecov.io/) account to access code coverage reports.
- **Codecov Token**: Obtain a `CODECOV_TOKEN` from Codecov for authentication.

## Setup Instructions

1. **Clone the Repository** (if not already):

   ```bash
   git clone https://github.com/your-username/your-repository.git
   ```

2. **Add the Workflow File**:

   - Save the provided workflow YAML file as `.github/workflows/codecov-ci.yml` in your repository.

3. **Store Codecov Token**:

   - In your GitHub repository, go to **Settings** > **Secrets and variables** > **Actions**.
   - Click on **New repository secret**.
   - Add `CODECOV_TOKEN` as the name and paste your Codecov token as the value.

4. **Organize Your Project**:

   - **Source Code**: Place your MATLAB source code in the `src` directory.
   - **Tests**: Place your test files in the `test` directory. Ensure `test_myfunction.m` is in this directory.

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
       results = runner.run(testsuite('test/test_myfunction.m')); \
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

## Codecov Integration

To visualize your code coverage metrics:

1. **Log in to Codecov**: Go to [Codecov](https://codecov.io/) and log in with your GitHub account.

2. **Find Your Repository**: Locate your GitHub repository in Codecov.

3. **View Coverage Reports**: After the workflow runs, your coverage reports will be available under your repository in Codecov.

## Project Structure

Organize your project as follows:

```
your-repository/
├── .github/
│   └── workflows/
│       └── codecov-ci.yml
├── src/
│   └── (Your MATLAB source code)
├── test/
│   └── test_myfunction.m
├── README.md
└── (Other project files)
```

## Benefits

- **Automated Testing**: Ensures new code changes are tested automatically.
- **Continuous Integration**: Integrates testing and coverage reporting into your development workflow.
- **Code Coverage Insights**: Identifies untested parts of your codebase, helping improve test coverage.
- **Quality Assurance**: Fails the workflow if tests do not pass, maintaining high code quality.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

For any questions or assistance, feel free to open an issue or reach out to the maintainers.

# Workflow File: `.github/workflows/codecov-ci.yml`

```yaml
name: Code Cov CI

on:
  push:
    branches: [develop]  # Trigger workflow on push to develop
  pull_request:
    branches: [develop]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
      
      # Set up MATLAB
      - name: Set up MATLAB
        uses: matlab-actions/setup-matlab@v1
        with:
          release: R2022a  # Specify the MATLAB version

      # Run only the specific test_myfunction.m file from the /tests directory
      - name: Run MATLAB tests and generate coverage
        run: |
          matlab -batch "import matlab.unittest.TestRunner; import matlab.unittest.plugins.CodeCoveragePlugin; import matlab.unittest.plugins.codecoverage.CoberturaFormat; runner = TestRunner.withTextOutput; runner.addPlugin(CodeCoveragePlugin.forFolder('src', 'Producing', CoberturaFormat('coverage.xml'))); results = runner.run(testsuite('test/test_myfunction.m')); assertSuccess(results);"
      
      # Upload coverage report to Codecov
      - name: Upload coverage to Codecov
        run: |
          bash <(curl -s https://codecov.io/bash) -f coverage.xml -F matlab
        env:
          CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}
```

*Note: Replace `your-username` and `your-repository` with your actual GitHub username and repository name in the URLs and commands.*
