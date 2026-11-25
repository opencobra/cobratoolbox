% The COBRAToolbox: testDebugInfeasibleEntropyFBA.m
%
% Purpose:
%     - debugInfeasibleEntropyFBA first solves FBA (optimizeCbModel); if the model has no FBA
%       solution it warns and returns that solution, otherwise it runs entropic FBA
%       (entropicFluxBalanceAnalysis, default solver MOSEK, then pdco) and progressively drops
%       the coupling constraints, relaxes the internal flux bounds and rescales or relaxes the
%       exchange bounds until an EFBA solution is found. The test checks the documented early
%       return for a model without an FBA solution with every available LP solver: the warning,
%       the returned FBA solution (stat ~= 1), and that modelOut is then not assigned, as the
%       help text states. Every line after the FBA check needs MOSEK (see exemptions).
%
% Function under test:
%     src/base/solvers/entropicFBA/debugInfeasibleEntropyFBA.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - one FBA per call on a hand-built model; every available LP solver among
%     gurobi and glpk.
%
% Coverage exemptions:
%     Lines 34-128: need a working MOSEK. Line 37 calls entropicFluxBalanceAnalysis without
%     param.solver, so its default solver MOSEK is used, and both branches of the switch
%     (lines 45-69) call MOSEK at least once; the MOSEK licence is not available on the
%     reference machine, where line 37 stops with "Undefined function 'mosekopt'".
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDebugInfeasibleEntropyFBA'));
cd(fileDir);

% require an LP solver for the FBA check; skip gracefully if none is available
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});

% the solver selection is saved and restored; any global created while reading it is
% removed at the end
globalsBefore = who('global');
initialSolverState = CobraSolverState.get();

% a small model: a -> b -> exported b, uptake of a limited to 10. Requiring an export of at
% least 20 makes it infeasible (at most 10 can be exported)
model = createModel({'EX_a', 'R1', 'EX_b'}, {'', '', ''}, ...
    {' -> a[c]', 'a[c] -> b[c]', 'b[c] -> '}, 'printLevel', 0);
model.lb(1) = 0;
model.ub(1) = 10;
model = changeObjective(model, 'EX_b');
infeasibleModel = model;
infeasibleModel.lb(3) = 20;

for k = 1:numel(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if solverOK
        fprintf('   Testing debugInfeasibleEntropyFBA using %s ... \n', solvers.LP{k});

        %% a model without an FBA solution: warning and early return of the FBA solution
        % the returned solution is the FBA of the model (the same status as optimizeCbModel),
        % which is not optimal; the status is an integer, so it is compared exactly
        lastwarn('');
        sol = debugInfeasibleEntropyFBA(infeasibleModel);
        [warningText, ~] = lastwarn();
        assert(strcmp(warningText, 'Model does not admit a flux balance analysis solution'));
        fbaSolution = optimizeCbModel(infeasibleModel);
        assert(sol.stat ~= 1);
        assert(sol.stat == fbaSolution.stat);

        %% modelOut is only assigned once a relaxation is found, so asking for it after the
        % early return is an error
        assert(verifyCobraFunctionError('debugInfeasibleEntropyFBA', 'inputs', {infeasibleModel}, ...
            'outputArgCount', 2));

        fprintf('Done.\n');
    end
end

% leave the solver selection and the globals as they were found
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
if ~isempty(newGlobals)
    clear('global', newGlobals{:});
end

% change the directory
cd(currentDir)
