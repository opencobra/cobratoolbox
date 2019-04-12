% The COBRAToolbox: Lp9.m
%
% Purpose:
%     - test if bug fix in LP9 affects the results for test model (without
%     coupling constraints)
%
% Authors:
%     Agnieszka Wegrzyn 2019/04/09, fix compatibility for models with coupling constraints
%

global CBTDIR

% define the features required to run the test
requiredSolvers = {'gurobi'};

% require the specified toolboxes and solvers, along with a UNIX OS
solversPkgs = prepareTest('requiredSolvers', requiredSolvers, 'excludeSolvers', {'matlab', 'lp_solve'});

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% determine the test path for references
testPath = pwd;

% load the model
model = getDistributedModel('ecoli_core_model.mat'); %For all models in the test/models folder and subfolders

% load reference data and input variables
load('testData_LP9.mat');

% load
for k = 1:length(solversPkgs.LP)
    fprintf(' -- Running testLP9.m using the solver interface: %s ... ', solversPkgs.LP{k});

    solverLPOK = changeCobraSolver(solversPkgs.LP{k}, 'LP', 0);

    if solverLPOK
        % created test data for new version
        V = LP9(options.K, options.P, model, options.LPproblem, options.epsilon);
        solTest = model.c'*V;
    end
    assert(isequal(solOri,solTest), '\nResults are not consistent between old and new version of LP9\n')
    % output a success message
    fprintf('\nDone.\n');
end

% change the directory
cd(currentDir)
