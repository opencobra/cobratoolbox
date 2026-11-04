% The COBRAToolbox: testCycleFreeFlux.m
%
% Purpose:
%     - Test whether cycleFreeFlux removes flux around stoichiometrically
%       balanced cycles from FBA solutions for the E. coli core model
%
% Function under test:
%     src/analysis/thermo/thermoFBA/cycleFreeFlux.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation; ecoli_core_model and a five-reaction toy model with one cycle.
%     Assertions check the flux vector of the toy model, whose cycle-free solution is unique
%     (the tolerance 1e-4 covers the perturbation of the bounds by feasTol), and the printed
%     diagnostics of each branch. Anything written goes to a temporary folder.
%
% Coverage exemptions:
%     Lines 237-238: unreachable, they follow an unconditional error, which the test does reach.
%     Lines 287, 308, 489-490, 559-561, 731, 760-761, 765-773, 779-781, 839, 860-865, 870-875, 893, 914, 931-932, 970: the bodies of `if 0` blocks, or the else of an `if 1`.
%     Lines 418-420, 545-553: the else of an `if 1`.
%     Lines 327, 330: unreachable, the main function always sets param.approach and param.printLevel.
%     Lines 629-634, 847-852, 883-888: unreachable, the flux bounds are equal at these points and the bounds of the auxiliary variables are at least 10 apart, so no two bounds are closer than feasTol.
%     Lines 708, 719, 947, 958: unreachable, the auxiliary variables have lb = 0 and a positive ub, and the bounds of the fluxes were just made consistent or raised an error at line 703 or 942.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Lower bounds are checked only when an upper bound is violated
%       SEVERITY: wrong-result
%       TRIGGER: cycleFreeFlux with param.debug = 1 and a flux vector below a lower bound and within its upper bounds; or two flux vectors with an upper bound violated
%       OBSERVED: line 184 tests bool_ub instead of bool_lb, so a violated lower bound passes unnoticed, and a violated upper bound always gives the warning about lower bounds; line 183 compares with the whole matrix V0, not with v0
%       EXPECTED: each flux vector is checked against its lower bounds, as it is against the upper bounds
%       LINES: 183, 184
%     - DEFECT: The objective bound of the lp approach is tightened when it should be relaxed
%       SEVERITY: wrong-result
%       TRIGGER: param.approach = 'lp' with osenseStr 'min' and a positive objective value c0'*v0
%       OBSERVED: the constraint c0'*v <= (1 - feasTol)*c0'*v0 excludes v0, and the exchange fluxes are fixed, so the problem is infeasible and the regularised approach is used instead, with a warning
%       EXPECTED: the bound lets the flux vector keep its objective value
%       LINES: 802, 813
%     - DEFECT: The relaxedFBA fallback of the regularised approach can never succeed
%       SEVERITY: unusable-option
%       TRIGGER: any regularised problem that gurobi finds infeasible, as a flux vector that takes up more than it excretes
%       OBSERVED: relaxedFBA stops in verifyModel, because qp has no mets or rxns, so the error is caught and no relaxed solution is ever used
%       EXPECTED: the relaxed solution is returned
%       LINES: 513-516, 518-520
%     - DEFECT: The analysis of an infeasible problem under param.debug stops at its first step
%       SEVERITY: unusable-option
%       TRIGGER: param.debug = 1 with a linear approach on a problem that stays infeasible when relaxed
%       OBSERVED: relaxedFBA stops in verifyModel, because the problem has no mets or rxns, so the rest of the analysis never runs
%       EXPECTED: the three relaxations and the printed measures of infeasibility
%       LINES: 1032-1072
%     - DEFECT: A solution of the relaxed problem under param.debug is dropped
%       SEVERITY: wrong-result
%       TRIGGER: param.debug = 1 with a linear approach on an infeasible problem that the bounds relaxed by feasTol*10 make feasible
%       OBSERVED: it prints that a solution was found, then line 1076 sets v1 = [] with the warning that no solution was found, so the regularised approach is run instead
%       EXPECTED: the solution of the relaxed problem is returned
%       LINES: 1012, 1076
%     - DEFECT: param.removeFixedBool = 1 stops the regularised approach
%       SEVERITY: error
%       TRIGGER: param.approach = 'regularised' with param.removeFixedBool = 1; or param.approach = 'lp0' with it and non-zero exchange fluxes, which is infeasible and falls back on regularised
%       OBSERVED: error "Unrecognized function or variable 'fixedBool'", which only the two linear approaches define
%       EXPECTED: the option has no effect on the regularised approach, or removes its fixed variables
%       LINES: 991
%
% Authors:
%     - Original file: Hulda S. Haraldsdottir 03/08/2018
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

