% The COBRAToolbox: testBuildOptProblemNamesCon.m
%
% Purpose:
%     - Regression test for the buildOptProblemFromModel mosek-debug naming bug
%       (feature 015-solver-spine-hardening, R4 / FR-005). When model.C is
%       present without model.ctrs (or model.E without model.evars), the debug
%       naming path used to size names.con from model.mets alone, dropping the
%       size(model.C,1) coupling rows and mismatching size(optProblem.A,1). Under
%       mosek this surfaced as err_argument_dimension (Error 1201).
%
%       This test builds such models and asserts that
%         numel(optProblem.names.con) == size(optProblem.A,1)  and
%         numel(optProblem.names.var) == size(optProblem.A,2)
%       (a pure structural check, no solver required), and, when mosek is
%       available, that a real debug solve of a model.C-without-model.ctrs LP no
%       longer raises the mosek dimension error.
%
% Authors:
%     - Generated for feature 015-solver-spine-hardening, 2026-07-20.

% save the current path and the full solver-selection state, and guarantee both
% are restored on exit (including on an assertion failure) so this test never
% perturbs the global solver state for the rest of the suite. This test changes
% the LP solver to mosek below; without this guard that change would leak.
currentDir = pwd;
savedCbtState = CobraSolverState.get();
restoreCbtObj = onCleanup(@() restoreCbtEnv(savedCbtState, currentDir)); %#ok<NASGU>

% initialize the test
fileDir = fileparts(which('testBuildOptProblemNamesCon'));
cd(fileDir);

% -------------------------------------------------------------------------
% Model 1: model.C present, model.ctrs ABSENT (no E/evars).
% Assembled A = [S; C] has size(A,1) = nMet + size(C,1) coupling rows.
% -------------------------------------------------------------------------
modelC = struct();
modelC.rxns = {'R1'; 'R2'; 'R3'};
modelC.mets = {'A'; 'B'};
modelC.S = [1, -1, 0; 0, 1, -1];
modelC.b = [0; 0];
modelC.csense = ['E'; 'E'];
modelC.lb = [0; 0; 0];
modelC.ub = [10; 10; 10];
modelC.c = [0; 0; 1];
modelC.C = [1, 0, 0];         % one coupling row, no matching model.ctrs
modelC.d = 0;
modelC.dsense = 'L';
assert(~isfield(modelC, 'ctrs'));

optProblemC = buildOptProblemFromModel(modelC, false, struct('debug', true, 'solver', 'mosek'));

assert(numel(optProblemC.names.con) == size(optProblemC.A, 1), ...
    sprintf('names.con has %d entries but A has %d rows', ...
    numel(optProblemC.names.con), size(optProblemC.A, 1)));
assert(numel(optProblemC.names.var) == size(optProblemC.A, 2), ...
    sprintf('names.var has %d entries but A has %d columns', ...
    numel(optProblemC.names.var), size(optProblemC.A, 2)));
% the coupling row must have a (placeholder) name appended
assert(size(optProblemC.A, 1) == numel(modelC.mets) + size(modelC.C, 1));

% -------------------------------------------------------------------------
% Model 2: model.E present, model.evars ABSENT (no C/ctrs).
% Assembled A = [S, E] has size(A,2) = nRxn + size(E,2) extra columns.
% -------------------------------------------------------------------------
modelE = struct();
modelE.rxns = {'R1'; 'R2'; 'R3'};
modelE.mets = {'A'; 'B'};
modelE.S = [1, -1, 0; 0, 1, -1];
modelE.b = [0; 0];
modelE.csense = ['E'; 'E'];
modelE.lb = [0; 0; 0];
modelE.ub = [10; 10; 10];
modelE.c = [0; 0; 1];
modelE.E = [1; 0];            % one extra variable column, no matching model.evars
modelE.evarlb = 0;
modelE.evarub = 10;
modelE.evarc = 0;
modelE.D = zeros(0, 1);
assert(~isfield(modelE, 'evars'));

optProblemE = buildOptProblemFromModel(modelE, false, struct('debug', true, 'solver', 'mosek'));

assert(numel(optProblemE.names.con) == size(optProblemE.A, 1), ...
    sprintf('names.con has %d entries but A has %d rows', ...
    numel(optProblemE.names.con), size(optProblemE.A, 1)));
assert(numel(optProblemE.names.var) == size(optProblemE.A, 2), ...
    sprintf('names.var has %d entries but A has %d columns', ...
    numel(optProblemE.names.var), size(optProblemE.A, 2)));
% the extra variable column must have a (placeholder) name appended
assert(size(optProblemE.A, 2) == numel(modelE.rxns) + size(modelE.E, 2));

% -------------------------------------------------------------------------
% End-to-end mosek debug solve of a model.C-without-model.ctrs LP: with the fix
% the names line up with A, so mosek no longer raises err_argument_dimension.
% -------------------------------------------------------------------------
solverPkgs = prepareTest('needsLP', true, 'requiredSolvers', {'mosek'});
if any(strcmp(solverPkgs.LP, 'mosek'))
    changeCobraSolver('mosek', 'LP', 0);

    LPproblem = optProblemC;
    LPproblem.modelID = 'testBuildOptProblemNamesCon';

    solveErr = '';
    try
        sol = solveCobraLP(LPproblem, struct('debug', 1, 'printLevel', 0));
    catch ME
        solveErr = [ME.identifier ' ' ME.message];
    end
    assert(isempty(regexpi(solveErr, 'argument_dimension|1201', 'once')), ...
        sprintf('mosek raised a names/dimension error: %s', solveErr));
    % if it solved, this bounded LP is optimal
    if isempty(solveErr)
        assert(sol.stat == 1);
    end
end

% cwd + solver-selection state are restored by the onCleanup registered above,
% even if an assertion failed earlier.

% ---- local helper -------------------------------------------------------
function restoreCbtEnv(state, d)
% Restore the solver-selection state and working directory captured at entry.
    CobraSolverState.restore(state);
    cd(d);
end
