% The COBRAToolbox: testSingleRxnDeletion.m
%
% Purpose:
%     - singleRxnDeletion knocks out each reaction of a list in turn and computes the growth
%       of the deletion strain by FBA, MOMA (QP) or linear MOMA (LP). A reaction that
%       carries no flux in the minimal-norm wild type solution is not re-optimised: its
%       strain keeps the wild type growth and flux and hasEffect is false. An infeasible
%       strain gets growth NaN and a NaN flux column. The test checks the growth rates,
%       ratios, hasEffect, delRxn and the strain fluxes (feasibility of each strain model)
%       for the three methods, the default and explicit reaction lists and the verbose
%       output.
%     - Expected values are derived by hand on the six-reaction toy model of
%       testSingleSL.m: EX_A ( -> A, ub 10), R1 (A -> B), R2 (A -> C, ub 5), R3 (C -> B),
%       BIO (B -> , objective) and ATPM (A -> , lb 1). The wild type growth is 9 and the
%       minimal-norm wild type flux is EX_A 10, R1 9, BIO 9, ATPM 1 (R2-R3 costs twice the
%       flux), so R2 and R3 carry no flux. FBA growth of the knock-outs: EX_A infeasible
%       (ATPM is forced), R1 5 (through R2-R3, R2 ub 5), BIO 0, ATPM 10.
%       Linear MOMA (sum of absolute differences to an optimal wild type flux, which here is
%       EX_A 10, R1 9 - t, R2 = R3 = t, BIO 9, ATPM 1 with t in [0, 5]): for the R1 knock-out
%       the distance 27 - 3*b decreases with the growth b <= 5, so b = 5; for the ATPM
%       knock-out the distance is at least |10 - e| + 2*|9 - e| + 1, smallest at growth
%       e = 9. MOMA (sum of squared differences): for the R1 knock-out the gradient keeps
%       R2 = R3 = 5 and the wild type t = 5 at their bounds, growth 5; for the ATPM knock-out
%       the distance (10 - e)^2 + 5/3*(9 - e)^2 + 1 (after minimising over the R2-R3 split)
%       is smallest at e = 75/8 = 9.375.
%
% Function under test:
%     src/analysis/deletion/singleRxnDeletion.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LP (FBA, linear MOMA) with every available LP solver among gurobi and glpk,
%     QP (MOMA) with gurobi (pdco is excluded, as in testMOMA: its interior-point QP does
%     not reach the accuracy of the hand-derived values), on a six-reaction toy model.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%     (Method 'lMOMA' is used only with a feasible wild type model: linearMOMA is quarantined
%     for an infeasible wild type, see testLinearMOMA.m, so that input is skipped here.)
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSingleRxnDeletion'));
cd(fileDir);

% the solver set-up may create global variables; those created here are removed at the end
globalsBefore = who('global');

% require an LP and a QP solver; skip gracefully if none is available
solvers = prepareTest('needsLP', true, 'needsQP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'}, ...
    'excludeSolvers', {'pdco', 'qpng', 'mosek', 'dqqMinos'});
initialSolverState = CobraSolverState.get();

% the toy model (see Purpose)
rxnIds = {'EX_A'; 'R1'; 'R2'; 'R3'; 'BIO'; 'ATPM'};
model = createModel(rxnIds, rxnIds, {' -> A'; 'A -> B'; 'A -> C'; 'C -> B'; 'B -> '; 'A -> '}, ...
    'lowerBoundList', [0 0 0 0 0 1], 'upperBoundList', [10 1000 5 1000 1000 1000], 'printLevel', 0);
model = changeObjective(model, 'BIO');
nRxns = numel(rxnIds);

% the unique minimal-norm wild type flux and the hand-derived growth of each knock-out
wildTypeFlux = [10; 9; 0; 0; 9; 1];
expectedFBA = [NaN; 5; 9; 9; 0; 10];
expectedLinearMOMA = [NaN; 5; 9; 9; 0; 9];
expectedMOMA = [NaN; 5; 9; 9; 0; 75/8];
% hasEffect is false exactly for the reactions without wild type flux (R2, R3)
expectedHasEffect = logical([1; 1; 0; 0; 1; 1]);

% tolerances: LP results of a toy model are exact up to the solver feasibility tolerance
% (1e-6); the QP optimum is checked to 1e-4, the accuracy a barrier/simplex QP reaches
tolLP = 1e-6;
tolQP = 1e-4;

