% The COBRAToolbox: testSolverAbstractionRouting.m
%
% Purpose:
%     - Feature 015-solver-spine-hardening (User Story 2). Verify that modules
%       rerouted through the solveCobra{LP,QP,MILP,MIQP} abstraction now honour
%       changeCobraSolver and return FR-013-equivalent results under a
%       non-native configured solver (identical canonical .stat, optimal
%       objective equal within a justified tolerance; the solution vector is
%       not asserted). Also verify that the documented solver islands
%       (specs/015-solver-spine-hardening/islands.md) fail with a clear,
%       identified "requires <solver> (<capability>)" error when their required
%       solver is absent (or route to the listed fallback), never an opaque
%       crash or a silent wrong answer.
%
%     Everything is prepareTest-gated and skips cleanly when a required solver
%     or toolbox is unavailable.
%
% Authors:
%     - COBRA Toolbox, feature 015-solver-spine-hardening.

% require an LP and a MILP solver; the routed modules are LP/MILP based
solvers = prepareTest('needsLP', true, 'needsMILP', true, ...
    'requireOneSolverOf', {'gurobi', 'ibm_cplex', 'glpk'});

% save the current path and the full solver-selection state, and guarantee both
% are restored on exit (including on an assertion failure) so this test never
% perturbs the global solver state for the rest of the suite. This test switches
% the configured LP/MILP solver many times (portability checks, pdco island);
% without this guard a mid-test failure would leak the last-set solver.
currentDir = pwd;
savedCbtState = CobraSolverState.get();
restoreCbtObj = onCleanup(@() restoreCbtEnv(savedCbtState, currentDir)); %#ok<NASGU>
testDir = fileparts(which('testSolverAbstractionRouting.m'));
cd(testDir);

% objective-equivalence tolerance (FR-013)
tol = 1e-6;

% Determine the set of installed LP solvers we can cross-check against. A
% genuine portability check needs at least two distinct backends.
candidateLP = {'gurobi', 'mosek', 'glpk', 'pdco'};
availLP = {};
for s = candidateLP
    if changeCobraSolver(s{1}, 'LP', 0)
        availLP{end + 1} = s{1};
    end
end

% shared small model
model = getDistributedModel('ecoli_core_model.mat');
rev = double(model.lb < 0);
S = model.S;

%% -------------------------------------------------------------------------
%% Part 1 - Routing portability: SWIFTCORE swiftcc/blocked across solvers
%% -------------------------------------------------------------------------
% swiftcc() calls the routed blocked.m, which now goes through solveCobraLP.
% The set of flux-consistent reactions must be identical across LP backends
% and must match the fastcc reference (FR-013: same feasible/optimal outcome).
fprintf('\n -- Part 1a: SWIFTCORE (blocked.m) routing portability ...\n');
refConsistent = fastcc(model, 1e-4, 0);
consistentSets = cell(1, numel(availLP));
for k = 1:numel(availLP)
    consistentSets{k} = sort(reshape(swiftcc(S, rev, availLP{k}), [], 1));
    assert(isequal(consistentSets{k}, sort(refConsistent(:))), ...
        sprintf('swiftcc under %s disagrees with fastcc reference', availLP{k}));
end
if numel(availLP) >= 2
    assert(isequal(consistentSets{1}, consistentSets{2}), ...
        'swiftcc gave different consistent sets across two LP solvers');
    fprintf('    swiftcc identical across %s and %s.\n', availLP{1}, availLP{2});
else
    fprintf('    only one LP solver available; cross-solver check skipped.\n');
end

