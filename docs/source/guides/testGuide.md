# Guide for writing a test

Before starting to write a test on your own, it might be instructive to follow common test practices in `/test/verifiedTests`. A style guide on how to write tests is given [here](https://opencobra.github.io/cobratoolbox/docs/styleGuide.html).

## Test if an output is correct

If you want to test if the output of a function `[output1, output2] = function1(input1, input2)` is correct, you should call this function at least 4 times in your test. The argument `ìnput2` might be an optional input argument.
````Matlab
% Case 1: test with 1 input and 1 output argument
output1 = function1(input1)

% Case 2: test with 1 input and 2 output arguments
[output1, output2] = function1(input1)

% Case 3: test with 1 output and 2 input arguments
output1 = function1(input1, input2)

% Case 4: test with 2 input and 2 output arguments
[output1, output2] = function1(input1, input2)
````

Each of the 4 test scenarios should be followed by a test on `output1` and `output2`. For instance, for `Case 4`:
````Matlab
% Case 4: test with 2 input and 2 output arguments
[output1, output2] = function1(input1, input2)

% test on output1
assert(output1 < tol); % tol must be defined previously, e.g. tol = 1e-6;

% test on output2
assert(abs(output2 - refData_output2) < tol); % refData_output2 can be loaded from a file
````
The test succeeds if the argument of `assert()` yields a `true` logical condition.

## Test if a function throws an error or warning message

If you want to test whether your `function1` correctly throws an **error** message, you can test as follows:
````Matlab
% Case 5: test with 2 input and 1 output arguments (2nd input argument is of wrong dimension)
try
    output1 = function1(input1, input2');
catch ME
    assert(length(ME.message) > 0)
end
````

If you want to test whether your `function1` correctly throws a **warning** message, you can test as follows:
````Matlab
warning('off', 'all')
    output1 = function1(input1, input2');
    assert(length(lastwarn()) > 0)
warning('on', 'all')
````
Note that this allows the error message to be thrown without failing the test.

## Test template

A test template is readily available [here](https://opencobra.github.io/cobratoolbox/docs/testTemplate.html). The following sections shall be included in a test file:

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

#### 2. Test initialization

````Matlab
global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which('fileName')));
````

#### 3. Define the solver packages to be tested and the tolerance

```Matlab
% set the tolerance
tol = 1e-8;

% define the solver packages to be used to run this test
solverPkgs = {'tomlab_cplex', 'glpk', 'gurobi6'};
```

#### 4. Load a model and/or reference data

```Matlab
% load the model
load([CBTDIR filesep 'test' filesep 'models' filesep 'testModel.mat'], 'model');
load('testData_functionToBeTested.mat');
```

Please only load *small* models, i.e. less than `100` reactions. If you want to use a non-standard test model that is already available online, please make a pull request with the URL entry to the [COBRA.models repository](https://github.com/cobrabot/COBRA.models).

:warning: In order to guarantee compatibility across platforms, please use the full path to the model. For instance:
```Matlab
global CBTDIR

% load the ecoli core model
load([CBTDIR filesep 'test' filesep 'models' filesep 'ecoli_core_model.mat'], 'model');
```

#### 5. Create a parallel pool

This is only necessary for tests that test a function that runs in parallel.

```Matlab
% create a parallel pool
poolobj = gcp('nocreate'); % if no pool, do not create new one.
if isempty(poolobj)
    parpool(2); % launch 2 workers
end
```
:warning: Please only launch a pool of `2` workers - more workers should not be needed to test a parallel function efficiently.

#### 6. Body of test

Loop through the solver packages

````Matlab
for k = 1:length(solverPkgs)
    fprintf(' -- Running <testFile> using the solver interface: %s ... ', solverPkgs{k});

    solverLPOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverLPOK
        % <your test goes here>
    end

    % output a success message
    fprintf('Done.\n');
end    
````

#### 7. Change to the current directory

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

## Verify that your test passed

Once your pull request (PR) has been submitted, you will notice an orange mark next to your latest commit. Once the continuous integration (CI) server succeeded, you will see a green check mark. If the CI failed, you will see a red cross.

## What should I do in case my PR failed?

You can check why your PR failed by clicking on the mark and following the respective links. Alternatively, you can see the output of the CI for your PR [here](https://prince.lcsb.uni.lu/jenkins/job/COBRAToolbox-pr-auto/). You can then click on the build number. Under `Console Output`, you can see the output of `test/testAll.m` with your integrated PR.

Once you understood why the build for your proposed PR failed, you can add more commits that aim at fixing the error, and the CI will be re-triggered.

Common errors include:

- Double percentage sign `%%` in your test file to separate code blocks. Replace `%%` with `%`.
- Compatibility issues (`ILOG Cplex` is not compatible with `R2015b+`). Add an additional test on the version of matlab using `verLessThan('matlab', '<version>')`.

## Can I find out how many tests have failed?

The logical conditions, when tested using `assert()`, will throw an error when not satisfied. It is bad practice to test the sum of tests passed and failed. Please only test using `assert(logicalCondition)`. Even though a test may fail using `assert()`, a summary table with comprehensive information is provided at the end of the test run.

For instance, the following test script **do not do this - bad practice!**:
````Matlab
% do not do this: bad practice!
testPassed = 0;
testFailed = 0;

% test on logical condition 1 - do not do this: bad practice!
if logicalCondition1
    testPassed = testPassed + 1;
else
    testFailed = testFailed + 1;
end

% test on logical condition 2 - do not do this: bad practice!
if logicalCondition2
    testPassed = testPassed + 1;
else
    testFailed = testFailed + 1;
end

assert(testPassed == 2 && testFailed == 0); % do not do this: bad practice!
````
shall be rewritten as follows:
````Matlab
% good practice
assert(logicalCondition1);
assert(logicalCondition2);
````
