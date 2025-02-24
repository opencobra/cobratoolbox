% The COBRAToolbox: createContextSpecificModel.m
%
% Purpose:
%     - For testing the IgemRNA model generation by integrating gene
%     expression and medium data
%
% Authors:
%     - Created: 13/04/2021
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
modelPath = 'testData_modelYeast.xls';
trDataPath = 'testData_transcriptomics.xlsx';
mediumDataPath = 'testData_mediumData.xlsx';
growthNotAffectingGeneDel = 0;
meetMinimumReq = 0;
thApproach = 3;
lowerTh = 2;
upperTh = 25;
objective = 'r_2111';
gmAndOperation = 'MIN';
gmOrOperation = 'MAX';
constrAll = 0;
excludeBiomassEq = 0;
biomassId = 'r_4041';
percentile = 0;

for k = 1:length(solvers.LP)
    solverLPOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);

    if solverLPOK
       model = createContextSpecificModel(modelPath, trDataPath, mediumDataPath, growthNotAffectingGeneDel, meetMinimumReq, thApproach, lowerTh, upperTh, objective, gmAndOperation, gmOrOperation, constrAll, excludeBiomassEq, biomassId, percentile);

       fprintf(' -- Running testModelCreation.m using the solver interface: %s ... ', solvers.LP{k});

       assert(numel(dir('resultsPostOptimization/contextSpecificModels')) > 2)
       
       % output a success message
       fprintf('Done.\n');
    end
end

% change the directory
cd(currentDir)