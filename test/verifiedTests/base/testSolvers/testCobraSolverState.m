% The COBRAToolbox: testCobraSolverState.m
%
% Purpose:
%     - Unit test for the CobraSolverState accessor (feature
%       015-solver-spine-hardening, US3). CobraSolverState is a backward-
%       compatible facade OVER the 14 solver-state globals
%       (CBT_{LP,QP,MILP,MIQP,EP,NLP,CLP}_SOLVER / _PARAMS): reading or writing
%       through it must be equivalent to reading or writing the corresponding
%       global. This test pins:
%         (1) round-trip equivalence for all 7 solver types and 7 param types
%             (accessor <-> global, both directions);
%         (2) old-style `global CBT_LP_SOLVER` still sees a value written via the
%             accessor;
%         (3) get()/restore() lossless snapshot round-trip;
%         (4) unknown type -> COBRA:CobraSolverState:unknownType;
%         (5) changeCobraSolver parity: the migrated (eval-free) selection path
%             produces the same resulting global state, the same validation error
%             on a bogus solver, and leaves the prior selection intact on a failed
%             change (the rollback invariant);
%         (6) an explicit-state solve (solveCobra* given a CobraSolverState
%             snapshot) is FR-013-equivalent to the globals-driven solve
%             (identical .stat/.origStat, objective within tolerance) AND that the
%             explicit state, not the ambient globals, drives the selection, with
%             the globals restored afterwards.
%     Sections (1)-(4) are pure (no solver required); (5)-(6) are prepareTest-gated.
%
% Author:
%     - Created for feature 015-solver-spine-hardening, 2026-07-20.

% save the current path and any tolerances/seeds
currentDir = pwd;
fprintf(' -- Running testCobraSolverState: ... \n');
fileDir = fileparts(which('testCobraSolverState'));
cd(fileDir);

% fixed seed (the LP fixture is deterministic; this is defensive for reproducibility)
rng(0);

% justified tolerance: both solves target the SAME LP optimum; LP solvers report
% the optimal objective to ~feasTol (1e-6 default), so 1e-6 bounds any residual
% difference between two solves of an identical, well-conditioned problem.
objTol = 1e-6;

% the 7 solver/problem types the accessor and the globals cover
solverTypes = {'LP', 'QP', 'MILP', 'MIQP', 'EP', 'NLP', 'CLP'};

% snapshot the real solver state so the test never corrupts the session, and
% restore it (even on failure) before returning
origState = CobraSolverState.get();