global CBTDIR

% define the features required to run the test

% require the specified toolboxes and solvers, along with a UNIX OS
% linprog does not seem to work properly on this problem...
% quadMinos and dqqMinos seem to have problems with this rproblem too,
% leading to suboptimal solutions.
solverPkgs = prepareTest('needsLP', true, 'needsQP', true, 'excludeSolvers',{'matlab','dqqMinos','quadMinos','pdco', 'ibm_cplex'});

% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which(mfilename)));

% set the tolerance
tol = getCobraSolverParams('LP', 'feasTol');

% load the model
%Either:
origmodel = getDistributedModel('ecoli_core_model.mat'); %For all models in the test/models folder and subfolders
%Set the default solver
changeCobraSolver(solverPkgs.LP{1},'LP');

[~, isInternalRxn] = findStoichConsistentSubset(origmodel, 0, 0);
cycleRxns = {'FRD7'; 'SUCDi'}; % Form a stoichiometrically balanced cycle
isCycleRxn = ismember(origmodel.rxns, cycleRxns);

relaxBoundsPassCount = 0;
relaxBoundsFailSolvers = {};

for k = 1:length(solverPkgs.LP)
    fprintf(' -- Running testCycleFreeFlux using the solver interface: %s ... ', solverPkgs.LP{k});

    solverLPOK = changeCobraSolver(solverPkgs.LP{k}, 'LP', 0);
    model = origmodel;
    if solverLPOK
        % Remove cycle from a single FBA solution
        solution = optimizeCbModel(model);
        v1 = cycleFreeFlux(solution.v, model.c, model, isInternalRxn);
        d1 = v1 - solution.v;
        % assert, that the cycle free variant does not contain a cycle.
        assert(norm(v1(isCycleRxn)) - 5.0643756 < 1e-4);        
        assert(all(d1(~isCycleRxn) <= tol*10));%decide if all non-cycled rxns have non-cycled flux
        
        % Attempt to remove a forced cycle
        model.lb(find(isCycleRxn, 1)) = 1000; % Force flux through FRD7
        solution = optimizeCbModel(model);
        
        param.relaxBounds = false; % Default
        v2 = cycleFreeFlux(solution.v, model.c, model, isInternalRxn, param);
        d2 = v2 - solution.v;
        assert(all(d2 <= tol*10));
        
        param.relaxBounds = true; % Relax flux bounds that do not include 0
        try
            v3 = cycleFreeFlux(solution.v, model.c, model, isInternalRxn, param);
            d3 = v3 - solution.v;
            assert(norm(v3(isCycleRxn)) - 5.0643756 < 1e-4);        
            assert(all(d3(~isCycleRxn) <= tol*10)); %decide if all non-cycled rxns have non-cycled flux
            relaxBoundsPassCount = relaxBoundsPassCount + 1;
        catch ME
            if contains(ME.message, 'Relaxed model may not admit a steady state. relaxedFBA failed')
                relaxBoundsFailSolvers{end+1} = solverPkgs.LP{k};
                fprintf('Skipping relaxBounds=true branch for solver %s: %s\n', solverPkgs.LP{k}, ME.message);
            else
                rethrow(ME);
            end
        end
        
        % Remove cycle from a set of flux vectors
        model.lb(find(isCycleRxn, 1)) = 0; % Reset lower bound on FRD7
        [minFlux, maxFlux, Vmin, Vmax] = fluxVariability(model, 0, 'max', model.rxns(1:3), 0, 1, 'FBA');
        V0 = [Vmin, Vmax];
        n = size(model.S, 2);
        C = [eye(n), eye(n)];
        param.relaxBounds = false;
        V1 = cycleFreeFlux(V0, C, model, isInternalRxn, param);
        D1 = V1 - V0;
        assert(norm(V1(isCycleRxn)) - 5.0643756 < 1e-4); 
        bool = all(D1(~isCycleRxn, :) <= 1e-4);
        if ~all(bool)
            fprintf('Cycle-free flux calculation failed for %s th set(s) of solution, likely infeasible \n',num2str(find(~bool)));
        end   
    end

    % output a success message
    fprintf('Done.\n');
