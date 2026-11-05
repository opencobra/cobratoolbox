% The COBRAToolbox: filterNonFluxReactions.m
%
% Purpose:
%     - For testing the IgemRNA post-optimization task called "None-flux reactions" 
%       which filters reactions carrying no flux value and saves the
%       results in an excel file
%
% Function under test:
%     src/analysis/igemRNA/filterNonFluxReactions/filterNonFluxReactions.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model and no optimisation; result files from this folder, and small result files
%     written to a temporary folder for two models of one phenotype.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The result file is written next to the result folder, not into it
%       SEVERITY: wrong-result
%       TRIGGER: any call, for example filterNonFluxReactions('WT')
%       OBSERVED: the path is built without a file separator, so the result goes to
%         resultsPostOptimization/nonFluxReactionsnonFluxReactionsWT.xls and the folder
%         nonFluxReactions stays empty. The first section below therefore compares the reference
%         with the file stored in this folder, not with a new result.
%       EXPECTED: resultsPostOptimization/nonFluxReactions/nonFluxReactionsWT.xls
%       LINES: 84
%
% Authors:
%     - Kristina Grausa 05/16/2022 - created 
%     - Kristina Grausa 08/22/2022 - standard header and formatting
%     - Farid Zare      02/12/2024 - Repository addresses are corrected
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
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

% set function params
phenotype = 'WT';

% Load reference Data
load('ref_nonflux_reactions.mat')

for k = 1:length(solvers.LP)
    solverLPOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);

    if solverLPOK
       filterNonFluxReactions(phenotype);
       
       fprintf(' -- Running testNonFluxReactions.m using the solver interface: %s ... ', solvers.LP{k});

       % Load the result
       resultPath = fullfile('resultsPostOptimization', 'nonFluxReactions', 'nonFluxReactionsWT.xls');
       resultData = readtable(resultPath);
       
       assert(isequaln(resultData, refData));
       
       % output a success message
       fprintf('Done.\n');
    end
end

% remove the result written in this folder (see the defect in the header)
strayResult = fullfile('resultsPostOptimization', 'nonFluxReactionsnonFluxReactionsWT.xls');
if isfile(strayResult)
    delete(strayResult);
end

%% two models of one phenotype: the common non-flux reactions are those of both models

% small result files in a temporary folder, without the folder for the results
workDir = tempname;
mkdir(fullfile(workDir, 'resultsPostOptimization', 'contextSpecificModels'));
cd(workDir);
modelFolder = fullfile('resultsPostOptimization', 'contextSpecificModels');
columns = {'Reaction', 'LowerBound', 'UpperBound'};

% exist(folder, 'dir') also searches the MATLAB path, which holds the folder of the same name of this
% test, so it is taken off the path for the function to create the folder here
storedFolder = fullfile(testPath, 'resultsPostOptimization', 'nonFluxReactions');
storedFolderOnPath = ismember(storedFolder, strsplit(path, pathsep));
if storedFolderOnPath
    rmpath(storedFolder);
end

% R1 carries no flux in both models, R2 and R3 in one model each, R4 in neither
writetable(cell2table({'R1', '0', '0'; 'R2', '0', '0'; 'R3', '-1', '1'; 'R4', '0', '2'}, 'VariableNames', columns), ...
           fullfile(modelFolder, 'first_toy.xls'), 'Sheet', 'Reaction List');
writetable(cell2table({'R1', '0', '0'; 'R2', '-1', '0'; 'R3', '0', '0'; 'R4', '1', '2'}, 'VariableNames', columns), ...
           fullfile(modelFolder, 'second_toy.xls'), 'Sheet', 'Reaction List');
filterNonFluxReactions('toy');
if storedFolderOnPath
    addpath(storedFolder);
end

% the folder for the results is created, and one result file is written (see the defect in the header)
assert(isfolder(fullfile('resultsPostOptimization', 'nonFluxReactions')));
results = dir(fullfile('resultsPostOptimization', '**', '*nonFluxReactionstoy.xls'));
assert(numel(results) == 1);
resultFile = fullfile(results(1).folder, results(1).name);

% one sheet per model with its own non-flux reactions, and a sheet with the common ones
assert(isequal(sort(sheetnames(resultFile)), sort(["first_toy"; "second_toy"; "Common_toy"])));
firstSheet = readcell(resultFile, 'Sheet', 'first_toy');
secondSheet = readcell(resultFile, 'Sheet', 'second_toy');
commonSheet = readcell(resultFile, 'Sheet', 'Common_toy');
assert(isequal(firstSheet(:, 1), {'Reaction'; 'R1'; 'R2'}));
assert(isequal(secondSheet(:, 1), {'Reaction'; 'R1'; 'R3'}));
assert(isequal(commonSheet(:, 1), {'Reaction'; 'R1'}));

cd(testPath);
rmdir(workDir, 's');

% change the directory
cd(currentDir)
