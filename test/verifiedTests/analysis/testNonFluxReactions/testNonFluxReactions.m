% The COBRAToolbox: filterNonFluxReactions.m
%
% Purpose:
%     - For testing the IgemRNA post-optimization task called "None-flux reactions" 
%       which filters reactions carrying no flux value and saves the
%       results in an excel file
%
% Authors:
%     - Kristina Grausa 05/16/2022 - created 
%     - Kristina Grausa 08/22/2022 - standard header and formatting
%     - Farid Zare      20/11/2023 - Repository addresses are corrected
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
       filterNonFluxReactions(phenotype);
       
       fprintf(' -- Running testNonFluxReactions.m using the solver interface: %s ... ', solvers.LP{k});
       
       assert(numel(dir('resultsPostOptimization/nonFluxReactions/')) > 2)
       
       % output a success message
       fprintf('Done.\n');
    end
end

% change the directory
cd(currentDir)
