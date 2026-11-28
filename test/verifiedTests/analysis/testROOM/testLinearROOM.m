% The COBRAToolbox: testLinearROOM.m
%
% Purpose:
%     - linearROOM solves the LP relaxation of ROOM (regulatory on/off minimization): after the
%       knock-out of the reactions rxnKO it minimises the sum of the continuous indicators y_i
%       in [0, 1] that let flux i leave the tolerance band [w_i - delta*|w_i| - epsilon,
%       w_i + delta*|w_i| + epsilon] around the wild type flux w. It returns the knock-out flux
%       distribution, the solution structure and the Euclidean distance to the wild type flux;
%       an infeasible knock-out gives NaN. The test checks the LP invariants (status, S*v = 0,
%       bounds, knocked-out flux zero), the optimum, the options, the infeasible case and the
%       input checks.
%     - Expected values are derived by hand on a four-reaction toy model (EX_A: -> A, ub 10;
%       R1 and R2: A -> B; EX_B: B ->) with the wild type flux w = [10; 10; 0; 10] and R1
%       knocked out. Every flux then equals one value f along EX_A, R2 and EX_B; y_R1 = 1, and
%       the smallest indicators are y_EX_A = y_EX_B = max(0, (wl - f) / wl) and
%       y_R2 = max(0, (f - wu_R2) / (ub_R2 - wu_R2)), with wl = 10 - 10*delta - epsilon and
%       wu_R2 = epsilon. The sum falls with f until f = wl and rises after it, so the unique
%       optimum is f = wl with objective 1 + (wl - epsilon) / (1000 - epsilon).
%
% Function under test:
%     src/analysis/ROOM/linearROOM.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LP on a four-reaction toy model, every available LP solver among gurobi and glpk.
%
% Coverage exemptions:
%     Line 78: unreachable, the statement `global CBT_LP_PARAMS` above it always creates the
%     variable, so the exist check of line 71 is always true.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: printLevel is accepted but ignored
%       SEVERITY: cosmetic
%       TRIGGER: linearROOM(model, fluxWT, rxnKO, 'printLevel', 1) (the default) or any other
%         printLevel
%       OBSERVED: (R2025a, gurobi, 2026-11-25) the parsed printLevel is never read after line
%         67; the function prints nothing at any level
%       EXPECTED: output gated by printLevel as the help text says ("Verbose output"), or the
%         option removed from the help text
%       LINES: 67
%     - DEFECT: The help text describes totalFluxDiff as a sum of squares
%       SEVERITY: cosmetic
%       TRIGGER: [~, ~, totalFluxDiff] = linearROOM(model, fluxWT, rxnKO)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) totalFluxDiff = norm(fluxROOM - fluxWT), the
%         Euclidean distance (13.9374 on the toy model below), not the sum of squared
%         differences (194.25) of the formula in the help text
%       EXPECTED: the help text and the value agree; the name "Euclidean distance" matches the code
%       LINES: 123
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLinearROOM'));
cd(fileDir);

% the solver set-up may create global variables; those created here are removed at the end
globalsBefore = who('global');

% require an LP solver; skip gracefully if none is available
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
initialSolverState = CobraSolverState.get();

% the LP parameters are a global that a section below changes; it is restored at the end
global CBT_LP_PARAMS
savedLPParams = CBT_LP_PARAMS;
% the same parameters without objTol, so that linearROOM falls back to its own 1e-6
lpParamsWithoutObjTol = savedLPParams;
if isstruct(lpParamsWithoutObjTol) && isfield(lpParamsWithoutObjTol, 'objTol')
    lpParamsWithoutObjTol = rmfield(lpParamsWithoutObjTol, 'objTol');
end

% tolerance: the solvers' feasibility tolerance is 1e-9 or better, the hand-derived values are
% exact, so 1e-6 leaves a wide margin without hiding a wrong vertex (the vertices differ by
% at least 0.3 in flux)
tol = 1e-6;

% the toy model and its wild type flux (EX_A, R1, R2, EX_B)
model = createModel({'EX_A'; 'R1'; 'R2'; 'EX_B'}, {'EX_A'; 'R1'; 'R2'; 'EX_B'}, ...
    {' -> A'; 'A -> B'; 'A -> B'; 'B -> '}, ...
    'lowerBoundList', [0 0 0 0], 'upperBoundList', [10 1000 1000 1000], 'printLevel', 0);
model = changeObjective(model, 'EX_B');
fluxWT = [10; 10; 0; 10];

