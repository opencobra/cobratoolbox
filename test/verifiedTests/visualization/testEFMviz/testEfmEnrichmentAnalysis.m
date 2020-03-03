% The COBRAToolbox: testEfmEnrichmentAnalysis.m
%
% Purpose:
%     - script to test if any given set of EFMs are enriched with high/low expressed genes
%
% Authors:
%     - Created initial test script: Chaitra Sarathy 2 Dec 19
%     - Updates to header docs: Chaitra Sarathy 19 Dec 19

global CBTDIR

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


