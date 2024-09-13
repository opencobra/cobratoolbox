# Cobratoolbox Website Documentation

This website is hosted on the GitHub servers using gh-pages. Here at the gh-pages branch is the source code of the website. If changes are made here, changes are made to the website. If you are interested to learn more about how gh-pages works check out the documentation for more information: https://docs.github.com/en/pages


## Continuous Integration of Tutorials:
Part 1 of the CI occurs when a contributor pushes their tutorial .mlx file to the Tutorials Repository. In this part the .mlx file is also converted into a .html and .pdf file. Detailed Documentation for the first part is ‘[here](https://github.com/opencobra/COBRA.tutorials/tree/master/.github/workflows)’
### Part 2: The html files then get pushed to the gh-pages branch
A workflow is then set up to be trigged when a .html file is to the gh-pages branch. The .yml file is called ‘[main.yml](https://github.com/opencobra/cobratoolbox/blob/gh-pages/.github/workflows/main.yml)’.

The main.yml can be explained as follows:

```
on:
  push:
    branches: [ gh-pages ]
    paths:
    - '**.html'
```


This specifies that the .yml file will run if a .html file is pushed to the gh-pages branch.

```
jobs:
  extract-info:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v2
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          fetch-depth: 0
```

Here the second step is to checkout the repository and find any changes that were made. Also note that we are now running on ‘ubuntu-latest’ and not ‘self-hosted’ as there is no need to use King for this part.

```
- name: Check Commit Message
  id: check_msg
  run: |
    commit_msg=$(git log --format=%B -n 1)
    if [[ "$commit_msg" == "Sync files from source repo" ]]; then
      echo "::set-output name=run_job::true"
    else
      echo "::set-output name=run_job::false"
    fi
```


In the tutorials repo we push to the gh-pages branch with the particular comment: ‘Sync files from source repo’. This helps distinguish between slight edits made to pages on the website and tutorial pushes from the tutorials repo. Here this piece of code checks this.

```
- name: Set up Python
  uses: actions/setup-python@v2
  if: steps.check_msg.outputs.run_job == 'true'
  with:
    python-version: '3.x'

- name: Install Dependencies
  if: steps.check_msg.outputs.run_job == 'true'
  run: |
    python -m pip install --upgrade pip
    pip install beautifulsoup4

- name: Get Changed HTML Files
  id: getfile
  if: steps.check_msg.outputs.run_job == 'true'
  run: |
    changed_files=$(git diff --name-only HEAD~1 HEAD | grep '\.html')
    echo "::set-output name=file::$changed_files"
```

Here are some basic steps such as 1. Set up python got github actions 2. Install Python dependencies needed 3. Get the html files that were pushed to the repository.

```
- name: Extract Info from HTML Files
  if: steps.check_msg.outputs.run_job == 'true'
  run: |
    for file in ${{ steps.getfile.outputs.file }}
    do
      python extract_info.py $file
    done
```


Now we run the python file to configure the website to adjust to the added tutorial.

```
- name: Commit and Push New File
  if: steps.check_msg.outputs.run_job == 'true'
  run: |
    git config user.name "GitHub Action"
    git config user.email "action@github.com"
    git add .
    git commit -m "Sync files from source repo" || echo "No changes to commit"
    git push -f origin gh-pages
```

After changing and adding the folders/files around in the repo we push the changes to the repository

**What is extract_info.py?**
This Python script processes the HTML file to extract its heading and then uses this information to update the website's [tutorial homepage](https://opencobra.github.io/cobratoolbox/stable/tutorials/index.html). Initially, it reads the specified HTML file to find the main heading (inside an h1 tag). Then, it modifies a template HTML file (HOLDER_TEMPLATE.html) by replacing a placeholder with the path of the processed file, and saves this modified content as a new tutorial file within a predefined directory structure (stable/tutorials). Additionally, the script updates the index.html file located within the same stable/tutorials directory, adding a link to the new tutorial under a specific section, which is determined by part of the original file's path.


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