end

if relaxBoundsPassCount == 0
    if ~isempty(relaxBoundsFailSolvers)
        error('testCycleFreeFlux: relaxBounds=true failed for all tested LP solvers (%s).', strjoin(unique(relaxBoundsFailSolvers), ', '));
    else
        error('testCycleFreeFlux: relaxBounds=true branch was not executed successfully for any LP solver.');
    end
end

% The sections below use a toy model with the cycle R1, R2, R3 and write to a temporary folder
changeCobraSolver(solverPkgs.LP{1}, 'LP', 0);
changeCobraSolver(solverPkgs.QP{1}, 'QP', 0);
testDir = pwd;
workDir = tempname;
mkdir(workDir);
stubDir = tempname;
mkdir(stubDir);
figuresBefore = findall(0, 'Type', 'figure');
restoreState = onCleanup(@() leaveToySections(testDir, {workDir, stubDir}));
cd(workDir);

% A -> B -> C -> A is the cycle, with an uptake of A and an excretion of C
toyModel = struct();
toyModel.S = sparse([1 -1 0 1 0; 0 1 -1 0 0; 0 0 1 -1 -1]);
toyModel.mets = {'A'; 'B'; 'C'};
toyModel.rxns = {'EX_A'; 'R1'; 'R2'; 'R3'; 'EX_C'};
toyModel.lb = [0; -1000; -1000; -1000; 0];
toyModel.ub = [10; 1000; 1000; 1000; 10];
toyModel.c = [0; 0; 0; 0; 1];
toyModel.b = zeros(3, 1);
toyModel.csense = ['E'; 'E'; 'E'];
toyModel.osenseStr = 'max';
toyInternal = logical([0; 1; 1; 1; 0]);
toyFlux = [1; 3; 3; 2; 1]; % a steady state in which 2 units go around the cycle
toyCycleFree = [1; 1; 1; 0; 1]; % the same exchange fluxes without the cycle
toyTol = 1e-4;
isCycleFree = @(v) norm(v - toyCycleFree, inf) < toyTol;

%% Where the internal reactions come from when they are not given
modelWithBools = toyModel;
modelWithBools.SConsistentRxnBool = toyInternal;
modelWithBools.SConsistentMetBool = true(3, 1);
assert(isCycleFree(cycleFreeFlux(toyFlux, toyModel.c, modelWithBools)), 'model.SConsistentRxnBool must be used.');
modelWithIntBool = toyModel;
modelWithIntBool.SIntRxnBool = toyInternal;
lastwarn('');
assert(isCycleFree(cycleFreeFlux(toyFlux, toyModel.c, modelWithIntBool)), 'model.SIntRxnBool must be used.');
assert(contains(lastwarn, 'Assuming SConsistentMetBool and SConsistentRxnBool heuristically'), ...
    'Using model.SIntRxnBool must raise a warning.');
modelWithBiomass = toyModel;
modelWithBiomass.biomassRxnAbbr = 'EX_C';
assert(isCycleFree(cycleFreeFlux(toyFlux, toyModel.c, modelWithBiomass)), ...
    'The consistent reactions must be computed when the model does not hold them.');
assert(isCycleFree(cycleFreeFlux(toyFlux, toyModel.c, toyModel)), ...
    'The consistent reactions must be computed when the model does not hold them.');

%% Optional fields and parameters take their defaults
bareModel = rmfield(rmfield(toyModel, 'b'), 'csense');
[vBare, consistentBare] = cycleFreeFlux(toyFlux, toyModel.c, bareModel, toyInternal, ...
    struct('eta', 1e-3, 'printLevel', 1));
assert(isCycleFree(vBare), 'model.b and model.csense must default to a steady state.');
assert(isequal(consistentBare, abs(vBare - toyFlux) < 1e-3), ...
    'A flux is thermodynamically consistent when it moved by less than eta.');

