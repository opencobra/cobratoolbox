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

## Checking for broken links

Install 'linkchecker' utility:

```
sudo apt install linkchecker
```

Execute link check scan with the following command:

```
linkchecker https://opencobra.github.io/cobratoolbox/stable/
```

