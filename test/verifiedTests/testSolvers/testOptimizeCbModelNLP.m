% The COBRAToolbox: testSolveCobraNLP.m
%
% Purpose:
%     - tests the optimizeCbModelNLP function, and some of its parameters.
%
% Authors:
%     - Original file: * Joseph Kang 11/16/09
%                      * Richard Que (02/11/10) NLP Support
%     - CI integration: Laurent Heirendt, March 2017
%
% Note:
%     - The tomlab_snopt solver must be tested with a valid license

% save the current path
currentDir = pwd;

% initialize the test
initTest(fileparts(which(mfilename)));

% set the tolerance
tol = 1e-6;

load('ecoli_core_model','model')

% define the solver packages to be used to run this test
solverPkgs = {'glpk'};  % tomlab_snopt

for k = 1:length(solverPkgs)

    % change the COBRA solver (NLP)
    solverOK = changeCobraSolver(solverPkgs{k});

    if solverOK == 1
        fprintf('   Testing solveCobraNLP using %s ... ', solverPkgs{k});

        toymodel = createToyModel(0, 0, 0); % create a toy model 
        toymodel.ub(1) = -1; %force uptake, otherwise the default Objective will try to minimize all fluxes...
        
        % optimize
        sol = optimizeCbModelNLP(toymodel, 'nOpt', 10);

        % the optimal sol has the minimal uptake and a maximal flux distribution.
        optsol = [-1; 0.5; 0.5; 0.5; 0.5];

        assert(abs(sum(sol.x - optsol)) < tol)

        % test a different objective function
        model.ub(28) = 0;

        % maximize the glucose flux...
        objArg = {ismember(model.rxns,model.rxns(28))};
        model.c(:) = 0;
        sol2 = optimizeCbModelNLP(model, 'objFunction', 'SimpleQPObjective', 'objArgs', objArg, 'nOpt', 5);

        assert(abs(sol2.f-100) < tol);

        % output a success message
        fprintf('Done.\n');
    end
end

% change the directory
cd(currentDir)
