# Building COBRA Toolbox documentation

This procedure has been tested on Ubuntu 20.04. The documentation build
uses Python 2.

```
sudo apt update
sudo apt install -y python-pip
```

The from the cobratoolbox/docs directory:

```
pip install -r requirements.txt
```

To build the documentation:

```
make html
```

Output HTML documentation will be in directory ./build/html


## Building documenation using Docker

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

## Building COBRA.tutorials

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

## Publishing the HTML to live site

To publish the updated documentation on the cobratoolbox website at
https://opencobra.github.io/cobratoolbox/stable/
checkout the gh-pages branch of the https://github.com/opencobra/cobratoolbox.git repository
and replace the ./stable or ./latest directory with the build output.

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

