# condalab

Handy MATLAB utility to switch between conda environments **from within MATLAB**

## Installation

1. Grab this repo. Chuck it somewhere on your path.
2. Determine where your base `conda` installation by opening a terminal and typing `which conda`. Make a note of that path. 
3. Type `conda.init` in your MATLAB terminal. It should prompt you for the path you got in step 2. 


## Usage

`condalab` works exactly like `conda`. 

So if you want to list the environments you have, you can use


```
% yes, type this in your matlab prompt
conda env list 

base     /Users/srinivas/anaconda3
*umap     /Users/srinivas/anaconda3/envs/umap

```

and the `*` indicates the currently active environment. 

To switch environments, use 

```
% yes, type this in your matlab prompt
conda activate umap
```

To check that everything worked, you can run

```
conda.test

The python executable I am using is located at:
/Users/srinivas/anaconda3/envs/umap/bin/python
```

and you see that it is using the right environment. 


It's that simple. Enjoy. 
