
# TestAll and Code Coverage CI - GitHub Actions Workflow

This repository contains the **Code Coverage CI** GitHub Actions workflow, which automates the process of running MATLAB tests and generating code coverage reports using MOcov and Codecov. The workflow is triggered on pushes and pull requests to the `develop` branch.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Workflow Breakdown](#workflow-breakdown)
  - [Trigger Configuration](#trigger-configuration)
  - [Jobs Definition](#jobs-definition)
  - [Steps Breakdown](#steps-breakdown)
- [Project Structure](#project-structure)


## Overview

The **Code Coverage CI** workflow automates testing and code coverage reporting. It ensures that code changes are tested and that code coverage metrics are updated automatically using [MOcov](https://github.com/MOxUnit/MOcov) and [Codecov](https://codecov.io/).

## Prerequisites

- **MATLAB R2022a**: The workflow uses MATLAB R2022a. Ensure your code is compatible with this version.
- **MOcov**: An open-source code coverage tool for MATLAB. It will be installed as part of the workflow.
- **Codecov Account**: Sign up for a [Codecov](https://codecov.io/) account to access code coverage reports.
- **Codecov Token**: Obtain a `CODECOV_TOKEN` from Codecov for authentication (required for private repositories).

## Setup Instructions

1. **Clone the Repository** (if not already):

   ```bash
   git clone https://github.com/opencobra/cobratoolbox.git
   ```

2. **Add the Workflow File**:

   - Save the provided workflow YAML file as `.github/workflows/codecov.yml` in the repository.

3. **Store Codecov Token**:

   - In the repository, go to **Settings** > **Secrets and variables** > **Actions**.
   - Click on **New repository secret**.
   - Add `CODECOV_TOKEN` as the name and paste the Codecov token as the value.

4. **Add MOcov to Your Project** (Optional for local testing):

   - **Clone MOcov**:

     ```bash
     git clone https://github.com/MOxUnit/MOcov.git /path/to/MOcov
     ```

   - **Add MOcov to MATLAB Path**:

     ```matlab
     addpath(genpath('/path/to/MOcov'));
     ```

5. **Create `run_coverage_tests.m` Script**:

   - Add the `run_coverage_tests.m` script to the root of the repository. This script runs tests and generates the coverage report using MOcov.

6. **Organize Project**:

   - **Source Code**: Place your MATLAB source code in the `src` directory.
   - **Tests**: Place test files in the `test` directory. Ensure `testAll.m` or your main test script is in this directory.

7. **Push Changes**:

   ```bash
   git add .
   git commit -m "Add Code Coverage CI workflow with MOcov"
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

   Checks out thr repository code so the workflow can access it.

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

3. **Install MOcov**

   Clones the MOcov repository and sets the appropriate permissions.

   ```yaml
   - name: Install MOcov
     run: |
       git clone https://github.com/MOxUnit/MOcov.git /opt/MOcov
       sudo chmod -R 755 /opt/MOcov
   ```

4. **Run MATLAB Tests and Generate Coverage**

   Executes MATLAB tests using MOcov to generate a code coverage report in XML format.

   ```yaml
   - name: Run MATLAB tests and generate coverage
     run: |
       matlab -batch "addpath(genpath(pwd)); run_coverage_tests"
   ```

   **Contents of `run_coverage_tests.m`:**

   ```matlab
   function run_coverage_tests()
       % Add MOcov to path
       addpath(genpath('/opt/MOcov'));
       
       try
           % Run tests and capture results
           disp('Running tests with coverage...');
           
           % Run tests directly first to capture results
           results = runtests('test/testAll.m');
           passed = all([results.Passed]);
           
           % Now run MOcov with a simpler expression that just runs the tests
           test_expression = 'runtests(''test/testAll.m'')';
           
           % Run MOcov for coverage analysis
           mocov('-cover', '.', ...
                 '-cover_xml_file', 'coverage.xml', ...
                 '-expression', test_expression);
           
           % Check results
           if ~passed
               error('Some tests failed. Check the test results for details.');
           end
           
           disp('All tests passed successfully!');
           disp(['Number of passed tests: ' num2str(sum([results.Passed]))]);
           
           exit(0);
       catch e
           disp('Error running tests:');
           disp(getReport(e));
           exit(1);
       end
   end
   ```

5. **Upload Coverage to Codecov**

   Uploads the generated coverage report to Codecov for analysis.

   ```yaml
   - name: Upload coverage to Codecov
     uses: codecov/codecov-action@v3
     with:
       files: ./coverage.xml
       flags: matlab
       token: ${{ secrets.CODECOV_TOKEN }}
       fail_ci_if_error: true
       comment: true
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
├── run_coverage_tests.m
└── (Other project files)
```

