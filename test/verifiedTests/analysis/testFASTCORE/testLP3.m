% The COBRAToolbox: testLP3.m
%
% Purpose:
%     - LP3(J, model, LPproblem, basis) solves LP-3 of FASTCORE: maximise the sum of the fluxes
%       of the reactions J, where reactions that can only run backwards (model.ub <= 0) are
%       flipped first, so that their flux magnitude is maximised, and flipped back in v. It
%       returns the optimal flux vector and the basis reported by solveCobraLP. The test
%       checks, for every solver, the optimal objective derived by hand on a small network with
%       one backward-only reaction and on the same LP with an extra inequality row (C*v <= d,
%       nonzero d), and the invariants S*v = 0 and the bounds. Where the optimum is not unique
%       only the objective is asserted.
%
% Function under test:
%     src/dataIntegration/transcriptomics/FASTCORE/LP3.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - solves LPs (hand-built model of 2 metabolites and 4 reactions), every available
%     LP solver among gurobi and glpk.
%
% Coverage exemptions:
%     Line 68: unreachable, the condition of line 67 ends with "&& 0".
%     Lines 71-72: unreachable, line 58 sets basis to [] before line 70 tests it (see the
%     defect below).
%     Line 80: unreachable, solveCobraLP always returns a basis field (solveCobraLP.m lines
%     1566-1569 set solution.basis for every solver).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The optional input basis is ignored
%       SEVERITY: cosmetic
%       TRIGGER: [v, basis] = LP3(J, model, LPproblem); LP3(J, model, LPproblem, basis)
%       OBSERVED: (R2025a, 2026-11-23, gurobi) line 58 sets basis = [] before the
%         solve, so the basis passed in is never given to solveCobraLP (lines 71-72 cannot run;
%         the comment of line 67 says the basis cannot be reused); the optimum is the same, only
%         the warm start the help text promises does not happen
%       EXPECTED: the basis used to warm-start the LP solve, as the help text says, or the
%         help text saying that the input is ignored
%       LINES: 58, 70-72
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLP3'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
globalsBefore = who('global');
initialSolverState = CobraSolverState.get();

% Network: uptake 1 (-> A, ub 10), 2 (A -> B, ub 5), 3 (written -> B but backward only:
% lb -10, ub 0, so it consumes B) and export 4 (A ->, ub 10)
model.S = sparse([1 -1 0 -1; ...
                  0  1 1  0]);
model.lb = [0; 0; -10; 0];
model.ub = [10; 5; 0; 10];
LPproblem.A = model.S;
LPproblem.b = zeros(2, 1);
LPproblem.csense = ['E'; 'E'];
LPproblem.lb = model.lb;
LPproblem.ub = model.ub;

% tolerance: optima are vertices with entries of order 1 to 10; 1e-6 covers the solvers'
% feasibility tolerances
tol = 1e-6;

for k = 1:length(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if ~solverOK
        continue
    end
    fprintf('   Testing LP3 using %s ... \n', solvers.LP{k});

    %% a backward-only reaction in J: its magnitude is maximised, its sign is kept in v
    % B balance gives v3 = -v2 and v2 <= 5, so the optimum is v3 = -5, v2 = 5 (unique);
    % v1 - v4 = 5 (split not unique)
    [v, basis] = LP3(3, model, LPproblem);
    assert(isequal(size(v), [4, 1]));
    assert(norm(model.S * v, inf) < tol);
    assert(all(v >= model.lb - tol) && all(v <= model.ub + tol));
    assert(abs(v(3) + 5) < tol && abs(v(2) - 5) < tol);
    % the second output is the basis solveCobraLP reported (a structure, or empty when the
    % solver returns none)
    assert(isempty(basis) || isstruct(basis));

    %% a basis given as input: the same optimum is returned
    [v, basis] = LP3(3, model, LPproblem, basis);
    assert(abs(v(3) + 5) < tol && abs(v(2) - 5) < tol);
    assert(isempty(basis) || isstruct(basis));

    %% several forward reactions in J: their sum is maximised
    % v2 + v4 = v1 <= 10, so the optimal objective is 10 (split not unique)
    v = LP3([2; 4], model, LPproblem, []);
    assert(norm(model.S * v, inf) < tol);
    assert(all(v >= model.lb - tol) && all(v <= model.ub + tol));
    assert(abs(v(2) + v(4) - 10) < tol);
    assert(abs(v(3) + v(2)) < tol);

    %% an extra inequality row with a nonzero right hand side (C*v <= d) is kept
    % v4 <= 2 makes the maximum of v4 equal to 2
    LPc = LPproblem;
    LPc.A = [model.S; 0 0 0 1];
    LPc.b = [0; 0; 2];
    LPc.csense = ['E'; 'E'; 'L'];
    v = LP3(4, model, LPc, []);
    assert(norm(model.S * v, inf) < tol);
    assert(all(v >= model.lb - tol) && all(v <= model.ub + tol));
    assert(abs(v(4) - 2) < tol);
end

% restore the solver state and remove the globals created by this test
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
for iGlobal = 1:numel(newGlobals)
    clear('global', newGlobals{iGlobal});
end

% change the directory
cd(currentDir)
