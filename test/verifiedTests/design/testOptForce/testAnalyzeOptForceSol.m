% The COBRAToolbox: testAnalyzeOptForceSol.m
%
% Purpose:
%     - analyzeOptForceSol(model, targetRxn, biomassRxn, solution, relax, tol) fixes each
%       intervened reaction of solution at its flux, maximises the growth rate of this mutant and
%       returns the minimum and maximum production of the target at that growth rate (the growth
%       rate rounded down to a multiple of tol when relax is 1). An infeasible mutant gives a
%       warning and a target range of 0.
%     - Input: a hand-built 7-reaction model: a fixed glucose uptake of 10 is split between
%       growth (R1 -> BIO, at most 6.5), the target (R2 -> EX_prod) and a by-product
%       (R3 -> EX_byp). Every expected value is derived by hand from the mass balance
%       R1 + R2 + R3 = 10 with R1 <= 6.5.
%
% Function under test:
%     src/design/optForce/analyzeOptForceSol.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - solves LPs (optimizeCbModel) on a hand-built model; every available LP solver
%     among gurobi and glpk.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The example of the help text names R21 twice
%       SEVERITY: cosmetic
%       TRIGGER: the help text of the input solution
%       OBSERVED: "the reaction R21 will be regulated at 10 ... and R21 will be regulated at 0"
%         for the example with the reactions R21 and R24
%       EXPECTED: the second reaction of the example is R24
%       LINES: 33-35
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAnalyzeOptForceSol'));
cd(fileDir);

% the solver functions create global variables; the ones that did not exist before are removed
% at the end
globalsBefore = who('global');

% require an LP solver; skip gracefully if none is available
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
initialSolverState = CobraSolverState.get();

% LP results of this small model are exact up to the solver's feasibility tolerance (1e-9 or
% better); 1e-6 also absorbs the rounding of the growth rate down to a multiple of tol = 1e-7
tol = 1e-6;

% the model: glucose uptake fixed at 10, growth limited to 6.5 by the bound of R1
model = createModel({'EX_glc', 'R1', 'R2', 'R3', 'BIO', 'EX_prod', 'EX_byp'}, ...
    {'', '', '', '', '', '', ''}, ...
    {' -> glc[c]', 'glc[c] -> bp[c]', 'glc[c] -> prod[c]', 'glc[c] -> byp[c]', 'bp[c] -> ', ...
    'prod[c] -> ', 'byp[c] -> '}, ...
    'lowerBoundList', [10 0 0 0 0 0 0], 'upperBoundList', [10 6.5 1000 1000 1000 1000 1000], ...
    'printLevel', 0);

noInterventions = struct('reactions', {{}}, 'flux', []);
knockoutR3 = struct('reactions', {{'R3'}}, 'flux', 0);

