% The COBRAToolbox: testEfmFilter.m
%
% Purpose:
%     - test if a given set of EFMs can be filtered to contain a reaction of interest
%
% Authors:
%     - Created initial test script: Chaitra Sarathy 2 Dec 19
%     - Updates to header docs: Chaitra Sarathy 19 Dec 19

global CBTDIR

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