%% Every approach removes the cycle, for an objective and for none, and with coupling constraints
coupledModel = toyModel;
coupledModel.C = sparse([0 1 0 0 0]);
coupledModel.d = 2;
coupledModel.dsense = 'L';
for approach = {'regularised', 'lp', 'lp0'}
    approachParam = struct('approach', approach{1});
    assert(isCycleFree(cycleFreeFlux(toyFlux, toyModel.c, toyModel, toyInternal, approachParam)), ...
        sprintf('%s must remove the cycle.', approach{1}));
    assert(isCycleFree(cycleFreeFlux(toyFlux, 0*toyModel.c, toyModel, toyInternal, approachParam)), ...
        sprintf('%s must remove the cycle without an objective.', approach{1}));
    approachParam.enforceCoupling = 1;
    vCoupled = cycleFreeFlux(toyFlux, toyModel.c, coupledModel, toyInternal, approachParam);
    assert(isCycleFree(vCoupled) && coupledModel.C*vCoupled <= coupledModel.d + toyTol, ...
        sprintf('%s must remove the cycle and keep the coupling constraint.', approach{1}));
    vCoupled = cycleFreeFlux(toyFlux, 0*toyModel.c, coupledModel, toyInternal, approachParam);
    assert(isCycleFree(vCoupled) && coupledModel.C*vCoupled <= coupledModel.d + toyTol, ...
        sprintf('%s must keep the coupling constraint without an objective.', approach{1}));
end

%% Relaxed bounds in the linear approaches, on forward and on reverse fluxes
reverseFlux = [1; -1; -1; -2; 1]; % 1 unit reversed around the cycle
reverseCycleFree = [1; 0; 0; -1; 1];
for approach = {'lp', 'lp0'}
    relaxedParam = struct('approach', approach{1}, 'relaxBounds', true);
    assert(isCycleFree(cycleFreeFlux(toyFlux, 0*toyModel.c, toyModel, toyInternal, relaxedParam)), ...
        sprintf('%s must remove the cycle with relaxed bounds.', approach{1}));
    vReverse = cycleFreeFlux(reverseFlux, 0*toyModel.c, toyModel, toyInternal, relaxedParam);
    assert(norm(vReverse - reverseCycleFree, inf) < toyTol, ...
        sprintf('%s must remove a reversed cycle with relaxed bounds.', approach{1}));
end

%% A minimised objective: a negative objective value, for which the bound is not too tight
minimisedModel = toyModel;
minimisedModel.osenseStr = 'min';
for approach = {'regularised', 'lp', 'lp0'}
    vMin = cycleFreeFlux(toyFlux, -toyModel.c, minimisedModel, toyInternal, struct('approach', approach{1}));
    assert(isCycleFree(vMin), sprintf('%s must remove the cycle when minimising.', approach{1}));
end

%% Fixed variables can be moved to the right hand side in the two linear approaches
fixedParam = struct('approach', 'lp', 'removeFixedBool', 1);
assert(isCycleFree(cycleFreeFlux(toyFlux, toyModel.c, toyModel, toyInternal, fixedParam)), ...
    'Removing the fixed variables must not change the result of lp.');
% lp0 keeps exchange fluxes free within feasTol, so here they are zero, thus exactly fixed
purelyCyclicFlux = [0; 1; 1; 1; 0];
vFixed = cycleFreeFlux(purelyCyclicFlux, toyModel.c, toyModel, toyInternal, ...
    struct('approach', 'lp0', 'removeFixedBool', 1));
assert(norm(vFixed, inf) < toyTol, 'A purely cyclic flux must vanish.');
vFixed = cycleFreeFlux(purelyCyclicFlux, toyModel.c, toyModel, toyInternal, ...
    struct('approach', 'lp0', 'removeFixedBool', 2));
assert(norm(vFixed, inf) < toyTol, 'Any other value of removeFixedBool leaves the problem as it is.');

%% param.debug checks the model and the flux vector before solving
debugParam = struct('debug', 1, 'printLevel', 1);
callWithDebug = @(v, model) cycleFreeFlux(v, model.c, model, toyInternal, debugParam);
invertedBounds = toyModel;
invertedBounds.lb(2) = 2000;
assert(verifyCobraFunctionError('cycleFreeFlux', 'inputs', {toyFlux, toyModel.c, invertedBounds, toyInternal, debugParam}, ...
    'testMessage', 'Model Lower bounds cannot be greater than upper bounds'));
