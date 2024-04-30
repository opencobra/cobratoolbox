# Cobratoolbox Website Documentation

This website is hosted on the GitHub servers using gh-pages. Here at the gh-pages branch is the source code of the website. If changes are made here, changes are made to the website. If you are interested to learn more about how gh-pages works check out the documentation for more information: https://docs.github.com/en/pages


## Continuous Integration of Tutorials:
### High level Overview
The whole idea of the continuous integration of the tutorials is that whenever a user contributes a tutorial in the format of a .mlx file on the [tutorials repo](https://github.com/opencobra/COBRA.tutorials) it should be converted to html and then rendered accordingly on the Cobratoolbox website in the [tutorials section](https://opencobra.github.io/cobratoolbox/stable/tutorials/index.html). This involves using MATLAB on a self-hosted server (King server) to generate the html file. This html is then pushed to the websites codebase repository which is the [gh-pages branch](https://github.com/opencobra/cobratoolbox/tree/gh-pages) of the main cobratoolbox repository.

GitHub actions is used to detect when a push (specifically .mlx push) is made to the tutorials repo. Then once the .mlx has been converted it is pushed to the gh-branch of the main repo. Again, GitHub actions can detect this push and configures the website to incorporate the extra tutorial. 

### Detailed Documentation
**Step 1: Pushing MLX files to the tutorials repository:**
To understand GitHub actions you need to look for the github workflow folder where you will find a .yml which contains all the details about the github action. The worflows can be found by navigating to ./.github/workflows/ . In the tutorials repo you will find a ‘[main.yml](https://github.com/opencobra/COBRA.tutorials/blob/master/.github/workflows/main.yml)’ file.

**What does main.yml do?**
Here is an explanation of each section of the .yml file. Pictures of the sections are added and an explanation is given beneath the picture.

```
on:
  push:
    branches: [ master ]
    paths:
    - '**.mlx'
```


This section of code basically means it will only run when a push is made to the master branch and one of the file types is a .mlx file. If not .mlx files are pushed, we don’t continue.

```
jobs:
  copy-changes:
    runs-on: self-hosted
    steps:
      - name: Checkout Source Repo
        uses: actions/checkout@v2
        with:
          repository: 'openCOBRA/COBRA.tutorials'
          token: ${{ secrets.GITHUB_TOKEN }}
          fetch-depth: 0
```


- Next, we have a series of ‘jobs’ to compute.
- The ‘runs-on’ parameter indicates where these jobs are computed. Here I specify it runs on ‘self-hosted’ because we need Matlab on King to run the .mlx to html. Generally, I would avoid using a self-hosted server but since Matlab is not an opensource programming language it needs to be ran a computer which has Matlab installed with a license.
- There are several steps to do in the jobs section. Here the first step is to checkout the source repo i.e. get all the details about the repo and the pushes made to the repo.

```
- name: Get All Changed Files
  id: files
  uses: jitterbit/get-changed-files@v1

- name: Find changed files
  id: getfile
  run: |
      files=$(echo "${{ steps.files.outputs.all }}" | tr ' ' '\n' | grep -E '\.mlx$')
      echo "::set-output name=file::$files"
```


- Here we have two more steps. The first step in this picture is used to find all the files that have been changed based on the most recent push.
- The next step is then used to find all the .mlx files that were pushed to the repository.

```
  - name: Give execute permission to the script
    run: chmod +x build.sh
    
  - name: Give execute permission to the other script  
    run: chmod +x setup.sh
```


The chmod command just makes the .sh files executable.

**Quick note on setup.sh and build.sh:**

• The setup.sh script automates the process of synchronizing .mlx files to the ghpages branch of the cobratoolbox GitHub repository. It requires three inputs: the repository identifier in owner/name format, a token for authentication, and the file path of the .mlx files to be synchronized. Upon execution, the script clones the cobratoolbox repository, configures git for automated operations, and targets aspecific directory within stable/tutorials/ to update. It clears this directory and copies the new .mlx files into it, ensuring that any changes are committed and pushed. This operation keeps the gh-pages branch of the cobratoolbox repository consistently updated with the latest .mlx files for documentation or tutorials.

• The build.sh script is designed for converting .mlx files to .html format and synchronizing them with the gh-pages branch of the cobratoolbox repository,. It takes three arguments: the repository identifier, a token for authentication, and the path of the .mlx file to be converted. Initially, the script converts the .mlx file to .html using MATLAB commands, assuming MATLAB is installed and accessible in the PATH. It then clones the target repository, sets up git with predefined user details, and switches to the gh-pages branch. The script creates a target directory within stable/tutorials/, copies the converted .html file into this directory, and finalizes by committing and pushing the changes.

• Both files can be found on the tutorial’s repository. Here are the links to [setup.sh](https://github.com/opencobra/COBRA.tutorials/blob/master/setup.sh) and [build.sh](https://github.com/opencobra/COBRA.tutorials/blob/master/build.sh)

```
  - name: Sync with Destination Repo
    run: |
      counter=0
      for file in ${{ steps.getfile.outputs.file }}; do
        if [ $counter -eq 0 ]
        then
          # This is the first iteration, handle the file differently
          ./setup.sh opencobra/cobratoolbox ${{ secrets.DEST_REPO_TOKEN }} $file 
          ./build.sh opencobra/cobratoolbox ${{ secrets.DEST_REPO_TOKEN }} $file 
        else
          ./build.sh openCOBRA/cobratoolbox ${{ secrets.DEST_REPO_TOKEN }} 
        fi
        counter=$((counter+1))
      done
    if: steps.getfile.outputs.file != ''
```

Here is the code to run the setup.sh and build.sh. We loop through all the .mlx files that were pushed. If it is the first file we are looking at we also run setup.sh to create the folder locations in the cobratoolbox – ghpages branch repository. Then afterwards build,sh is ran to convert the file to html and push to the created folder location

### Configuring the King Server

Go to this page of the repo to create a new self-hosted runner:

![image](https://github.com/opencobra/cobratoolbox/assets/68754265/05535af0-9ccf-4c38-9e79-512f738cc0f0)


By pressing the green new runner button, you are given easy instructions on how to set it up. You should have access to a terminal on King for this. To run the self-hosted runner nagivate to the folder you created it in and run ./run.sh to run the self-hosted runner.

You also need to make sure you have Matlab downloaded and working on the king server also. In the ‘[build.sh](https://github.com/opencobra/COBRA.tutorials/blob/master/build.sh)’ file the location of matlab is currently in my directory but you can add Matlab to another location and change the link to the location in the build.sh file.

### Part 2: The html files then get pushed to the gh=pages branch
In a similar fashion to the first step a .yml file is in the .github/workflows folder of the ghpages branch on the main cobratoolbox repository. The .yml file is called ‘[main.yml](https://github.com/opencobra/cobratoolbox/blob/gh-pages/.github/workflows/main.yml)’ and is trigger when a html file is pushed to the gh-pages branch of the repository. 

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
