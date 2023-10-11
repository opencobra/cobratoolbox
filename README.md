# Cobratoolbox Website Documentation

This website is built and hosted using GitHub pages, please read the documentation for more information: https://docs.github.com/en/pages


## Continuous Integration of Tutorials:

Here are the following steps taken in the tutorial CI pipeline:
1. Contributor posts .m and .mlx tutorial to the [Tutorials Repository](https://github.com/opencobra/COBRA.tutorials)
2. This triggers the [GitHub action workflow](https://github.com/opencobra/COBRA.tutorials/blob/master/.github/workflows/main.yml) which is hosted on a local computer (self-hosted runner). Here the .mlx file is converted to a .html file and pushed to the gh-pages branch of the cobratoolbox repository
3. This then triggers a [seperate Github actions workflow](https://github.com/opencobra/cobratoolbox/blob/gh-pages/.github/workflows/main.yml) on the cobratoolbox gh-pages branch. This workflow reconfigures the various files and directories so that the html tutorial can be integrated into the website 

## Continuous Integration of Functions
to be added ...

## Running Matlab Tests on Pull Requests
The testing workflow is defined in the main.yml file. This workflow is triggered on every push to the repository and runs the MATLAB tests using the GitHub Actions runner.

### Workflow Steps:
Setup: Install the MATLAB environment on the GitHub Actions runner.

Run Tests: Execute the runTestsAndGenerateReport.m script to run the tests and generate a report.

(Optional) Publish Results: You may choose to publish test results or reports to external platforms or as GitHub Pages.

### MATLAB Test Function: runTestsAndGenerateReport.m
The test function runTestsAndGenerateReport.m is responsible for executing the tests and generating a report of the results. This script is executed as part of the GitHub Actions workflow. The tests are designed to be automatically run using GitHub Actions whenever code is pushed to the repository. This ensures that any new changes do not introduce unexpected behavior or break existing functionality.
