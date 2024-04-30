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

![image](https://github.com/opencobra/cobratoolbox/assets/68754265/bfdb2072-f7d7-480f-b483-a8b701149284)


- Next, we have a series of ‘jobs’ to compute.
- The ‘runs-on’ parameter indicates where these jobs are computed. Here I specify it runs on ‘self-hosted’ because we need Matlab on King to run the .mlx to html. Generally, I would avoid using a self-hosted server but since Matlab is not an opensource programming language it needs to be ran a computer which has Matlab installed with a license.
- There are several steps to do in the jobs section. Here the first step is to checkout the source repo i.e. get all the details about the repo and the pushes made to the repo.

![image](https://github.com/opencobra/cobratoolbox/assets/68754265/92cc085c-9d8d-4451-a9ef-c4efee7e41d7)


- Here we have two more steps. The first step in this picture is used to find all the files that have been changed based on the most recent push.
- The next step is then used to find all the .mlx files that were pushed to the repository.

![image](https://github.com/opencobra/cobratoolbox/assets/68754265/6f7af540-8b60-425c-89d1-1cf0ce5c9e9d)


The chmod command just makes the .sh files executable.

**Quick note on setup.sh and build.sh:**

• The setup.sh script automates the process of synchronizing .mlx files to the ghpages branch of the cobratoolbox GitHub repository. It requires three inputs: the repository identifier in owner/name format, a token for authentication, and the file path of the .mlx files to be synchronized. Upon execution, the script clones the cobratoolbox repository, configures git for automated operations, and targets aspecific directory within stable/tutorials/ to update. It clears this directory and copies the new .mlx files into it, ensuring that any changes are committed and pushed. This operation keeps the gh-pages branch of the cobratoolbox repository consistently updated with the latest .mlx files for documentation or tutorials.

• The build.sh script is designed for converting .mlx files to .html format and synchronizing them with the gh-pages branch of the cobratoolbox repository,. It takes three arguments: the repository identifier, a token for authentication, and the path of the .mlx file to be converted. Initially, the script converts the .mlx file to .html using MATLAB commands, assuming MATLAB is installed and accessible in the PATH. It then clones the target repository, sets up git with predefined user details, and switches to the gh-pages branch. The script creates a target directory within stable/tutorials/, copies the converted .html file into this directory, and finalizes by committing and pushing the changes.

• Both files can be found on the tutorial’s repository. Here are the links to [setup.sh](https://github.com/opencobra/COBRA.tutorials/blob/master/setup.sh) and [build.sh](https://github.com/opencobra/COBRA.tutorials/blob/master/build.sh)

![image](https://github.com/opencobra/cobratoolbox/assets/68754265/b9a748df-c94c-45bb-bedd-1d84482ea14a)


Here is the code to run the setup.sh and build.sh. We loop through all the .mlx files that were pushed. If it is the first file we are looking at we also run setup.sh to create the folder locations in the cobratoolbox – ghpages branch repository. Then afterwards build,sh is ran to convert the file to html and push to the created folder location

### Configuring the King Server

Go to this page of the repo to create a new self-hosted runner:

![image](https://github.com/opencobra/cobratoolbox/assets/68754265/05535af0-9ccf-4c38-9e79-512f738cc0f0)


By pressing the green new runner button, you are given easy instructions on how to set it up. You should have access to a terminal on King for this. To run the self-hosted runner nagivate to the folder you created it in and run ./run.sh to run the self-hosted runner.

You also need to make sure you have Matlab downloaded and working on the king server also. In the ‘[build.sh](https://github.com/opencobra/COBRA.tutorials/blob/master/build.sh)’ file the location of matlab is currently in my directory but you can add Matlab to another location and change the link to the location in the build.sh file.

### Part 2: The html files then get pushed to the gh=pages branch
In a similar fashion to the first step a .yml file is in the .github/workflows folder of the ghpages branch on the main cobratoolbox repository. The .yml file is called ‘[main.yml](https://github.com/opencobra/cobratoolbox/blob/gh-pages/.github/workflows/main.yml)’ and is trigger when a html file is pushed to the gh-pages branch of the repository. 

The main.yml can be explained as follows:

![image](https://github.com/opencobra/cobratoolbox/assets/68754265/36885564-4f94-4615-a85e-5e2acb388e25)


This specifies that the .yml file will run if a .html file is pushed to the gh-pages branch.

![image](https://github.com/opencobra/cobratoolbox/assets/68754265/c9ebbeec-1699-40ce-88bd-97005fd7f39b)

Here the second step is to checkout the repository and find any changes that were made. Also note that we are now running on ‘ubuntu-latest’ and not ‘self-hosted’ as there is no need to use King for this part.

![image](https://github.com/opencobra/cobratoolbox/assets/68754265/9005eef6-820c-4e61-96b1-e450296b122d)


In the tutorials repo we push to the gh-pages branch with the particular comment: ‘Sync files from source repo’. This helps distinguish between slight edits made to pages on the website and tutorial pushes from the tutorials repo. Here this piece of code checks this.

![image](https://github.com/opencobra/cobratoolbox/assets/68754265/e7b7338c-87e3-4f34-83a7-57b2cbe8b0a0)


Here are some basic steps such as 1. Set up python got github actions 2. Install Python dependencies needed 3. Get the html files that were pushed to the repository.

![image](https://github.com/opencobra/cobratoolbox/assets/68754265/b0a063ed-5172-42a5-83de-47f3cb5d1ae1)


Now we run the python file to configure the website to adjust to the added tutorial.

![image](https://github.com/opencobra/cobratoolbox/assets/68754265/5eeda5b7-e8d3-4bb8-9ae6-79676ddfbf4a)

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
