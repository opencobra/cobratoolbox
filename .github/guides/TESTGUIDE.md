# Guide for writing a test

## Test template

A test template is readily available [here](). The following sections shall be included in a test file.

#### 1. Header
````Matlab
% The COBRAToolbox: <testNameOfSrcFile>.m
%
% Purpose:
%     - <provide a short description of the purpose of the test
%
% Authors:
%     - <major change>: <your name> <date>
%
````

#### 2. Solver paths

````Matlab
% define global paths
global path_TOMLAB
global path_ILOG_CPLEX
global path_GUROBI
````
*Note: `glpk` does not need to have an explicit path.*

#### 3. Test initialization

````Matlab
% save the current path
currentDir = pwd;

% initialize the test
initTest(fileparts(which(mfilename)));
````

#### 4. Define the solver packages to be tested and the tolerance

```Matlab
% set the tolerance
tol = 1e-8;

% define the solver packages to be used to run this test
solverPkgs = {'tomlab_cplex', 'glpk', 'gurobi6'};
```

#### 5. Load the model and reference data

```Matlab
% load the model
load('modelFile.mat', 'model');
load('testData_functionToBeTested.mat');
```

Please only load *small* models, i.e. less than `100` reactions.

#### 6. Create a parallel pool

This is only necessary for tests that test a function that runs in parallel.

```Matlab
% create a parallel pool
poolobj = gcp('nocreate'); % if no pool, do not create new one.
if isempty(poolobj)
    parpool(2); % launch 2 workers
end
```
Please only launch a pool of 2 workers - more workers should not be needed to test efficiently.

#### 7. Body of test

Loop through the solver packages

````Matlab
for k = 1:length(solverPkgs)
    fprintf(' -- Running <testFile> using the solver interface: %s ... ', solverPkgs{k});

    % add the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        addpath(genpath(path_TOMLAB));
    elseif strcmp(solverPkgs{k}, 'gurobi6')
        addpath(genpath(path_GUROBI));
    end

    solverLPOK = changeCobraSolver(solverPkgs{k});

    if solverLPOK
        % <your test goes here>
    end

    % remove the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        rmpath(genpath(path_TOMLAB));
    elseif strcmp(solverPkgs{k}, 'gurobi6')
        rmpath(genpath(path_GUROBI));
    end

    % output a success message
    fprintf('Done.\n');
end    
````

#### 8. Change to the current directory

````Matlab
% change the directory
cd(currentDir)
````

## Run the test locally on your machine

Please make sure that your test runs individually by typing after a fresh start:
````Matlab
>> initCobraToolbox
>> <testName>
````

Please then verify that the test runs in the test suite by running:
````Matlab
>> testAll
````

Alternatively, you can run the test suite in the background by typing:
````sh
$ matlab -nodesktop -nosplash < test/testAll.m
````
