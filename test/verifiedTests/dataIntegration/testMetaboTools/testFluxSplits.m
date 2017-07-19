% The COBRA Toolbox: testFluxSplits.m
%
% Purpose:
%     - tests the predictFluxSplits function
%
% Authors:
%     - Original file: Hulda Haraldsdottir
%     - CI integration: Laurent Heirendt January 2017
%
% Note:
%     - This test only runs with solvers that can solve LP and QP problems

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFluxSplits'));
cd(fileDir);

% define a toy model with single internal loop
model.mets = {'A'; 'B'; 'C'};
model.rxns = {'R1'; 'R2'; 'R3'; 'U'; 'S'};
model.S = [-1  0 -1 -1  0;
            1 -1  0  0  0;
            0  1  1  0 -1];
model.b = [0; 0; 0];
model.lb = [-1000; -1000; -1000; -10; 0];
model.ub = [1000; 1000; 1000; 0; 10];
model.c = [0; 0; 0; 0; 1];

% define inputs
obj = 'S';
met2test = {'C'};
samples = {'model'};
ResultsAllCellLines.model.modelPruned = model;

% define parameteres for tests
tol = 1e-6;
v_ref = [10/3; 10/3; 20/3; -10; 10]; % reference flux distribution

% list of solver packages
solverPkgs = {'tomlab_cplex', 'gurobi6'};

for k = 1:length(solverPkgs)

    fprintf(' -- Running testFluxSplits using the solver interface: %s ... ', solverPkgs{k});

    s1 = changeCobraSolver(solverPkgs{k}, 'LP', 0);
    s2 = changeCobraSolver(solverPkgs{k}, 'QP', 0);

    if s1 == 1 && s2 == 1
        % Test of production
        p.rxn = {'R3'}; % max contributing reaction
        p.flux = [20/3, 10, 200/3]; % contributing fluxes
        [BMall, ResultsAllCellLines, ~, maximum_contributing_rxn, maximum_contributing_flux, ~] = predictFluxSplits(model, obj, met2test, samples, ResultsAllCellLines, 1);

        assert(norm(BMall - v_ref) < tol);
        assert(strcmp(maximum_contributing_rxn,p.rxn));
        assert(norm(maximum_contributing_flux - p.flux) < tol);

        % Test of consumption
        c.rxn = {'S'}; % max contributing reaction
        c.flux = [10, 10, 100]; % contributing fluxes
        [BMall, ResultsAllCellLines, ~, maximum_contributing_rxn, maximum_contributing_flux, ~] = predictFluxSplits(model, obj, met2test, samples, ResultsAllCellLines, 0);

        assert(norm(BMall - v_ref) < tol);
        assert(strcmp(maximum_contributing_rxn,c.rxn));
        assert(norm(maximum_contributing_flux - c.flux) < tol);

        % set a status message
        fprintf('Done.\n');
    else
        warning('The test testFluxSplits cannot run using the solver interface: %s. The solver interface is not installed or not configured properly.\n', solverPkgs{k});
    end
end

% change the directory
cd(currentDir)