try
    % =====================================================================
    % (1) Round-trip equivalence: accessor <-> global, both directions, for all
    %     7 solver types (selection) and 7 param types (parameters).
    % =====================================================================
    for i = 1:numel(solverTypes)
        t = solverTypes{i};
        sentinelName = ['sentinelSolver_' t];

        % accessor -> global
        CobraSolverState.setSolver(t, sentinelName);
        eval(['global CBT_' t '_SOLVER']);   % test-harness only: reach the dynamically named global
        globalVal = eval(['CBT_' t '_SOLVER']);
        assert(strcmp(globalVal, sentinelName), ...
            'accessor->global solver mismatch for %s', t);
        assert(strcmp(CobraSolverState.getSolver(t), sentinelName), ...
            'accessor read-back solver mismatch for %s', t);

        % global -> accessor
        eval(['CBT_' t '_SOLVER = ''' 'directSolver_' t ''';']);
        assert(strcmp(CobraSolverState.getSolver(t), ['directSolver_' t]), ...
            'global->accessor solver mismatch for %s', t);

        % params: accessor -> global
        CobraSolverState.setParam(t, 'feasTol', 1e-9);
        eval(['global CBT_' t '_PARAMS']);
        pGlobal = eval(['CBT_' t '_PARAMS']);
        assert(abs(pGlobal.feasTol - 1e-9) < eps, ...
            'accessor->global param mismatch for %s', t);
        pAccessor = CobraSolverState.getParams(t);
        assert(abs(pAccessor.feasTol - 1e-9) < eps, ...
            'accessor read-back param mismatch for %s', t);

        % params: global -> accessor
        eval(['CBT_' t '_PARAMS.optTol = 3e-7;']);
        pAccessor = CobraSolverState.getParams(t);
        assert(abs(pAccessor.optTol - 3e-7) < eps, ...
            'global->accessor param mismatch for %s', t);
    end
    fprintf('   + round-trip equivalence (7 solver + 7 param types) passed\n');

    % =====================================================================
    % (2) A plain `global CBT_LP_SOLVER` consumer sees an accessor-written value.
    % =====================================================================
    CobraSolverState.setSolver('LP', 'consumerVisibleSolver');
    clear CBT_LP_SOLVER
    global CBT_LP_SOLVER
    assert(strcmp(CBT_LP_SOLVER, 'consumerVisibleSolver'), ...
        'old-style global consumer did not see accessor-written value');
    fprintf('   + old-style global consumer sees accessor write\n');

    % =====================================================================
    % (3) get()/restore() is a lossless snapshot round-trip.
    % =====================================================================
    snap = CobraSolverState.get();
    CobraSolverState.setSolver('LP', 'perturbed');
    CobraSolverState.setParam('LP', 'feasTol', 12345);
    CobraSolverState.restore(snap);
    restored = CobraSolverState.get();
    assert(isequal(restored, snap), 'get()/restore() is not lossless');
    fprintf('   + get()/restore() lossless snapshot round-trip\n');

    % =====================================================================
    % (4) Unknown type -> defined error id COBRA:CobraSolverState:unknownType.
    % =====================================================================
    for method = {'getSolver', 'getParams'}
        threw = false;
        try
            CobraSolverState.(method{1})('NOT_A_TYPE');
        catch ME
            threw = true;
            assert(strcmp(ME.identifier, 'COBRA:CobraSolverState:unknownType'), ...
                '%s did not raise COBRA:CobraSolverState:unknownType', method{1});
        end
        assert(threw, '%s did not throw on an unknown type', method{1});
    end
    threw = false;
    try
        CobraSolverState.setSolver('BOGUS', 'x');
    catch ME
        threw = true;
        assert(strcmp(ME.identifier, 'COBRA:CobraSolverState:unknownType'));
    end
    assert(threw, 'setSolver did not throw on an unknown type');
    fprintf('   + unknown type raises COBRA:CobraSolverState:unknownType\n');

    % restore the real state before the solver-gated sections
    CobraSolverState.restore(origState);

    % =====================================================================
    % (5)-(6) Solver-gated parity + explicit-state solve.
    % =====================================================================
    solvers = prepareTest('needsLP', true, ...
        'useSolversIfAvailable', {'gurobi', 'mosek', 'glpk', 'pdco'});
    availableLP = solvers.LP;
    assert(~isempty(availableLP), 'prepareTest returned no usable LP solver');

    % a small, well-conditioned, bounded, feasible LP:
    %   max x1 + x2  s.t.  x1 + x2 <= 2,  0 <= x1,x2 <= 1   =>  x = [1;1], obj = 2
    LPproblem = struct();
    LPproblem.A = sparse([1, 1]);
    LPproblem.b = 2;
    LPproblem.c = [1; 1];
    LPproblem.lb = [0; 0];
    LPproblem.ub = [1; 1];
    LPproblem.osense = -1;      % maximise
    LPproblem.csense = 'L';

    % ---- (5) changeCobraSolver parity: resulting state + bogus-solver error +
    %          prior-selection-intact-on-failure (rollback invariant) ----
    solverA = availableLP{1};
    changeCobraSolver(solverA, 'LP', 0);
    assert(strcmp(CobraSolverState.getSolver('LP'), solverA), ...
        'changeCobraSolver did not set the LP global via the migrated path');
    assert(strcmp(CBT_LP_SOLVER, solverA), ...
        'the old-style global does not reflect changeCobraSolver''s selection');

    % bogus solver -> defined error, and the prior selection is left intact
    threw = false;
    try
        changeCobraSolver('thisSolverDoesNotExist', 'LP', 0);
    catch
        threw = true;
    end
    assert(threw, 'changeCobraSolver did not error on a bogus solver');
    assert(strcmp(CobraSolverState.getSolver('LP'), solverA), ...
        'a failed changeCobraSolver changed the prior LP selection (rollback invariant broken)');
    fprintf('   + changeCobraSolver parity (state set, bogus-solver error, prior selection intact)\n');

    % accessor-level rollback primitive (the exact operations the changeCobraSolver
    % catch-block rollback performs): capture -> change -> restore
    oldval = CobraSolverState.getSolver('LP');
    CobraSolverState.setSolver('LP', 'temporary');
    CobraSolverState.setSolver('LP', oldval);
    assert(strcmp(CobraSolverState.getSolver('LP'), solverA), ...
        'accessor rollback primitive did not restore the prior selection');

    % ---- (6) explicit-state solve equivalence + selection override + restore ----
    % baseline: globals-driven solve under solverA
    changeCobraSolver(solverA, 'LP', 0);
    solAmbient = solveCobraLP(LPproblem);
    assert(solAmbient.stat == 1, 'baseline LP solve was not optimal');

    % explicit state == current globals must reproduce the solve EXACTLY (FR-013)
    stateA = CobraSolverState.get();
    solSameState = solveCobraLP(LPproblem, 'cobraSolverState', stateA);
    assert(solSameState.stat == solAmbient.stat, ...
        'explicit-state (== globals) .stat differs from globals-driven solve');
    assert(isequal(solSameState.origStat, solAmbient.origStat), ...
        'explicit-state (== globals) .origStat differs from globals-driven solve');
    assert(abs(solSameState.obj - solAmbient.obj) < objTol, ...
        'explicit-state (== globals) objective differs beyond tolerance');
    assert(strcmp(solSameState.solver, solverA), ...
        'explicit-state solve did not use the state''s selected solver');

    % if a second LP solver is available, prove the explicit state (not the ambient
    % globals) drives the selection, and that the globals are restored afterwards
    if numel(availableLP) >= 2
        solverB = availableLP{2};

        % capture a snapshot pinned to solverA, then switch the ambient globals to B
        changeCobraSolver(solverA, 'LP', 0);
        snapA = CobraSolverState.get();
        changeCobraSolver(solverB, 'LP', 0);   % ambient globals now => solverB

        solB = solveCobraLP(LPproblem);                                   % ambient => B
        solExplicitA = solveCobraLP(LPproblem, 'cobraSolverState', snapA); % explicit => A

        assert(strcmp(solB.solver, solverB), ...
            'ambient solve did not use the ambient (globals) solver');
        assert(strcmp(solExplicitA.solver, solverA), ...
            'explicit-state solve did not override the ambient globals selection');

        % the globals must be restored to solverB after the explicit-state solve
        assert(strcmp(CobraSolverState.getSolver('LP'), solverB), ...
            'the explicit-state solve did not restore the ambient globals on exit');

        % and both solves of the same LP agree (FR-013 equivalence across solvers)
        assert(solExplicitA.stat == 1 && solB.stat == 1, ...
            'cross-solver LP solves were not both optimal');
        assert(abs(solExplicitA.obj - solB.obj) < objTol, ...
            'cross-solver LP objectives differ beyond tolerance');
        fprintf('   + explicit-state drives selection (%s over ambient %s) and restores globals\n', ...
            solverA, solverB);
    end
    fprintf('   + explicit-state solve is FR-013-equivalent to the globals-driven solve\n');

catch ME
    % never leave the session with corrupted solver globals
    CobraSolverState.restore(origState);
    cd(currentDir);
    rethrow(ME);
end

% restore the real solver state and the working directory
CobraSolverState.restore(origState);
cd(currentDir);

fprintf(' -- testCobraSolverState passed.\n');
