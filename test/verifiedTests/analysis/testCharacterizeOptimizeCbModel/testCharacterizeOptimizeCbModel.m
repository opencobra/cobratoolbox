% The COBRAToolbox: testCharacterizeOptimizeCbModel.m
%
% Purpose:
%     - Characterization test that PINS the current behaviour of optimizeCbModel
%       across the axes the existing testOptimizeCbModel.m does not cover: the full
%       status matrix (optimal / infeasible / unbounded), every documented minNorm
%       strategy, both optimization senses, allowLoops on/off, and the presence of
%       primal and dual quantities. It asserts EXISTING behaviour (feature 009,
%       Constitution Principle III characterization mode); it must not change
%       optimizeCbModel. Canonical .stat is pinned exactly (solver-independent);
%       objective, mass-balance residual and fluxes are pinned within tolerance.
%
% Authors:
%     - Generated for feature 009-fba-characterization-statusmap, 2026-07-15.

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCharacterizeOptimizeCbModel'));
cd(fileDir);

% tolerance for floating-point comparisons (integer .stat is compared exactly)
tol = 1e-6;
% The minNorm re-solves (which must PRESERVE the optimum) pin the objective only
% to the solver's optimality tolerance, which varies across solver/MATLAB
% versions; a tight 1e-6 pin there is over-specified and fails on some CI gurobi
% builds. Use a looser tolerance for those objective pins only; the base direct
% solves and all structural checks (status, mass balance, flux vector) stay at tol.
objTol = 1e-4;

% require an LP solver; skip cleanly otherwise
solverPkgs = prepareTest('needsLP', true);

for k = 1:length(solverPkgs.LP)

    solverLP = solverPkgs.LP{k};
    fprintf('   Characterizing optimizeCbModel with LP solver %s ... ', solverLP);
    solverLPOK = changeCobraSolver(solverLP, 'LP', 0);

    if solverLPOK
        % is a QP solver also available (for the L2 / positive-scalar minNorm case)?
        qpOK = changeCobraSolver(solverLP, 'QP', 0);

        % --- OPTIMAL (max), minNorm = 0 -----------------------------------------
        model = buildToyModel();
        s = optimizeCbModel(model, 'max', 0);
        assert(s.stat == 1);                                   % canonical: optimal
        assert(abs(s.f - 10) < tol);                           % objective pinned
        assert(norm(model.S * s.v - model.b) < tol);           % mass balance
        assert(norm(s.v - [10; 10; 10]) < tol);                % unique optimum
        % dual quantities are present and well-formed (values are solver-dependent)
        assert(numel(s.w) == numel(model.rxns) && all(isfinite(s.w)));
        assert(numel(s.y) == numel(model.mets) && all(isfinite(s.y)));

        % --- OPTIMAL (min) ------------------------------------------------------
        s = optimizeCbModel(model, 'min', 0);
        assert(s.stat == 1);
        assert(abs(s.f - 0) < tol);

        % --- minNorm strategies preserve the optimum (all stat==1, f==10) -------
        for minNorm = {'one', 'zero', [1; 1; 1]}
            s = optimizeCbModel(model, 'max', minNorm{1});
            assert(s.stat == 1);
            assert(abs(s.f - 10) < objTol);
            assert(norm(model.S * s.v - model.b) < tol);
        end

        % L2 / positive-scalar minNorm requires a QP solver
        if qpOK
            s = optimizeCbModel(model, 'max', 1e-6);
            assert(s.stat == 1);
            assert(abs(s.f - 10) < objTol);
        end

        % 'optimizeCardinality' minNorm requires model.g0 on the model; pin that
        % the bare model raises rather than silently proceeding.
        errored = false;
        try
            optimizeCbModel(model, 'max', 'optimizeCardinality');
        catch
            errored = true;
        end
        assert(errored);

        % --- allowLoops on/off --------------------------------------------------
        s = optimizeCbModel(model, 'max', 0, true);
        assert(s.stat == 1 && abs(s.f - 10) < tol);
        s = optimizeCbModel(model, 'max', 0, false);
        assert(s.stat == 1 && abs(s.f - 10) < tol);

        % --- INFEASIBLE ---------------------------------------------------------
        modelInf = buildToyModel();
        modelInf.lb(3) = 50;                                   % demand 50 out, input capped at 10
        s = optimizeCbModel(modelInf, 'max', 0);
        assert(s.stat == 0);                                   % canonical: infeasible

        % --- UNBOUNDED ----------------------------------------------------------
        modelUnb = buildToyModel();
        modelUnb.ub = [inf; inf; inf];                         % uncap the pathway
        s = optimizeCbModel(modelUnb, 'max', 0);
        assert(s.stat == 2);                                   % canonical: unbounded

        fprintf('Done.\n');
    end
end

% change the directory back
cd(currentDir);


function model = buildToyModel()
    % Tiny linear pathway A ->(R1, ub 10) -> B (R2) -> out (R3, objective).
    % Feasible with a unique optimum f = 10; used to characterize the status matrix.
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