% expected optimum for given delta and epsilon (see Purpose)
expectedFlux = @(delta, epsilon) (10 - 10 * delta - epsilon) * [1; 0; 1; 1];
expectedObjective = @(delta, epsilon) 1 + (10 - 10 * delta - epsilon - epsilon) / (1000 - epsilon);

for k = 1:numel(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if ~solverOK
        continue
    end
    fprintf('   Testing linearROOM using %s ... \n', solvers.LP{k});

    %% default delta (0.03) and epsilon (0.001), CBT_LP_PARAMS without objTol (tol = 1e-6)
    % proves the LP invariants and the hand-derived unique optimum f = 9.699
    CBT_LP_PARAMS = lpParamsWithoutObjTol;
    [fluxROOM, solutionROOM, totalFluxDiff] = linearROOM(model, fluxWT, {'R1'});
    assert(solutionROOM.stat == 1);
    assert(isequal(size(fluxROOM), [4, 1]));
    assert(norm(model.S * fluxROOM) < tol);
    assert(all(fluxROOM >= model.lb - tol) && all(fluxROOM <= model.ub + tol));
    assert(abs(fluxROOM(2)) < tol);
    assert(norm(fluxROOM - expectedFlux(0.03, 0.001)) < tol);
    assert(abs(solutionROOM.f - expectedObjective(0.03, 0.001)) < tol);
    % totalFluxDiff is the Euclidean distance between the returned flux and the wild type flux
    assert(abs(totalFluxDiff - norm(fluxROOM - fluxWT)) < tol);
    assert(abs(totalFluxDiff - norm(expectedFlux(0.03, 0.001) - fluxWT)) < tol);

    %% delta and epsilon options, a row flux vector, objTol set in CBT_LP_PARAMS
    % proves that the band follows delta and epsilon (optimum f = 10 - epsilon for delta 0)
    % and that a row vector is accepted; printLevel 0 gives the same result as the default
    % because printLevel is ignored (defect above)
    CBT_LP_PARAMS = savedLPParams;
    CBT_LP_PARAMS.objTol = 1e-6;
    [fluxROOM, solutionROOM, totalFluxDiff] = linearROOM(model, fluxWT', {'R1'}, ...
        'delta', 0, 'epsilon', 0.5, 'printLevel', 0);
    assert(solutionROOM.stat == 1);
    assert(norm(model.S * fluxROOM) < tol);
    assert(norm(fluxROOM - expectedFlux(0, 0.5)) < tol);
    assert(abs(solutionROOM.f - expectedObjective(0, 0.5)) < tol);
    assert(abs(totalFluxDiff - norm(expectedFlux(0, 0.5) - fluxWT)) < tol);
    CBT_LP_PARAMS = savedLPParams;

    %% an infeasible knock-out returns NaN
    % EX_B must carry at least 5 and its only supply EX_A is knocked out
    modelForced = changeRxnBounds(model, 'EX_B', 5, 'l');
    [fluxROOM, solutionROOM, totalFluxDiff] = linearROOM(modelForced, fluxWT, {'EX_A'});
    assert(solutionROOM.stat ~= 1);
    assert(isequal(size(fluxROOM), [4, 1]) && all(isnan(fluxROOM)));
    assert(isnan(totalFluxDiff));
end

%% input checks (no solver call is reached)
% a flux vector of the wrong length, a flux vector off steady state, an unknown reaction
assert(verifyCobraFunctionError('linearROOM', 'inputs', {model, [10; 10; 10], {'R1'}}, ...
    'testMessage', 'This flux distribution has different number of reactions than the model'));
assert(verifyCobraFunctionError('linearROOM', 'inputs', {model, [10; 10; 0; 9], {'R1'}}, ...
    'testMessage', 'This flux distribution cannot exist in this model'));
assert(verifyCobraFunctionError('linearROOM', 'inputs', {model, fluxWT, {'R9'}}, ...
    'testMessage', 'Some reactions are not in the model'));
% the input parser rejects a reaction list that is not a cell and a non-numeric flux
assert(verifyCobraFunctionError('linearROOM', 'inputs', {model, fluxWT, 'R1'}));
assert(verifyCobraFunctionError('linearROOM', 'inputs', {model, {'10'}, {'R1'}}));

% restore the LP parameters, the solver state, the globals and the directory
CBT_LP_PARAMS = savedLPParams;
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
for i = 1:numel(newGlobals)
    clear('global', newGlobals{i});
end
cd(currentDir)
