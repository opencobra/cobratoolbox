% The COBRAToolbox: calculateMinimumRequirements.m
%
% Purpose:
%     - For testing the IgemRNA post-optimization option for generating a
%     model representing the minimum flux requirements to satisfy the steady
%     state.
%
% Authors:
%     - Created: 03/01/2022
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

% load reference data
trData=readtable('testData_transcriptomics.xlsx','Sheet','SRR8994357_WT');

% Set function params
modelPath = 'testData_modelYeast.xls';
trDataPath = 'testData_transcriptomics.xlsx';
mediumDataPath = 'testData_mediumData.xlsx';
growthNotAffectingGeneDel = 0;
thApproach = 3;
lowerTh = 5;
upperTh = 50;
objective = 'r_2111';
percentile = 0;

for k = 1:length(solvers.LP)
    solverLPOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);

    if solverLPOK
       calculateMinimumRequirements(modelPath, trDataPath, mediumDataPath, growthNotAffectingGeneDel, thApproach, lowerTh, upperTh, objective, percentile);
       
       fprintf(' -- Running testMinimumRequirements.m using the solver interface: %s ... ', solvers.LP{k});
       
       assert(numel(dir('Results post-optimization/Minimum requirements')) > 2)
       
       % output a success message
       fprintf('Done.\n');
    end
end

% change the directory
cd(currentDir)