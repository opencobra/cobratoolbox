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

% load the model
model = readCbModel('testModel.mat','modelName','model_irr'); %For all models which are part of this particular test.

% Load reference data
load([testPath filesep 'testData_efmImport.mat']);

efmFileName = 'testEFMs.txt';
fluxFileName = 'testFluxes.txt';

% This is a function with two required and two optional inputs:
% Case 1: Test whether efmImport gives the expected output when using 2 input and 1 output argument
[EFMRxns_case1] = efmImport([testPath filesep], efmFileName);
assert(isequal(EFMRxns_case1,EFMRxns_ref));

% Case 2:  Test whether efmImport gives an error when using  2 input and 2 output arguments
% [EFMRxns_case2, EFMFluxes_case2] = efmImport([testPath filesep], efmFileName);
assert(verifyCobraFunctionError('efmImport', 'inputs', {[testPath filesep], efmFileName}, 'outputArgCount', 2));

% Case 3: Test whether efmImport gives the expected output when with all the 4 input and 2 output arguments
[EFMRxns_case4, EFMFluxes_case4] = efmImport([testPath filesep], efmFileName, [testPath filesep], fluxFileName);
assert(isequal(EFMRxns_case4, EFMRxns_ref));
assert(isequal(EFMFluxes_case4,EFMFluxes_ref));

