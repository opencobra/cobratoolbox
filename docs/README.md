# Building cobtratoolbox documentation

This procedure has been tested on Ubuntu 18.04. The documentation build
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

