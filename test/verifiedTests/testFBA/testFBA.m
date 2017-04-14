% The COBRAToolbox: testFBA.m
%
% Purpose:
%     - tests the basic functionality of FBA
%       Tests four basic solution: Optimal minimum 1-norm solution, Optimal
%       solution on fructose, Optimal anaerobic solution, Optimal ethanol
%       secretion rate solution returns 1 if all tests were completed succesfully, 0 if not
%
% Authors:
%     - Original file: Joseph Kang 04/27/09
%     - CI integration: Laurent Heirendt January 2017
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFBA'));
cd(fileDir);

% set the tolerance
tol = 1e-8;

% define the solver packages to be used to run this test
solverPkgs = {'gurobi6', 'tomlab_cplex', 'glpk'};

% load the model
load('testFBAData.mat');

for k = 1:length(solverPkgs)

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverOK == 1
        fprintf('   Testing flux balance analysis using %s ... ', solverPkgs{k});

        % check the optimal solution - BiomassEcoli
        fprintf('\n>> Optimal minimum 1-norm solution\n');
        model = changeObjective(model, {'BiomassEcoli'}, 1);
        solution = optimizeCbModel(model);

        % testing if f values are within range
        assert(abs(solution.f - solutionStd.f) < tol);

        % testing if c*x == f
        assert(abs(model.c' * solution.x - solution.f) < tol);

        % print the flux vector
        printFluxVector(model, solution.x, true, true);

        % check the optimal solution - fructose
        fprintf('\n>> Optimal solution on fructose\n');
        model2 = changeRxnBounds(model, {'EX_glc(e)', 'EX_fru(e)'}, [0 -9], 'l');
        solution2 = optimizeCbModel(model2);

        % testing if f values are within range
        assert(abs(solution2.f - solution2Std.f) < tol);

        % testing if c*x == f
        assert(abs(model2.c' * solution2.x - solution2.f) < tol);

        % print the flux vector
        printFluxVector(model2, solution.x, true, true);

        % check the optimal anaerobic solution
        fprintf('\n>> Optimal anaerobic solution\n');
        model3 = changeRxnBounds(model, 'EX_o2(e)', 0, 'l');
        solution3 = optimizeCbModel(model3);

        % testing if f values are within range
        assert(abs(solution3.f - solution3Std.f) < tol);

        % testing if c*x == f
        assert(abs(model3.c' * solution3.x - solution3.f) < tol);

        % check the optimal ethanol secretion rate solution
        fprintf('\n>> Optimal ethanol secretion rate solution \n');
        model4 = changeObjective(model, 'EX_etoh(e)', 1);
        solution4 = optimizeCbModel(model4);

        % testing if f values are within range
        assert(abs(solution4.f - solution4Std.f) < tol);

        % testing if c*x == f
        assert(abs(model4.c' * solution4.x - solution4.f) < tol);

        % output a success message
        fprintf('Done.\n');
    end
end

% change the directory
cd(currentDir)