noSteadyState = toyModel;
noSteadyState.ub(1) = 0;
noSteadyState.lb(5) = 1;
assert(verifyCobraFunctionError('cycleFreeFlux', 'inputs', {toyFlux, toyModel.c, noSteadyState, toyInternal, debugParam}, ...
    'testMessage', 'Model does not admit a steady state flux'));
assert(verifyCobraFunctionError('cycleFreeFlux', 'inputs', {[1; 3; 3; 2; 2], toyModel.c, toyModel, toyInternal, debugParam}, ...
    'testMessage', 'Solution provided is not a steady state'));
aboveUpperBound = toyModel;
aboveUpperBound.ub(2:4) = 1.5;
assert(verifyCobraFunctionError('cycleFreeFlux', 'inputs', {toyFlux, toyModel.c, aboveUpperBound, toyInternal, debugParam}, ...
    'testMessage', 'Input flux vector majorly violated upper bounds, in 1th flux vector'));

% within feasTol of the upper bound the flux is moved onto it, with a warning
tinyStep = 1e-7;
slightlyAbove = toyModel;
slightlyAbove.ub(2) = 3;
consoleText = evalc('vAbove = callWithDebug([1; 3 + tinyStep; 3 + tinyStep; 2 + tinyStep; 1], slightlyAbove);');
assert(isCycleFree(vAbove), 'A flux slightly above its upper bound must be accepted.');
% warnings captured from the console are wrapped at its width
oneLine = @(text) regexprep(text, '\s+', ' ');
assert(contains(oneLine(consoleText), 'minorly violated upper bounds'), 'The small violation must raise a warning.');

% the lower bounds are checked when an upper bound is violated
belowLowerBound = slightlyAbove;
belowLowerBound.ub(2) = 3;
belowLowerBound.lb(4) = 3;
assert(verifyCobraFunctionError('cycleFreeFlux', 'inputs', {[1; 3 + tinyStep; 3 + tinyStep; 2 + tinyStep; 1], ...
    toyModel.c, belowLowerBound, toyInternal, debugParam}, ...
    'testMessage', 'Input flux vector  solution majorly violated lower bounds, in 1th flux vector'));
slightlyBelow = slightlyAbove;
slightlyBelow.lb(4) = 2 + 2*tinyStep;
lastwarn('');
callWithDebug([1; 3 + tinyStep; 3 + tinyStep; 2 + tinyStep; 1], slightlyBelow);
assert(contains(lastwarn, 'minorly violated lower bounds'), 'The small violation must raise a warning.');

% several flux vectors are checked one by one, printing the index
consoleText = evalc('vTwo = cycleFreeFlux([toyFlux, toyFlux], [toyModel.c, toyModel.c], toyModel, toyInternal, struct(''debug'', 1));');
assert(size(vTwo, 2) == 2 && isCycleFree(vTwo(:, 2)), 'Each flux vector must be repaired.');
assert(contains(consoleText, '2'), 'The index of each flux vector must be printed.');

%% param.parallelize: not worth it for up to 12 vectors, refused beyond when workers are available
parallelParam = struct('parallelize', true);
assert(isCycleFree(cycleFreeFlux(toyFlux, toyModel.c, toyModel, toyInternal, parallelParam)), ...
    'With one flux vector the loop must run serially.');
if isParallelToolboxAvailable()
    assert(verifyCobraFunctionError('cycleFreeFlux', 'inputs', {repmat(toyFlux, 1, 13), ...
        repmat(toyModel.c, 1, 13), toyModel, toyInternal, parallelParam}, ...
        'testMessage', 'param.parallelize = true not fully supported, set param.parallelize = false'));
end

%% Forced reactions: a flux on the forcing bound is not thermodynamically consistent
% with param.relaxBounds, a flux below the forcing lower bound is still not consistent
forcedForward = toyModel;
forcedForward.lb(2) = 1;
justBelow = [1; 1; 1; 0; 1] - 1e-7*[1; 1; 1; 0; 1];
[vForced, consistentForced] = cycleFreeFlux(justBelow, toyModel.c, forcedForward, toyInternal, ...
    struct('relaxBounds', true));
