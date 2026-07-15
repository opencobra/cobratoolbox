% The COBRAToolbox: testCharacterizeSolveCobraLP.m
%
% Purpose:
%     - Characterization test that PINS the dispatcher-level status outcomes of
%       solveCobraLP (optimal / infeasible / unbounded) on a built LP problem, the
%       status matrix the existing tests do not assert (feature
%       009-fba-characterization-statusmap, W7-core / W2). Asserts EXISTING
%       behaviour (Constitution Principle III characterization mode); canonical
%       .stat is pinned exactly, objective within tolerance. It must not change
%       solveCobraLP behaviour.
%
% Authors:
%     - Generated for feature 009-fba-characterization-statusmap, 2026-07-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCharacterizeSolveCobraLP'));
cd(fileDir);

tol = 1e-6;

% require an LP solver; skip cleanly otherwise
solverPkgs = prepareTest('needsLP', true);

model = buildToyModel();
optProblem = buildOptProblemFromModel(model);

for k = 1:length(solverPkgs.LP)

    solverLP = solverPkgs.LP{k};
    fprintf('   Characterizing solveCobraLP status matrix with %s ... ', solverLP);
    solverLPOK = changeCobraSolver(solverLP, 'LP', 0);

    if solverLPOK
        % --- OPTIMAL ---
        sol = solveCobraLP(optProblem);
        assert(sol.stat == 1);                       % canonical: optimal
        assert(abs(sol.obj - 10) < tol);             % objective pinned
        assert(norm(sol.full - [10; 10; 10]) < tol); % unique optimum

        % --- INFEASIBLE ---
        infProblem = optProblem;
        infProblem.lb(3) = 50;                       % demand 50 out, input capped at 10
        sol = solveCobraLP(infProblem);
        assert(sol.stat == 0);                       % canonical: infeasible

        % --- UNBOUNDED ---
        unbProblem = optProblem;
        unbProblem.ub = [inf; inf; inf];             % uncap the pathway
        sol = solveCobraLP(unbProblem);
        assert(sol.stat == 2);                       % canonical: unbounded

        fprintf('Done.\n');
    end
end

% change the directory back
cd(currentDir);


function model = buildToyModel()
    % Tiny linear pathway A ->(R1, ub 10) -> B (R2) -> out (R3, objective).
    model = struct();
    model.rxns = {'R1'; 'R2'; 'R3'};
    model.mets = {'A'; 'B'};
    model.S = [1, -1, 0; 0, 1, -1];
    model.lb = [0; 0; 0];
    model.ub = [10; 1000; 1000];
    model.c = [0; 0; 1];
    model.b = [0; 0];
    model.csense = ['E'; 'E'];
    model.osenseStr = 'max';
end
