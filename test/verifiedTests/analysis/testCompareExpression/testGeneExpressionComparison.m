% The COBRAToolbox: findUpDownRegulatedGenes.m
%
% Purpose:
%     - For testing the IgemRNA non-optimization task called "Find
%     up/down-regulated genes" which performs gene expression value
%     comparison between different phenotypes or datasets.
%
% Authors:
%     - Kristina Grausa 05/16/2022 - created 
%     - Kristina Grausa 08/22/2022 - standard header and formatting
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
sourceDataSet = 'SRR8994357_WT';
targetDataSet = 'SRR8994378_S47D';
trFilePath = 'testData_transcriptomics.xlsx';

for k = 1:length(solvers.LP)
    solverLPOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);

    if solverLPOK
       result = findUpDownRegulatedGenes(sourceDataSet, targetDataSet, trFilePath);
       
       fprintf(' -- Running testGeneExpressionComparison.m using the solver interface: %s ... ', solvers.LP{k});
       
       assert(~isempty(result))
       
       % output a success message
       fprintf('Done.\n');
    end
end

% change the directory
cd(currentDir)