assert(norm(vForced - justBelow, inf) < toyTol && ~consistentForced(2), ...
    'Below its forcing lower bound a forced reaction must not count as consistent.');
forcedReverse = toyModel;
forcedReverse.ub(4) = -1;
justAbove = [1; 0; 0; -1; 1] - 1e-7*[1; 0; 0; -1; 1];
[vForced, consistentForced] = cycleFreeFlux(justAbove, toyModel.c, forcedReverse, toyInternal, ...
    struct('relaxBounds', true));
assert(norm(vForced - justAbove, inf) < toyTol && ~consistentForced(4), ...
    'Above its forcing upper bound a forced reaction must not count as consistent.');

%% An infeasible linear problem falls back on the regularised approach
% the excretion exceeds what enters: fixed exchange fluxes rule out a steady state
unbalancedFlux = [1; 3; 3; 0; 5];
for approach = {'lp', 'lp0'}
    lastwarn('');
    consoleText = evalc(['vFallback = cycleFreeFlux(unbalancedFlux, toyModel.c, toyModel, toyInternal, ' ...
        'struct(''approach'', approach{1}));']);
    assert(contains(consoleText, 'lp error, switching to regularised approach.'), ...
        sprintf('%s must fall back on the regularised approach.', approach{1}));
    assert(any(vFallback), 'The regularised approach must return a flux vector.');
end
% a forced reaction on its bound in the fallback does not count as consistent
forcedFallback = toyModel;
forcedFallback.lb(2) = 3;
forcedFallback.ub(4) = -1;
[~, consistentFallback] = cycleFreeFlux([1; 3; 3; -1; 5], toyModel.c, forcedFallback, toyInternal, struct('approach', 'lp'));
assert(~consistentFallback(2) && ~consistentFallback(4), ...
    'A forced reaction on its bound must not count as consistent in the fallback.');

%% No approach succeeds: the flux stays zero, and the failure is printed
% the uptake exceeds what leaves, which the slack of the regularised steady state cannot absorb
infeasibleFlux = [5; 3; 3; 2; 1];
consoleText = evalc(['vNone = cycleFreeFlux(infeasibleFlux, toyModel.c, toyModel, toyInternal, ' ...
    'struct(''approach'', ''lp'', ''printLevel'', 2));']);
assert(all(vNone == 0), 'Without a solution the flux vector must stay zero.');
assert(contains(consoleText, 'No quadratically regularised solution found. Relaxing LP version...'), ...
    'The failure of the regularised problem must be printed.');
assert(contains(consoleText, 'regularised approach failed, likely infeasible.'), ...
    'The failure of the fallback must be printed.');
assert(contains(consoleText, 'relaxedFBA fallback failed'), 'The failure of relaxedFBA must be printed.');

%% Bounds that are inconsistent with the flux
% slightly: the lower bound is lowered to the upper bound, with a message
slightModel = toyModel;
slightModel.lb(2:3) = 1;
slightFlux = [1 - 1e-7; 1 - 1e-7; 1 - 1e-7; 0; 1 - 1e-7];
for approach = {'lp', 'lp0'}
    consoleText = evalc(['vSlight = cycleFreeFlux(slightFlux, toyModel.c, slightModel, toyInternal, ' ...
        'struct(''approach'', approach{1}, ''printLevel'', 2));']);
    assert(contains(consoleText, '#5 Lower bounds slightly greater than upper bounds, set to the same.'), ...
        sprintf('%s must report the bounds it set to the same value.', approach{1}));
    assert(norm(vSlight - slightFlux, inf) < toyTol, 'The flux must be kept.');
end
% a lot: an error in the linear approaches, and then the regularised approach is infeasible too
wrongFlux = [0.5; 0.5; 0.5; 0; 0.5];
for approach = {'lp', 'lp0'}
    consoleText = evalc(['vWrong = cycleFreeFlux(wrongFlux, toyModel.c, slightModel, toyInternal, ' ...
        'struct(''approach'', approach{1}));']);
    assert(contains(consoleText, 'cycleFreeFlux: Lower bounds cannot be greater than upper bounds'), ...
        sprintf('%s must report the bounds.', approach{1}));
    assert(all(vWrong == 0), 'Without a solution the flux vector must stay zero.');
