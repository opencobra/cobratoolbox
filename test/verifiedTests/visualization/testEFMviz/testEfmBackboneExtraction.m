% The COBRAToolbox: testEfmBackboneExtraction.m
%
% Purpose:
%     - test extraction of backbone from a given set of EFMs
%
% Authors:
%     - Created initial test script: Chaitra Sarathy 2 Dec 19
%     - Updates to header docs: Chaitra Sarathy 19 Dec 19

global CBTDIR

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% determine the test path for references
testPath = pwd;

% Load reference data
load([testPath filesep 'testData_efmBackboneExtraction.mat']);

% This is a function with two required inputs:
% Case 1: Test whether efmBackboneExtraction gives the expected output when using 2 input and 2 output arguments
[selectedRxns,  rxnDistribution] = efmBackboneExtraction(testEFMRxns, percentage);
assert(isequal(selectedRxns, selectedRxns_ref));
assert(isequal(rxnDistribution,rxnDistribution_ref));

% Case 2: Test whether efmBackboneExtraction throws an error when using 1 input argument only 
assert(verifyCobraFunctionError('efmBackboneExtraction', 'inputs', {testEFMRxns}, 'outputArgCount', 1));

% Case 3: Test whether efmBackboneExtraction throws an error when using NO input arguments
assert(verifyCobraFunctionError('efmBackboneExtraction', 'inputs', {}, 'outputArgCount', 1));

