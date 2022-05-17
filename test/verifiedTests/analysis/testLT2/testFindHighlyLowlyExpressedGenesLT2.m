% The COBRAToolbox: findHighlyLowlyExpressedGenesGT1.m
%
% Purpose:
%     - For testing the IgemRNA non-optimization option task for
%     determining gene expression level based on transcriptomics data and
%     parameters for thresholding approach LT1 (Local)
%
% Authors:
%     - Created: 07/01/2022
%     - COBRAToolbox style applied: 05/05/2022
%

global CBTDIR

% define the required solvers
requiredSolvers = {'needsLP', 'matlab'};

% check if the specified requirements are fullfilled
solvers = prepareTest('needsLP',true);

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% determine the test path for references
testPath = pwd;

% set the tolerance
tol = 1e-8;

% Set function params
lowerThreshold = 0;
upperThreshold = 50;
trDataPath = 'testData_transcriptomics.xlsx';
sheetIndex = 4;

for k = 1:length(solvers.LP)
    fprintf(' -- Running testfindHighlyLowlyExpressedGenesLT1.m using the solver interface: %s ... ', solvers.LP{k});
    
    solverLPOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);

    if solverLPOK
       genes = findHighlyLowlyExpressedGenesLT2(lowerThreshold, upperThreshold, trDataPath, sheetIndex);
      
       assert(~isempty(genes))
       
       % output a success message
       fprintf('Done.\n');
    end
end

% change the directory
cd(currentDir)