end
% an inverted model bound is an error both times, so it reaches the caller
assert(verifyCobraFunctionError('cycleFreeFlux', 'inputs', {toyFlux, toyModel.c, invertedBounds, toyInternal}, ...
    'testMessage', 'Model lower bounds cannot be greater than upper bounds'));
% bounds closer than the feasibility tolerance are worth a warning
closeBounds = toyModel;
closeBounds.lb(2) = 3 - 1e-7;
closeBounds.ub(2) = 3;
lastwarn('');
cycleFreeFlux(toyFlux, toyModel.c, closeBounds, toyInternal);
assert(contains(lastwarn, 'Unperturbed lower and upper bounds closer than feasibility tolerance'), ...
    'Bounds closer than the feasibility tolerance must raise a warning.');
% flux below feasTol/100 is taken as zero, and printed at this print level
consoleText = evalc('cycleFreeFlux(purelyCyclicFlux, toyModel.c, toyModel, toyInternal, struct(''printLevel'', 2));');
assert(contains(consoleText, 'cycleFreeFlux: Assuming flux in 2 reactions'), ...
    'The fluxes taken as zero must be reported.');

%% param.debug prints what it sees in the bounds of the linear problems
% a small exchange flux is free within a range smaller than feasTol
smallFlux = [0.1; 0.1; 0.1; 0; 0.1];
consoleText = evalc('cycleFreeFlux(smallFlux, toyModel.c, toyModel, toyInternal, struct(''approach'', ''lp0'', ''debug'', 2));');
assert(contains(consoleText, '#2 Perturbed lower and upper bounds closer than'), ...
    'The small range of the exchange fluxes must be reported.');
% an internal flux just above its forcing bound
nearForced = toyModel;
nearForced.lb(2) = 0.5;
nearFlux = [0.5; 0.5; 0.5; 0; 0.5] + 5e-7;
nearFlux(4) = 0;
consoleText = evalc('cycleFreeFlux(nearFlux, toyModel.c, nearForced, toyInternal, struct(''approach'', ''lp0'', ''debug'', 1));');
assert(contains(consoleText, '#3 Perturbed lower and upper bounds closer than'), ...
    'The small range of a forced flux must be reported.');
consoleText = evalc('cycleFreeFlux(nearFlux, toyModel.c, nearForced, toyInternal, struct(''approach'', ''lp0'', ''debug'', 2));');
assert(contains(consoleText, '#3 Perturbed'), 'The small range must be reported with the plots too.');
nearReverse = toyModel;
nearReverse.ub(4) = -0.5;
nearReverseFlux = [0.5; 0; 0; -0.5; 0.5] - 5e-7*[-1; 0; 0; 1; -1];
consoleText = evalc('cycleFreeFlux(nearReverseFlux, toyModel.c, nearReverse, toyInternal, struct(''approach'', ''lp0'', ''debug'', 1));');
assert(contains(consoleText, '#4 Perturbed lower and perturbed upper bounds closer'), ...
    'The small range of a reverse forced flux must be reported.');
% a flux smaller than feasTol, with either sign, in both approaches
tinyFlux = [0; 5e-7; 5e-7; 5e-7; 0];
consoleText = evalc('cycleFreeFlux(tinyFlux, 0*toyModel.c, toyModel, toyInternal, struct(''approach'', ''lp'', ''debug'', 2));');
assert(contains(consoleText, 'reactions is between') && contains(consoleText, '#3 Perturbed'), ...
    'Small fluxes must be reported.');
consoleText = evalc('cycleFreeFlux(-tinyFlux, 0*toyModel.c, toyModel, toyInternal, struct(''approach'', ''lp'', ''debug'', 2));');
assert(contains(consoleText, '#4 Perturbed'), 'Small reverse fluxes must be reported.');
consoleText = evalc('cycleFreeFlux(tinyFlux, 0*toyModel.c, toyModel, toyInternal, struct(''approach'', ''lp0'', ''debug'', 1));');
assert(contains(consoleText, 'so they are bound between'), 'Small fluxes must be reported.');
% regularised, with its plots
regularisedPlots = cycleFreeFlux(toyFlux, toyModel.c, toyModel, toyInternal, ...
    struct('debug', 1, 'printLevel', 3));
