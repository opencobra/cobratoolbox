# Building COBRA Toolbox documentation
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

## Building documentation using Docker (Has not been tested for new version)

Installing unwanted versions of Python and modules can be avoided by 
building with Docker: 

Build the docker image:

```
docker build -t opencobra/cobratoolbox-docs .
```


To build the docs:


```
docker run --rm -v /var/tmp:/output opencobra/cobratoolbox-docs
```

The above command will deposit the built HTML documentation  
in /var/tmp/cobratoolbox_doc_timestamp.tar.gz 
You can specify an alternative directory by changing the location of
the /output mountpoint in the docker run command.

## Building COBRA.tutorials (Has not been tested for new version)

Check that wkhtmltopdf is installed
which wkhtmltopdf
If not, install with:
sudo apt-get update
sudo apt-get install xvfb libfontconfig wkhtmltopdf

Check that imagemagick is installed
which convert
If not, install with:
sudo apt-get update
sudo apt install imagemagick

Clone the cobratoolbox and COBRA.tutorials repository in an empty directory. Then cd to 
./cobratoolbox/docs directory and create and run the following script:

```
MATLAB_ROOT=/usr/local/MATLAB
MATLAB_VERSION=R2020b
OUTPUT=/var/tmp/COBRA.tutorials_output
./prepareTutorials.sh  \
	-p=${OUTPUT} \
	-t=../../COBRA.tutorials \
	-c=../../cobratoolbox \
	-e=${MATLAB_ROOT}/${MATLAB_VERSION}/bin/matlab \
	-m=html

```

Replace MATLAB_ROOT with the location of the matlab if different to 
/usr/local, and OUTPUT with the location to which the tutorial HTML files
are to be written.

Remark: This procedure has been tested with head of cobratoolbox develop branch
(e8c40f3e74de9f2d671b58dd918305697ffd64b9) and
head of COBRA.tutorials master branch (0761e66374b0eff81db0f9adde87e118a12e967e)
on 2021-06-16 running on Ubuntu 18.04 with MATLAB R2020b

Remark: the dependency on matlab for this step makes it difficult to dockerize
due to the need for matlab licence files.


## Adding Google Analytics tracking code to the template

Tracking code can be added to the template by editing layout.html or footer.html
in https://github.com/opencobra/sphinx_cobra_theme/tree/develop/sphinx_cobra_theme/

The tracking code is located near the end of the page.

```
 <!-- Global site tag (gtag.js) - Google Analytics -->
  <script async src="https://www.googletagmanager.com/gtag/js?id=G-TRCMZL1FKK"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', 'G-TRCMZL1FKK');
  </script>
```

## Remarks about sphinx_cobra_theme

The project logo (top-left) is hardcoded in layout.html at approx line 127. A comment in the code indicates this was done
to expedite configuration issues earlier in the project. Ideally the template should be reuseable (without modification)
for all the opencobra sub-projects: so need to find a way to externally configure the project logo.

## Checking for broken links

Install 'linkchecker' utility:

```
sudo apt install linkchecker
```

Execute link check scan with the following command:

```
linkchecker https://opencobra.github.io/cobratoolbox/stable/
```