for k = 1:numel(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if ~solverOK
        continue
    end
    fprintf('   Testing analyzeOptForceSol using %s ... \n', solvers.LP{k});

    %% no intervention, default relax and tol
    % growth is 6.5 (bound of R1); at that rate 3.5 of glucose is left, which can all go to the
    % target or all to the by-product: the target range is [0, 3.5]. The growth rate is rounded
    % down by less than tol = 1e-7, which widens the maximum by less than 1e-7
    [maxGrowthRate, minTarget, maxTarget] = analyzeOptForceSol(model, 'EX_prod', 'BIO', noInterventions);
    assert(abs(maxGrowthRate - 6.5) < tol);
    assert(abs(minTarget) < tol);
    assert(abs(maxTarget - 3.5) < tol);

    %% knockout of the by-product, relax with a coarse tolerance
    % with relax = 1 and tol = 1 the growth rate 6.5 is rounded down to 6, so the growth may lie
    % in [6, 6.5] and the target, 10 - R1 without by-product, in [3.5, 4]
    [maxGrowthRate, minTarget, maxTarget] = analyzeOptForceSol(model, 'EX_prod', 'BIO', knockoutR3, 1, 1);
    assert(abs(maxGrowthRate - 6.5) < tol);
    assert(abs(minTarget - 3.5) < tol);
    assert(abs(maxTarget - 4) < tol);

    %% knockout of the by-product, exact growth rate (relax = 0)
    % the growth is held at 6.5, so the target is fixed at 3.5
    [maxGrowthRate, minTarget, maxTarget] = analyzeOptForceSol(model, 'EX_prod', 'BIO', knockoutR3, 0);
    assert(abs(maxGrowthRate - 6.5) < tol);
    assert(abs(minTarget - 3.5) < tol);
    assert(abs(maxTarget - 3.5) < tol);

    %% two interventions: upregulation of the target and knockout of the by-product
    % R2 = 4 and R3 = 0 leave 6 for growth; the target is fixed at 4
    upAndKnockout = struct('reactions', {{'R2'; 'R3'}}, 'flux', [4; 0]);
    [maxGrowthRate, minTarget, maxTarget] = analyzeOptForceSol(model, 'EX_prod', 'BIO', upAndKnockout);
    assert(abs(maxGrowthRate - 6) < tol);
    assert(abs(minTarget - 4) < tol);
    assert(abs(maxTarget - 4) < tol);

    %% infeasible mutant: warning and a target range of 0
    % R2 = 2 and R3 = 0 force R1 = 8 above its bound 6.5; the growth LP has no solution, so no
    % growth rate is returned (NaN) and both target values are 0
    infeasibleSet = struct('reactions', {{'R2'; 'R3'}}, 'flux', [2; 0]);
    lastwarn('');
    [maxGrowthRate, minTarget, maxTarget] = analyzeOptForceSol(model, 'EX_prod', 'BIO', infeasibleSet);
    assert(strcmp(lastwarn, 'OptForce: infeasible model for mutant strain, according to function analyzeOptForceSol'));
    assert(isnan(maxGrowthRate));
    assert(minTarget == 0 && maxTarget == 0);
end

%% input checks raise their documented errors
% they stop before any LP is solved
assert(verifyCobraFunctionError('analyzeOptForceSol', 'inputs', {}, ...
    'testMessage', 'OptForce: model must be specified when running analyzeOptForceSol'));
modelFields = {'S', 'rxns', 'mets', 'lb', 'ub', 'c', 'b'};
for i = 1:numel(modelFields)
    assert(verifyCobraFunctionError('analyzeOptForceSol', 'inputs', {rmfield(model, modelFields{i})}, ...
        'testMessage', ['OptForce: Missing field ' modelFields{i} ' in model']));
end
assert(verifyCobraFunctionError('analyzeOptForceSol', 'inputs', {model}, ...
    'testMessage', 'OptForce: target reaction must be specified when running analyzeOptForceSol'));
assert(verifyCobraFunctionError('analyzeOptForceSol', 'inputs', {model, 6}, ...
    'testMessage', 'OptForce: input targetRxn must be an string'));
assert(verifyCobraFunctionError('analyzeOptForceSol', 'inputs', {model, 'EX_prod'}, ...
    'testMessage', 'OptForce: biomassRxn reaction must be specified when running analyzeOptForceSol'));
assert(verifyCobraFunctionError('analyzeOptForceSol', 'inputs', {model, 'EX_prod', 5}, ...
    'testMessage', 'OptForce: input biomassRxn must be an string'));
assert(verifyCobraFunctionError('analyzeOptForceSol', 'inputs', {model, 'EX_prod', 'BIO'}, ...
    'testMessage', 'OptForce: intervened reactions must be specified when running analyzeOptForceSol'));
assert(verifyCobraFunctionError('analyzeOptForceSol', 'inputs', {model, 'EX_prod', 'BIO', struct('flux', 0)}, ...
    'testMessage', 'OptForce: Missing field reactions in solution'));
assert(verifyCobraFunctionError('analyzeOptForceSol', 'inputs', {model, 'EX_prod', 'BIO', struct('reactions', {{'R3'}})}, ...
    'testMessage', 'OptForce: Missing field flux in solution'));

% leave the solver selection and the globals as they were found
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
for k = 1:numel(newGlobals)
    clearvars('-global', newGlobals{k});
end

% change the directory
cd(currentDir)