assert(isCycleFree(regularisedPlots), 'The plots must not change the result.');

%% param.debug on a linear problem that has no solution
% a row with an inequality sense is not part of the steady state check of param.debug
inequalityModel = toyModel;
inequalityModel.csense = ['E'; 'E'; 'G'];
% within 1e-5 of feasible: the relaxed problem has a solution
almostFlux = [1 + 1e-5; 1 + 1e-5; 1 + 1e-5; 0; 1 + 2e-5];
consoleText = evalc(['cycleFreeFlux(almostFlux, 0*toyModel.c, inequalityModel, toyInternal, ' ...
    'struct(''approach'', ''lp0'', ''debug'', 1));']);
assert(contains(consoleText, 'so relaxing bounds by feasTol*10') && contains(consoleText, '...solution found.'), ...
    'The relaxed problem must be solved.');
% far from feasible: the problem is written to a file and analysed
farFlux = [1; 1; 1; 0; 2];
consoleText = evalc(['cycleFreeFlux(farFlux, 0*toyModel.c, inequalityModel, toyInternal, ' ...
    'struct(''approach'', ''lp0'', ''debug'', 1));']);
assert(contains(consoleText, 'Debugging relaxation etc...'), 'The analysis must be announced.');
assert(isfile('debug_cycleFreeFlux_infeasibility.mat'), 'The problem must be saved to the current folder.');
% the regularised problem, with param.debug: a row less-or-equal cannot use its slack
lessEqualModel = toyModel;
lessEqualModel.csense = ['E'; 'E'; 'L'];
consoleText = evalc(['cycleFreeFlux([1; 1; 1; 0; 0], 0*toyModel.c, lessEqualModel, toyInternal, ' ...
    'struct(''debug'', 1));']);
assert(contains(consoleText, 'No solution found with approach: regularised'), 'The failure must be printed.');

%% A solver that returns an inaccurate or no solution, in place of solveCobraQP
% no input makes gurobi fail on this small problem: the solver is replaced by a function that
% returns the status asked for (status 3, inaccurate, or status 0 with a working LP solver)
fid = fopen(fullfile(stubDir, 'solveCobraQP.m'), 'w');
fprintf(fid, ['function solution = solveCobraQP(qp, varargin)\n' ...
    'solution = struct(''stat'', 3, ''origStatText'', ''NUMERIC'', ''full'', zeros(size(qp.c)));\n' ...
    'solution.full(1:numel(getappdata(0, ''qpFlux''))) = getappdata(0, ''qpFlux'');\n' ...
    'solution.stat = getappdata(0, ''qpStat'');\nend\n']);
fclose(fid);
addpath(stubDir);
rehash path
setappdata(0, 'qpFlux', toyCycleFree);
setappdata(0, 'qpStat', 3);
consoleText = evalc(['vInaccurate = cycleFreeFlux(toyFlux, toyModel.c, toyModel, toyInternal, ' ...
    'struct(''printLevel'', 3));']);
assert(isCycleFree(vInaccurate) && contains(consoleText, 'cycleFreeFlux, regularised: NUMERIC'), ...
    'An inaccurate solution must be accepted and reported.');
setappdata(0, 'qpStat', 0);
consoleText = evalc('vFromLP = cycleFreeFlux(toyFlux, toyModel.c, toyModel, toyInternal);');
assert(isCycleFree(vFromLP) && contains(consoleText, 'Relaxing LP version...'), ...
    'Without a regularised solution the linear version must give the result.');
rmpath(stubDir);
rmappdata(0, 'qpFlux');
rmappdata(0, 'qpStat');
rehash path

close(setdiff(findall(0, 'Type', 'figure'), figuresBefore));

% change the directory, remove the temporary folders
clear restoreState

% change the directory
cd(currentDir)

function leaveToySections(folder, temporaryFolders)
% Back to the folder of the test, on every exit from the sections of the toy model.
cd(folder);
cellfun(@(d) rmdir(d, 's'), temporaryFolders);
end
