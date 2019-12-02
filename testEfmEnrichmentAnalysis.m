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

% set the tolerance
% tol = 1e-8;

% load the model
model = readCbModel('testModel.mat','modelName','model_irr'); %For all models which are part of this particular test.

%Load reference data
% load([testPath filesep 'testData_functionToBeTested.mat']);

efmFileName = 'testEFMs.txt';
fluxFileName = 'testFluxes.txt';

[EFMRxns_efmOnly] = efmImport([testPath filesep], efmFileName);
assert(isequal(EFMRxns_efmOnly,[1,2,3,4,5; 2,3,6,0,0]));

                                                                                                       
[EFMRxns, EFMFluxes] = efmImport([testPath filesep], efmFileName, [testPath filesep], fluxFileName);
assert(isequal(EFMRxns,[1,2,3,4,5; 2,3,6,0,0]));
assert(isequal(EFMFluxes,[1,1,1,1,1,0; 0,1,1,0,0,1]));