for k = 1:numel(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if ~solverOK
        continue
    end
    fprintf('   Testing singleRxnDeletion (FBA, lMOMA) using %s ... \n', solvers.LP{k});

    %% default method (FBA) and default reaction list (all reactions)
    % growth rates and ratios as derived by hand; the infeasible EX_A knock-out gives NaN
    % growth and a NaN flux column
    [grRatio, grRateKO, grRateWT, hasEffect, delRxn, fluxSolution] = singleRxnDeletion(model);
    assert(abs(grRateWT - 9) < tolLP);
    assert(isnan(grRateKO(1)) && isnan(grRatio(1)) && all(isnan(fluxSolution(:, 1))));
    assert(max(abs(grRateKO(2:end) - expectedFBA(2:end))) < tolLP);
    assert(max(abs(grRatio(2:end) - expectedFBA(2:end) / 9)) < tolLP);
    assert(isequal(hasEffect, expectedHasEffect));
    % delRxn is the reaction list as a column
    assert(isequal(delRxn, rxnIds));
    % reactions without wild type flux keep the minimal-norm wild type flux (no LP solved)
    assert(max(abs(fluxSolution(:, 3) - wildTypeFlux)) < tolLP);
    assert(isequal(fluxSolution(:, 3), fluxSolution(:, 4)));
    % every other strain flux is feasible for its knock-out model (reaction i fixed to 0,
    % the others within their bounds) and grows at grRateKO
    for i = [2 5 6]
        x = fluxSolution(:, i);
        others = setdiff(1:nRxns, i);
        assert(norm(model.S * x, inf) < tolLP && abs(x(i)) < tolLP);
        assert(all(x(others) >= model.lb(others) - tolLP) && all(x(others) <= model.ub(others) + tolLP));
        assert(abs(model.c' * x - grRateKO(i)) < tolLP);
    end

    %% explicit reaction list with method 'FBA' (three inputs), and an empty list
    % a given list is analysed in its order; an empty list means all reactions
    [grRatio, grRateKO, grRateWT, hasEffect, delRxn] = singleRxnDeletion(model, 'FBA', {'ATPM'; 'R2'});
    assert(max(abs(grRateKO - [10; 9])) < tolLP && isequal(hasEffect, [true; false]));
    assert(isequal(delRxn, {'ATPM'; 'R2'}) && max(abs(grRatio - [10; 9] / 9)) < tolLP);
    % a row list is returned as a column
    [~, ~, ~, ~, delRxn] = singleRxnDeletion(model, 'FBA', {'BIO', 'R1'});
    assert(isequal(delRxn, {'BIO'; 'R1'}));
    [~, grRateKO] = singleRxnDeletion(model, 'FBA', {});
    assert(isnan(grRateKO(1)) && max(abs(grRateKO(2:end) - expectedFBA(2:end))) < tolLP);

    %% verbose output (verbFlag true) prints a header and one line per reaction
    [~, grRateKO] = singleRxnDeletion(model, 'FBA', {'R1'; 'R3'}, true);
    assert(max(abs(grRateKO - [5; 9])) < tolLP);

    %% linear MOMA ('lMOMA'): wild type feasible (see Known defects)
    % growth rates as derived by hand; the R1 strain flux is not unique (only its growth),
    % so its feasibility is checked, not a flux vector
    [grRatio, grRateKO, grRateWT, hasEffect, ~, fluxSolution] = singleRxnDeletion(model, 'lMOMA');
    assert(abs(grRateWT - 9) < tolLP && isequal(hasEffect, expectedHasEffect));
    assert(isnan(grRateKO(1)) && all(isnan(fluxSolution(:, 1))));
    assert(max(abs(grRateKO(2:end) - expectedLinearMOMA(2:end))) < tolLP);
    assert(max(abs(grRatio(2:end) - expectedLinearMOMA(2:end) / 9)) < tolLP);
    for i = [2 5 6]
        x = fluxSolution(:, i);
        others = setdiff(1:nRxns, i);
        assert(norm(model.S * x, inf) < tolLP && abs(x(i)) < tolLP);
        assert(all(x(others) >= model.lb(others) - tolLP) && all(x(others) <= model.ub(others) + tolLP));
        assert(abs(model.c' * x - grRateKO(i)) < tolLP);
    end
end

for k = 1:numel(solvers.QP)
    % select the same solver for QP and LP (if available)
    if any(strcmp(solvers.QP{k}, solvers.LP))
        lpSolver = solvers.QP{k};
    else
        lpSolver = solvers.LP{1};
    end
    if ~changeCobraSolver(solvers.QP{k}, 'QP', 0) || ~changeCobraSolver(lpSolver, 'LP', 0)
        continue
    end
    fprintf('   Testing singleRxnDeletion (MOMA) using %s for QP and %s for LP ... \n', solvers.QP{k}, lpSolver);

    %% MOMA: growth rates as derived by hand, strain fluxes feasible
    % the R1 strain flux is unique for MOMA (strictly convex distance): EX_A 8, R2 = R3 =
    % BIO = 5, ATPM 3 (see Purpose: t = 5, b = 5, a minimises (5 - a)^2 + (1 - a)^2)
    [grRatio, grRateKO, grRateWT, hasEffect, ~, fluxSolution] = singleRxnDeletion(model, 'MOMA');
    assert(abs(grRateWT - 9) < tolLP && isequal(hasEffect, expectedHasEffect));
    assert(isnan(grRateKO(1)) && all(isnan(fluxSolution(:, 1))));
    assert(max(abs(grRateKO(2:end) - expectedMOMA(2:end))) < tolQP);
    assert(max(abs(grRatio(2:end) - expectedMOMA(2:end) / 9)) < tolQP);
    assert(max(abs(fluxSolution(:, 2) - [8; 0; 5; 5; 5; 3])) < tolQP);
    for i = [2 5 6]
        x = fluxSolution(:, i);
        others = setdiff(1:nRxns, i);
        assert(norm(model.S * x, inf) < tolQP && abs(x(i)) < tolQP);
        assert(all(x(others) >= model.lb(others) - tolQP) && all(x(others) <= model.ub(others) + tolQP));
    end
end

% restore the solver state, remove the globals created by the solver set-up, restore the
% directory
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
for i = 1:numel(newGlobals)
    clear('global', newGlobals{i});
end
cd(currentDir)
