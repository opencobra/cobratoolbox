# Cobratoolbox Website Documentation

This website is hosted on the GitHub servers using gh-pages. Here at the gh-pages branch is the source code of the website. If changes are made here, changes are made to the website. If you are interested to learn more about how gh-pages works check out the documentation for more information: https://docs.github.com/en/pages. 

The following sections describe how continuous integration of tutorials, modules, and contributors work in gh-pages.


## Continuous Integration of Tutorials:
**Part 1** of the CI occurs when a contributor pushes their tutorial .mlx file to the Tutorials Repository. In this part the .mlx file is also converted into a .html, .pdf and .m file. Detailed Documentation for the first part is ‘[here](https://github.com/opencobra/COBRA.tutorials/tree/master/.github/workflows)’. At the end of the first step, the .HTML file(s) of the new tutorial(s) is/are pushed to gh-pages branch at stable/tutorials/<folder of the tutorial> with the commit message being "Sync files from source repo".

### Part 2: The html files then converted to required format and the index.html file is updated
A workflow is then set up to be trigged when a .html file is pushed to the gh-pages branch. The .yml file is called ‘[UpdateTutorialIndex.yml](https://github.com/opencobra/cobratoolbox/blob/gh-pages/.github/workflows/UpdateTutorialIndex.yml)’.

The UpdateTutorialIndex.yml can be explained as follows:

```
on:
  push:
    branches: gh-pages
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
          ref: gh-pages
```

Here the second step is to checkout the repository and find any changes that were made. Also note that we are now running on ‘ubuntu-latest’ and not ‘self-hosted’ as there is no need to use King for this part. Also, we are cloning only the gh-pages branch

```
- name: Check Commit Message
  id: check_msg
  run: |
    commit_msg=$(git log --format=%B -n 1)
    if [[ "$commit_msg" == "Sync files from source repo" ]]; then
      echo "run_job=true" >> $GITHUB_OUTPUT
    else
      echo "run_job=false" >> $GITHUB_OUTPUT
    fi
```

The commit message: ‘Sync files from source repo’ helps to distinguish between slight edits made to pages on the website and tutorial pushes from the COBRA.tutorials repo. The variable, run_job is created based on the commit message that helps in deciding whether to proceed or not.

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
```

Here are some basic steps such as 1. Set up python 2. Install Python dependencies needed. Only beautifulsoup4 is installed which helps in modifying the stable/tutorials/index.html file.

```
- name: Get Changed HTML Files and update the index.html file of tutorial
  id: getfile
  if: steps.check_msg.outputs.run_job == 'true'
  run: |
    changed_files=$(git diff --name-only HEAD~1 HEAD | grep '\.html' | tr '\n' ' ')
    for file in $changed_files; do
        echo "Processing: $file"
        python ./stable/extract_info.py $file
    done
```


Now we run the python file, ./stable/extract_info.py to configure the website to adjust to the added tutorial.

```
- name: Commit and Push New File
  if: steps.check_msg.outputs.run_job == 'true'
  run: |
    git config user.name "github-actions[bot]"
    git config user.email "github-actions[bot]@users.noreply.github.com"
    git add .
    git commit -m "Update Tutorial (Automatic Workflow)" || echo "No changes to commit"
    git push
```

After changing and adding the folders/files in the repo we push the changes to the remote repository

**What is extract_info.py?**
This Python script processes the HTML file to extract its heading and then uses this information to update the website's [tutorial homepage](https://opencobra.github.io/cobratoolbox/stable/tutorials/index.html). Initially, it reads the specified HTML file to find the main heading (inside an h1 tag). Then, it modifies a template HTML file (HOLDER_TEMPLATE.html) by replacing a placeholder with the path of the processed file, and saves this modified content as a new tutorial file within a predefined directory structure (stable/tutorials). Additionally, the script updates the index.html file located within the same stable/tutorials directory, adding a link to the new tutorial under a specific section, which is determined by part of the original file's path.


## Continuous Integration of Modules:
The modules and citations webpages get updated for new pushes to the master branch. Each push to the master branch triggers [Update function docs workflow](https://github.com/opencobra/cobratoolbox/blob/master/.github/workflows/UpdateFunctionDocs.yml). Both modules pages and citation page work using the documentation tool [sphinx](https://www.sphinx-doc.org/en/master/). Detailed description of the workflow is given below:

```
on:
  push:
    branches:
      - master
```
- This workflow gets triggered only when a new push is made to the master branch of the cobratoolbox repo.


```
jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
      - name: Set up Python 3.10
        uses: actions/setup-python@v3
        with:
          python-version: '3.10'
```
- This workflow is set to run on the github-hosted server and it begins by checkout the repository and installing python version 3.10.

```
- name: Install dependencies
  working-directory: ./documentation
  run: |
    pip install -r requirements.txt
```
- Next step is to install the required [libraries](https://github.com/opencobra/cobratoolbox/blob/master/documentation/requirements.txt) for the automated generation of function docs and the citations page.

 ```
- name: Generate publications rst file
  working-directory: ./documentation/source/sphinxext
  run: |
    python GenerateCitationsRST.py
```
- This step in particular is to generate .rst file that is required in further steps to generate the [citations webpage](https://opencobra.github.io/cobratoolbox/stable/citations.html).
**What is GenerateCitationsRST.py**
  This python file generates the required .rst file that generates the webpage, citations.html. It begins with the year 2006 (from the initial publication that cited cobratoolbox) to the present year. Further the citations follow the style, ModStyle defined in [CitationStyle.py file](https://github.com/opencobra/cobratoolbox/blob/master/documentation/source/sphinxext/CitationStyle.py).

 ```
- name: Update packages
  working-directory: ./documentation/source
  run: |
    python ./sphinxext/copy_files.py
 ```
- For the tab style shown in the current webpage of [citations.html](https://opencobra.github.io/cobratoolbox/stable/citations.html), [tab.css](https://github.com/opencobra/cobratoolbox/blob/master/documentation/source/sphinxext/tabs.css) file is required.
- For appending each of the function docs with the github link, [linkcode.py](https://github.com/opencobra/cobratoolbox/blob/master/documentation/source/sphinxext/linkcode.py) file is required. Note that sphinx extensions have by default a linkcode.py file, but that does not work well for the matlab files (.m).
- The above two files, are used despite of default style file (tab.css) and the linkcode file. [copy_files.py](https://github.com/opencobra/cobratoolbox/blob/master/documentation/source/sphinxext/copy_files.py) file replaces these two files.

```
- name: Generate functions rst files
  working-directory: ./documentation/source/modules
  run: |
    python ./GetRSTfiles.py
```
- Website design using sphinx requires the .rst files to be predefined. These .rst files will further be used to create the .html files for the webpage.
- [GetRSTfiles.py](https://github.com/opencobra/cobratoolbox/blob/master/documentation/source/modules/GetRSTfiles.py) automates the process of generating the .rst files.
  
**What is GetRSTfiles.py?**
  For each of the sections in [src](https://github.com/opencobra/cobratoolbox/tree/master/src), all the subfolders are iterated and a separate .rst file is generated for each subfolder. These .rst files carry the information on the contents of the modules page.

```
- name: Generate documentation
  working-directory: ./documentation
  run: |
    make HTML
```
- This creates the .HTML files required for the webpage using the .rst files obtained in previous steps.
- This requires [conf.py](https://github.com/opencobra/cobratoolbox/blob/master/documentation/source/conf.py) that has the details of the extensions to be used, format of the function docs and other implementation details.
- Further, for citations page, [COBRA.bib](https://github.com/opencobra/cobratoolbox/blob/master/documentation/COBRA.bib) file is required and this needs to be manually updated. Currently the .bib file is retrieved from [web of science](https://www.webofscience.com/wos/woscc/summary/d043671b-cd33-418b-9781-a92c21471897-bec2b3ea/relevance/1(overlay:export/exbt)).

```
- name: Copy the citations html page
  run: |
    cp ./documentation/build/html/citations.html ./documentation/source/Citations/citations.html
```
- Citations html page is alone copied into a new folder. This is because deployment requires all files in a folder to be copied and hence we need a separate folder

```
- name: Deploy the function modules
  uses: JamesIves/github-pages-deploy-action@v4
  with:
    folder: ./documentation/build/html/modules
    branch: gh-pages
    target-folder: stable/modules
    commit-message: "update Function Docs (Automatic Workflow)"
```
- This is the deploying step for the modules webpages.

```
- name: Deploy the citations page
  uses: peaceiris/actions-gh-pages@v3
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    publish_dir: ./documentation/source/Citations
    publish_branch: gh-pages
    keep_files: true
    destination_dir: stable
    commit_message: "update Function Docs (Automatic Workflow)"
```
- This is the deploying step for the citations webpage

```
- name: Deploy the citations static page
  uses: peaceiris/actions-gh-pages@v3
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    publish_dir: ./documentation/build/html/_static
    publish_branch: gh-pages
    keep_files: true
    destination_dir: stable/_static
    commit_message: "update Function Docs (Automatic Workflow)"
```
- This step copies the style files required for the modules and the citations page.


## Continuous Integration of Contributors:
The [contributors webpage](https://opencobra.github.io/cobratoolbox/stable/contributors.html) is updated based on each new commits made to the repo. This workflow is triggered by the [UpdateContributors.yml](https://github.com/opencobra/cobratoolbox/blob/master/.github/workflows/UpdateContributors.yml) file. The detailed description is given below.


```
on:
  push:
    branches:
      - master
```
- This workflow gets triggered only when a new push is made to the master branch of the cobratoolbox repo.


```
jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
      - name: Set up Python 3.10
        uses: actions/setup-python@v3
        with:
          python-version: '3.10'
```
- This workflow is set to run on the github-hosted server and it begins by checkout the repository and installing python version 3.10.

```
- name: Install dependencies
  working-directory: ./documentation/source/Contributions
  run: |
    pip install -r requirements.txt
```
- Next step is to install the required [libraries](https://github.com/opencobra/cobratoolbox/blob/master/documentation/source/Contributions/requirements.txt) for the automated generation of contributors list.

```
- name: Update contributors
  working-directory: ./documentation/source/Contributions
  run: |
    python UpdateContributorsList.py
```
- In this step list of all the contributors to cobratoolbox is obtained and stored in [AllContributors.csv](https://github.com/opencobra/cobratoolbox/blob/master/documentation/source/Contributions/AllContributors.csv) file.

**What is UpdateContributorsList.py?**
This [python file](https://github.com/opencobra/cobratoolbox/blob/master/documentation/source/Contributions/UpdateContributorsList.py) generates the AllContributors.csv file. This csv file stores the following information required to generate the html page: Contributor's github username; the avatar URL of the contributor; link to the github page of the contributor; number of contributions made (count of commits); whether or not contributed in past one year.

```
- name: Generate HTML file
  working-directory: ./documentation/source/Contributions
  run: |
    python GenerateContributorsHTML.py
```
- Based on the details stored in the AllContributors.csv generated in the previous step, this step generates a .HTML page that is used in the webpage.

```
- name: Deploy to gh-pages/stable
  uses: peaceiris/actions-gh-pages@v3
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    publish_dir: ./documentation/source/Contributions/contributors
    publish_branch: gh-pages
    keep_files: true
    destination_dir: stable
    commit_message: "Update Contributors (Automatic Workflow)"
```
- The generated webpage is further deployed in this step

