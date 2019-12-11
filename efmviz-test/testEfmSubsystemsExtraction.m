% The COBRAToolbox: <testNameOfSrcFile>.m
%
% Purpose:
%     - <provide a short description of the purpose of the test
%
% Authors:
%     - <major change>: <your name> <date>
%

global CBTDIR

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% determine the test path for references
testPath = pwd;

% set the tolerance
% tol = 1e-8;

% Load reference data
load([testPath filesep 'testData_testEfmSubsystemsExtraction.mat']);

% This is a function with two required inputs:
% Case 1: Test whether efmFilter gives the expected output when using 2 input and 2 output arguments
[subsysSummary, uniqSubsys, countSubPerEFM] = efmSubsystemsExtraction(model, testEFMs);
assert(isequal(subsysSummary, subsysSummary_ref));
assert(isequal(uniqSubsys,uniqSubsys_ref));
assert(isequal(countSubPerEFM,countSubPerEFM_ref));

% Case 2: Test whether efmFilter throws an error when using 1 input argument only 
assert(verifyCobraFunctionError('efmSubsystemsExtraction', 'inputs', {testEFMs}, 'outputArgCount', 1));

% Case 3: Test whether efmFilter throws an error when using 1 input argument only 
assert(verifyCobraFunctionError('efmSubsystemsExtraction', 'inputs', {model}, 'outputArgCount', 1));

% Case 4: Test whether efmFilter throws an error when using NO input arguments
assert(verifyCobraFunctionError('efmSubsystemsExtraction', 'inputs', {}, 'outputArgCount', 1));

