% The COBRAToolbox: filterRateLimittingReactions.m
%
% Purpose:
%     - For testing the IgemRNA post-optimization task called "Rate
%     limitting reactions" which filters reactions from a result model
%     where FVA max equals reacrion upper bound
%
% Authors:
%     - Kristina Grausa 05/16/2022 - created 
%     - Kristina Grausa 08/22/2022 - standard header and formatting
%     - Farid Zare      11/21/2023 - Correction of repository address format 
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

for k = 1:length(solvers.LP)
    solverLPOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);

    if solverLPOK
       filterRateLimittingReactions(phenotype);
 
       fprintf(' -- Running testRateLimittingReactions.m using the solver interface: %s ... ', solvers.LP{k});
       
       assert(numel(dir('resultsPostOptimization/rateLimittingReactions')) > 2)
       
       % output a success message
       fprintf('Done.\n');
    end
end

% change the directory
cd(currentDir)
