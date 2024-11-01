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
%     - Farid Zare      02/12/2024 - Repository addresses are corrected
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

% change the directory
cd(currentDir)
