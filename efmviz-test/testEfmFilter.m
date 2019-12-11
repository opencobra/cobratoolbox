% The COBRAToolbox: <testNameOfSrcFile>.m
%
% Purpose:
%     - <provide a short description of the purpose of the test
%
% Authors:
%     - <major change>: <your name> <date>
%

global CBTDIR

% define the features required to run the test
% requiredToolboxes = { 'bioinformatics_toolbox', 'optimization_toolbox' };

% requiredSolvers = { 'dqqMinos', 'matlab' };

% require the specified toolboxes and solvers, along with a UNIX OS
% solversPkgs = prepareTest('reqSolvers', requiredSolvers, 'requiredToolboxes', requiredToolboxes, 'needUnix', true);

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% determine the test path for references
testPath = pwd;

% load the model
model = readCbModel('testModel.mat','modelName','model_irr'); %For all models which are part of this particular test.

% Load reference data
load([testPath filesep 'testData_efmFilter.mat']);

% This is a function with two required inputs:
% Case 1: Test whether efmFilter gives the expected output when using 2 input and 2 output arguments
[filteredEFMs, filteredRows] = efmFilter(testEFMRxns, roi); 
assert(isequal(filteredEFMs,filteredEFMs_ref));
assert(isequal(filteredRows,filteredRows_ref));

% Case 2: Test whether efmFilter throws an error when using 1 input argument only 
assert(verifyCobraFunctionError('efmFilter', 'inputs', {testEFMRxns}, 'outputArgCount', 1));

% Case 3: Test whether efmFilter throws an error when using NO input arguments
assert(verifyCobraFunctionError('efmFilter', 'inputs', {}));
