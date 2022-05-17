% The COBRAToolbox: filterRateLimittingReactions.m
%
% Purpose:
%     - For testing the IgemRNA post-optimization task called "Rate
%     limitting reactions" which filters reactions from a result model
%     where FVA max equals reacrion upper bound
%
% Authors:
%     - Created: 17/01/2022
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

% set function params
phenotype = 'WT';

for k = 1:length(solvers.LP)
    solverLPOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);

    if solverLPOK
       filterRateLimittingReactions(phenotype);
 
       fprintf(' -- Running testRateLimittingReactions.m using the solver interface: %s ... ', solvers.LP{k});
       
       assert(numel(dir('Results post-optimization\Rate limitting reactions')) > 2)
       
       % output a success message
       fprintf('Done.\n');
    end
end

% change the directory
cd(currentDir)