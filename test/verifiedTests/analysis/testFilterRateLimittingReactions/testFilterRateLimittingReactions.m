% The COBRAToolbox: filterRateLimittingReactions.m
%
% Purpose:
%     - For testing the IgemRNA post-optimization task called "Rate
%     limitting reactions" which filters reactions from a result model
%     where FVA max equals reacrion upper bound
%
% Function under test:
%     src/analysis/igemRNA/filterRateLimittingReactions/filterRateLimittingReactions.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model and no optimisation; a result file from this folder, and small result files
%     written to a temporary folder for two models of one phenotype and for a file without MaxFlux.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Kristina Grausa 05/16/2022 - created 
%     - Kristina Grausa 08/22/2022 - standard header and formatting
%     - Farid Zare      11/21/2023 - Correction of repository address format 
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

% Load reference data
load('ref_rate_limitting_reactions_WT.mat');

for k = 1:length(solvers.LP)
    solverLPOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);

    if solverLPOK
       filterRateLimittingReactions(phenotype);
 
       fprintf(' -- Running testRateLimittingReactions.m using the solver interface: %s ... ', solvers.LP{k});

       % Load result data
       resultPath = fullfile('resultsPostOptimization', 'rateLimittingReactions', '_rate_limitting_reactionsWT.xls');
       resultData = readtable(resultPath);

       assert(isequaln(refData, resultData));
              
       % output a success message
       fprintf('Done.\n');
    end
end

% remove the results written in this folder
rmdir(fullfile('resultsPostOptimization', 'rateLimittingReactions'), 's');

%% two models of one phenotype: the common rate limiting reactions are those of both models

% small result files in a temporary folder
workDir = tempname;
mkdir(fullfile(workDir, 'resultsPostOptimization', 'contextSpecificModels'));
cd(workDir);
modelFolder = fullfile('resultsPostOptimization', 'contextSpecificModels');
columns = {'Reaction', 'UpperBound', 'MaxFlux', 'GPR'};

% R1 is limiting in both models and R2 in the first only. Not limiting: R3 (below its bound), R4
% (bound of 1000), R5 (bound of 0) and R6 (without a gene rule)
writetable(cell2table({'R1', '10', '10', 'g1'; 'R2', '5', '5', 'g2'; 'R3', '8', '5', 'g3'; ...
                       'R4', '1000', '1000', 'g4'; 'R5', '0', '0', 'g5'; 'R6', '7', '7', ''}, 'VariableNames', columns), ...
           fullfile(modelFolder, 'first_toy.xls'), 'Sheet', 'Reaction List');
writetable(cell2table({'R1', '10', '10', 'g1'; 'R2', '5', '4', 'g2'; 'R3', '8', '5', 'g3'; ...
                       'R4', '1000', '1000', 'g4'; 'R5', '0', '0', 'g5'; 'R6', '7', '7', ''}, 'VariableNames', columns), ...
           fullfile(modelFolder, 'second_toy.xls'), 'Sheet', 'Reaction List');
filterRateLimittingReactions('toy');

% one sheet per model with its own reactions, and a sheet with the common ones
resultFile = fullfile('resultsPostOptimization', 'rateLimittingReactions', '_rate_limitting_reactionstoy.xls');
assert(isfile(resultFile));
assert(isequal(sort(sheetnames(resultFile)), sort(["first_toy"; "second_toy"; "Common_toy"])));
firstSheet = readcell(resultFile, 'Sheet', 'first_toy');
secondSheet = readcell(resultFile, 'Sheet', 'second_toy');
commonSheet = readcell(resultFile, 'Sheet', 'Common_toy');
assert(isequal(firstSheet(:, 1), {'Reaction'; 'R1'; 'R2'}));
assert(isequal(secondSheet(:, 1), {'Reaction'; 'R1'}));
assert(isequal(commonSheet(:, 1), {'Reaction'; 'R1'}));

%% a model file without the column MaxFlux: the error of each row is displayed and the row skipped

writetable(cell2table({'R1', '10'; 'R2', '5'}, 'VariableNames', {'Reaction', 'UpperBound'}), ...
           fullfile(modelFolder, 'noMaxFlux.xls'), 'Sheet', 'Reaction List');
printed = evalc('filterRateLimittingReactions(''noMaxFlux'');');
assert(numel(strfind(printed, 'Unrecognized table variable name')) == 2);

% only the column names are written
resultFile = fullfile('resultsPostOptimization', 'rateLimittingReactions', '_rate_limitting_reactionsnoMaxFlux.xls');
assert(isequal(readcell(resultFile, 'Sheet', 'Common_noMaxFlux'), {'Reaction', 'UpperBound'}));

cd(testPath);
rmdir(workDir, 's');

% change the directory
cd(currentDir)