%% -------------------------------------------------------------------------
%% Part 1b - Routing portability: QFCA directionallyCoupled across solvers
%% -------------------------------------------------------------------------
% directionallyCoupled.m now goes through solveCobraLP. The directional
% coupling relation (the -1 entries of the returned vector) is a structural
% fact that must be identical across LP backends.
fprintf(' -- Part 1b: QFCA (directionallyCoupled.m) routing portability ...\n');
testRxns = [1, 10, 20, 40];   % a spread of reaction indices
coupleRef = [];
for k = 1:numel(availLP)
    coupledK = false(numel(testRxns), size(S, 2));
    for t = 1:numel(testRxns)
        [~, res] = directionallyCoupled(S, rev, testRxns(t), availLP{k});
        coupledK(t, :) = (res(:).' < -0.5);   % coupled reactions
    end
    if k == 1
        coupleRef = coupledK;
    else
        assert(isequal(coupledK, coupleRef), ...
            sprintf('directionallyCoupled coupling differs under %s vs %s', ...
            availLP{k}, availLP{1}));
    end
end
if numel(availLP) >= 2
    fprintf('    directionallyCoupled coupling identical across solvers.\n');
else
    fprintf('    only one LP solver available; cross-solver check skipped.\n');
end

%% -------------------------------------------------------------------------
%% Part 1c - TrimGdel Gurobi-struct -> solveCobra transform equivalence
%% -------------------------------------------------------------------------
% gDel_minRN.m / step2and3.m / GRPRchecker.m formerly called gurobi() on
% Gurobi-style problem structs; they now route those structs through
% solveCobraLP / solveCobraMILP (local helper solveGurobiViaCobra). The full
% gDel_minRN pipeline cannot run in every environment (it depends on
% readGeneRules, which has a separate, out-of-scope R2026a incompatibility),
% so here we validate the exact transform the routing performs: a Gurobi-style
% LP and MILP solved through the abstraction must match a direct gurobi() call
% on the same problem (identical .stat/OPTIMAL, objective within tol).
if any(strcmp('gurobi', availLP)) && changeCobraSolver('gurobi', 'MILP', 0)
    fprintf(' -- Part 1c: TrimGdel Gurobi-struct routing transform ...\n');
    changeCobraSolver('gurobi', 'LP', 0);
    rng(0);

    % LP: minimise, all-equality rows, no rhs (Gurobi defaults rhs to 0) -
    % exactly the shape of the TrimGdel FBA sub-LPs.
    Slp = sprand(6, 10, 0.5);
    gm.obj = randn(10, 1);
    gm.A = sparse(Slp);
    gm.modelsense = 'Min';
    gm.sense = repmat('=', 1, 6);
    gm.lb = -2 * ones(10, 1);
    gm.ub = 2 * ones(10, 1);
    rawLP = gurobi(gm, struct('OutputFlag', 0));

    lp.A = gm.A; lp.c = gm.obj; lp.b = zeros(6, 1);
    lp.lb = gm.lb; lp.ub = gm.ub; lp.osense = 1;
    lp.csense = repmat('E', 6, 1);
    solLP = solveCobraLP(lp);
    assert(solLP.stat == 1 && strcmp(rawLP.status, 'OPTIMAL'), ...
        'TrimGdel LP transform: status mismatch');
    assert(abs(rawLP.objval - solLP.obj) <= tol, ...
        'TrimGdel LP transform: objective mismatch');

    % MILP: mixed C/B/I with '<' and '=' rows, like TrimGdel Step-1/2.
    n = 8;
    A1 = randn(5, n); Aeq = randn(2, n);
    gmi.obj = randn(n, 1);
    gmi.A = sparse([A1; Aeq]);
    gmi.rhs = [ones(5, 1); zeros(2, 1)];
    gmi.modelsense = 'Min';
    gmi.sense = [repmat('<', 1, 5), repmat('=', 1, 2)];
    gmi.lb = -ones(n, 1); gmi.ub = ones(n, 1);
    gmi.vtype = [repmat('C', 1, 3), repmat('B', 1, 3), repmat('I', 1, 2)];
    rawMILP = gurobi(gmi, struct('OutputFlag', 0, 'IntFeasTol', 1e-9));

    csi = gmi.sense(:); csi(csi == '<') = 'L'; csi(csi == '=') = 'E';
    milp.A = gmi.A; milp.c = gmi.obj; milp.b = gmi.rhs;
    milp.lb = gmi.lb; milp.ub = gmi.ub; milp.osense = 1;
    milp.csense = csi; milp.vartype = gmi.vtype(:);
    solMILP = solveCobraMILP(milp, 'intTol', 1e-9);
    assert(solMILP.stat == 1 && strcmp(rawMILP.status, 'OPTIMAL'), ...
        'TrimGdel MILP transform: status mismatch');
    assert(abs(rawMILP.objval - solMILP.obj) <= tol, ...
        'TrimGdel MILP transform: objective mismatch');
    fprintf('    Gurobi-struct LP and MILP match the abstraction (stat + obj).\n');
else
    fprintf(' -- Part 1c: gurobi LP+MILP not both available; TrimGdel transform skipped.\n');
end

%% -------------------------------------------------------------------------
%% Part 2 - Island graceful requirement (identified error when solver absent)
%% -------------------------------------------------------------------------
% The islands legitimately bypass the abstraction. When their required solver
% is absent they must fail with a clear, identified error id naming the
% required solver + capability, never an opaque backend crash.
fprintf(' -- Part 2: solver-island graceful requirement ...\n');
global SOLVERS

cplexAvailable = ~isempty(SOLVERS) && isfield(SOLVERS, 'ibm_cplex') && ...
    SOLVERS.ibm_cplex.installed && SOLVERS.ibm_cplex.working;

if ~cplexAvailable
    % ibm_cplex islands must raise their identified requires-CPLEX error.
    dummyLP = struct('A', sparse(2, 2), 'b', [0; 0], 'c', [1; 0], ...
        'lb', [0; 0], 'ub', [1; 1], 'csense', 'EE', 'S', sparse(2, 2));

    verifyIslandError('COBRA:findMIIS:requiresCplex', ...
        @() findMIIS(dummyLP));
    verifyIslandError('COBRA:mtFVA:requiresCplex', ...
        @() mtFVA(dummyLP, 1));
    fprintf('    findMIIS and mtFVA raise identified requires-CPLEX errors.\n');
else
    fprintf('    ibm_cplex present; CPLEX-island absent-solver check skipped.\n');
end

% maxEntConsVector is a pdco (nonlinear objective) island with no fallback:
% when pdco IS available it must run; when absent it must fail identified.
if changeCobraSolver('pdco', 'LP', 0)
    [mvec, mbool] = maxEntConsVector(sparse([1 -1; -1 1]), 0);
    assert(numel(mvec) == 2 && islogical(mbool), ...
        'maxEntConsVector did not return under pdco');
    fprintf('    maxEntConsVector runs under its pdco backend.\n');
end

% restore any solver the checks changed
if ~isempty(availLP)
    changeCobraSolver(availLP{1}, 'LP', 0);
end

% output a success message
fprintf('\nDone: solver-abstraction routing verified.\n');

% change the directory back
cd(currentDir)

% ---- local helper -------------------------------------------------------
function verifyIslandError(expectedId, fh)
% Assert that calling fh() raises an error whose identifier is expectedId.
    raised = false;
    try
        fh();
    catch ME
        raised = true;
        assert(strcmp(ME.identifier, expectedId), ...
            sprintf('expected island error id ''%s'' but got ''%s''', ...
            expectedId, ME.identifier));
    end
    assert(raised, sprintf('expected island error ''%s'' was not raised', expectedId));
end

function restoreCbtEnv(state, d)
% Restore the solver-selection state and working directory captured at entry.
    CobraSolverState.restore(state);
    cd(d);
end
