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

To publish the updated documentation on the cobratoolbox website at 
https://opencobra.github.io/cobratoolbox/stable/
checkout the gh-pages branch of the https://github.com/opencobra/cobratoolbox.git repository
and replace the ./stable or ./latest directory with the build output.


== Building documenation using Docker

Installing unwanted versions of Python and modules can be avoided by using a 
Docker container.

Build the docker image:

```
docker build -t opencobra/cobratoolbox-docs .
```


To build the docs:

(TODO)

```
docker run --rm opencobra/cobratoolbox-docs
```


