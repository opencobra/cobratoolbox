# Cobratoolbox Website Documentation

This website is built and hosted using GitHub pages, please read the documentation for more information: https://docs.github.com/en/pages


## Continuous Integration of Tutorials:

Here are the following steps taken in the tutorial CI pipeline:
1. Contributor posts .m and .mlx tutorial to the [Tutorials Repository](https://github.com/opencobra/COBRA.tutorials)
2. This triggers the [GitHub action workflow](https://github.com/opencobra/COBRA.tutorials/blob/master/.github/workflows/main.yml) which is hosted on a local computer (self-hosted runner). Here the .mlx file is converted to a .html file and pushed to the gh-pages branch of the cobratoolbox repository
3. This then triggers a [seperate Github actions workflow](https://github.com/opencobra/cobratoolbox/blob/gh-pages/.github/workflows/main.yml) on the cobratoolbox gh-pages branch. This workflow reconfigures the various files and directories so that the html tutorial can be integrated into the website 

## Continuous Integration of Functions
Each accepted pull request triggers two workflows (W1 and W2) to generate documentation for functions, 
contributors and citations.

### W1 (.github/workflows/UpdateFunctionDocs.yml)
This workflow does the following:
1) Install python 3.10
2) Install required packages defined in /docs/requirements.txt
3) Run Python code (/docs/source/sphinxext/GenerateCitationsRST.py) to generate './docs/source/citations.rst' file
4) Run Python code (/docs/source/sphinxext/copy_files.py) to adapt the installed packages for Matlab functions. Files required to run this:
     1) 'docs/source/sphinxext/linkcode.py'
     2) 'docs/source/sphinxext/tabs.css'
5) Run python code (/docs/source/modules/GetRSTfiles.py) to generate all the .rst files required for documenting all the functions in '/src/'
6) Generate documentation using 'make HTML'. Files required to run this:
     1) 'docs/createModulesPage.sh'
     2) 'docs/generateJSONList.py'
     3) 'docs/source/sphinxext/CitationStyle.py'
     4) 'docs/COBRA.bib'.
COBRA.bib file has to be updated manually each month. Currently the .bib file is retrieved from [web of science](https://www.webofscience.com/wos/woscc/summary/d043671b-cd33-418b-9781-a92c21471897-bec2b3ea/relevance/1(overlay:export/exbt))
7) Deploying to gh-pages in the latest folder (Only files in /latest/modules/ folder and /latest/citations.html will get updated). This requires 'docs/source/Citations/citations.html'
   
### W2 (.github/workflows/UpdateContributors.yml)
This workflow does the following:
1) Install python 3.10
2) Install required packages defined in /docs/source/Contributions/requirements.txt
3) Run Python code files:
    1) /docs/source/Contributions/UpdateContributorsList.py
    2) /docs/source/Contributions/GenerateContributorsHTML.py <br>
       This code requires:
       	1) '/docs/source/Contributions/AllContributors.csv'
       	2) '/docs/source/Contributions/contributorsTemp.html'
       	3) '/docs/source/Contributions/contributors/contributors.html'
4) Deploying to gh-pages (/latest/contributors.html)

## Running Matlab Tests on Pull Requests
The testing workflow is defined in the main.yml file. This workflow is triggered on every push to the repository and runs the MATLAB tests using the GitHub Actions runner.

### Workflow Steps:
Setup: Install the MATLAB environment on the GitHub Actions runner.

Run Tests: Execute the runTestsAndGenerateReport.m script to run the tests and generate a report.

(Optional) Publish Results: You may choose to publish test results or reports to external platforms or as GitHub Pages.

### MATLAB Test Function: runTestsAndGenerateReport.m
The test function runTestsAndGenerateReport.m is responsible for executing the tests and generating a report of the results. This script is executed as part of the GitHub Actions workflow. The tests are designed to be automatically run using GitHub Actions whenever code is pushed to the repository. This ensures that any new changes do not introduce unexpected behavior or break existing functionality.
