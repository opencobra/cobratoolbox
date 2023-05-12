% The COBRAToolbox: calculateMinimumRequirements.m
%
% Purpose:
%     - For testing the IgemRNA post-optimization functionality of deleting
%     lowly expressed genes from the model
%
% Authors:
%     - Kristina Grausa 05/16/2022 - created 
%     - Kristina Grausa 08/22/2022 - standard header and formatting
%

global CBTDIR

% define the required solvers
requiredSolvers = {'needsLP', 'matlab'};

% check if the specified requirements are fullfilled
solvers = prepareTest('needsLP',true, 'needsUnix', false);

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% determine the test path for references
testPath = pwd;

% set the tolerance
tol = 1e-8;

% load the model
model = readCbModel('testData_modelYeast.xls','modelName','model'); 

% load reference data
trData=readtable('testData_transcriptomics.xlsx','Sheet','SRR8994357_WT');

% Set function params
trDataPath = 'testData_transcriptomics.xlsx';
thApproach = 3;
lowerTh = 0;
upperTh = 30;
sheetIndex = 1;
growthNotAffectingGeneDel = 0;
percentile = 0;

for k = 1:length(solvers.LP)
    fprintf(' -- Running testInactiveGeneDeletion.m using the solver interface: %s ... ', solvers.LP{k});

    solverLPOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);

    if solverLPOK
       resultModel = deleteInactiveGenes(model, trData, trDataPath, thApproach, lowerTh, upperTh, sheetIndex, growthNotAffectingGeneDel, percentile);
       
       genes = resultModel.genes;
       
       deletedGeneIndices = find(contains(genes,'_deleted'));
       
       assert(~isempty(deletedGeneIndices))
       
       % output a success message
       fprintf('Done.\n');
    end
end

% change the directory
cd(currentDir)

