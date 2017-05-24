Frequently Asked Questions (FAQ)
--------------------------------

## Github

**What do all these labels mean?**

A comprehensive list of labels and their description for the issues and pull requests is given [here](https://opencobra.github.io/cobratoolbox/docs/labels.html).

## Reconstruction

What does `DM_reaction` stand for after running `biomassPrecursorCheck(model)`?

**Answer**: `DM_ reactions` are commonly demand reactions.

## Submodules

When running `git submodule update`, the following error message appears:

```bash
No submodule mapping found in .gitmodules for path 'external/lusolMex64bit'
```

**Solution**: remove the cached version of the respective submodule
```bash
git rm --cached external/lusolMex64bit
```

**Note**: The submodule throwing an error might be different than `external/lusolMex64bit`, but the command should work with any submodule.

## Parallel programming

When running cobra code in a parfor loop, solvers (and other global variables) are not properly set.  

**Answer**: This is an issue with global variables and the matlab parallel computing toolbox.
Global variables are not passed on to the workers of a parallel pool.  
To change cobra global settings for a parfor loop, it is necessary to
reinitialize the global variables on each worker. The easiest way to do this is as follows:
```Matlab
global CBT_SOLVER_LP
solver = CBT_SOLVER_LP
parfor 1:2
    changeCobraSolver(solver,'LP');
    %additional code in the parfor loop will now use the currently set solver
    optimizeCbModel(model);
end
```
By requesting the current global variable before the parfor loop and assigning it to a local variable, that variable is passed on to the workers,
which can then use it to set up the correct solver (or other variable).
