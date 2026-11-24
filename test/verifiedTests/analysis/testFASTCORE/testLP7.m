% The COBRAToolbox: testLP7.m
%
% Purpose:
%     - LP7(J, model, LPproblem, epsilon, basis) solves LP-7 of FASTCORE: it adds one variable
%       z(j) per reaction j of J, with 0 <= z(j) <= epsilon and z(j) <= v(j), and maximises
%       sum(z), so that as many reactions of J as possible carry a flux of at least epsilon.
%       Extra rows of LPproblem (C*v <= d) are kept. It returns the flux part v of the optimum
%       and the basis reported by solveCobraLP; when the LP is not solved to optimality it
%       prints the status, warns and returns NaN when the solver gives no point. The test
%       checks, for every solver, the outcome derived by hand on a small network (which
%       reactions of J reach epsilon), the cap of z by a C*v <= d row with nonzero d, the
%       invariants S*v = 0 and the bounds, and the warning for an infeasible LP. Where the
%       optimum is not unique only the reached threshold is asserted.
%
% Function under test:
%     src/dataIntegration/transcriptomics/FASTCORE/LP7.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - solves LPs (hand-built model of 2 metabolites and 4 reactions), every available
%     LP solver among gurobi and glpk.
%
% Coverage exemptions:
%     Line 70: unreachable, the condition of line 69 ends with "&& 0".
%     Lines 73-74: unreachable, line 58 sets basis to [] before line 72 tests it (see the
%     defect below).
%     Line 83: unreachable, solveCobraLP always returns a basis field (solveCobraLP.m sets
%     solution.basis for every solver).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The optional input basis is ignored
%       SEVERITY: cosmetic
%       TRIGGER: [v, basis] = LP7(J, model, LPproblem, epsilon); LP7(J, model, LPproblem, epsilon, basis)
%       OBSERVED: (R2025a, 2026-11-23, gurobi) line 58 sets basis = [] before the solve, so
%         the basis passed in is never given to solveCobraLP (lines 73-74 cannot run; the
%         comment of line 69 says the basis cannot be reused); the optimum is the same, only
%         the warm start the help text promises does not happen
%       EXPECTED: the basis used to warm-start the LP solve, as the help text says, or the
%         help text saying that the input is ignored
%       LINES: 58, 69-74
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLP7'));
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

epsilon = 1e-3;
% tolerance: the thresholds are 1e-3 and the optima have entries up to 10; 1e-7 is well
% below epsilon and above the solvers' feasibility tolerances
tol = 1e-7;

for k = 1:length(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if ~solverOK
        continue
    end
    fprintf('   Testing LP7 using %s ... \n', solvers.LP{k});

    %% two reactions of J that can both carry flux: both reach epsilon
    % v2 + v4 = v1 <= 10 and v2 <= 5 leave room for v2 >= epsilon and v4 >= epsilon together
    [v, basis] = LP7([2; 4], model, LPproblem, epsilon);
    assert(isequal(size(v), [4, 1]));
    assert(norm(model.S * v, inf) < tol);
    assert(all(v >= model.lb - tol) && all(v <= model.ub + tol));
    assert(v(2) >= epsilon - tol && v(4) >= epsilon - tol);
    % the second output is the basis solveCobraLP reported (a structure, or empty when the
    % solver returns none)
    assert(isempty(basis) || isstruct(basis));

    %% a basis given as input: the same threshold is reached
    [v, basis] = LP7([2; 4], model, LPproblem, epsilon, basis);
    assert(v(2) >= epsilon - tol && v(4) >= epsilon - tol);
    assert(isempty(basis) || isstruct(basis));

    %% a reaction of J that cannot carry flux stays at zero, the other one reaches epsilon
    % with ub(4) = 0 reaction 4 is blocked; reaction 2 can still carry flux
    LPblocked = LPproblem;
    LPblocked.ub(4) = 0;
    v = LP7([2; 4], model, LPblocked, epsilon, []);
    assert(norm(model.S * v, inf) < tol);
    assert(all(v >= LPblocked.lb - tol) && all(v <= LPblocked.ub + tol));
    assert(v(2) >= epsilon - tol);
    assert(abs(v(4)) < tol);

    %% an extra inequality row with a nonzero right hand side (C*v <= d) is kept
    % v4 <= 2 with epsilon = 3: z4 <= v4 <= 2, so the largest z4 is 2 and v4 = 2 exactly
    LPc = LPproblem;
    LPc.A = [model.S; 0 0 0 1];
    LPc.b = [0; 0; 2];
    LPc.csense = ['E'; 'E'; 'L'];
    v = LP7(4, model, LPc, 3);
    assert(norm(model.S * v, inf) < tol);
    assert(all(v >= model.lb - tol) && all(v <= model.ub + tol));
    assert(abs(v(4) - 2) < tol);

    %% an infeasible LP: the status is printed and a warning is issued
    % v1 >= 1 but A cannot leave (ub(2) = ub(4) = 0), so S*v = 0 has no solution
    LPinfeasible = LPproblem;
    LPinfeasible.lb(1) = 1;
    LPinfeasible.ub([2, 4]) = 0;
    lastwarn('');
    v = LP7(1, model, LPinfeasible, epsilon);
    [warnMsg] = lastwarn();
    assert(strcmp(warnMsg, 'LP solution may not be optimal'));
    assert(isequal(size(v), [4, 1]));
    if strcmp(solvers.LP{k}, 'gurobi')
        % gurobi returns no point for an infeasible LP, so v is NaN (lines 96-97)
        assert(all(isnan(v)));
    end
end

% restore the solver state and remove the globals created by this test
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
for iGlobal = 1:numel(newGlobals)
    clear('global', newGlobals{iGlobal});
end

% change the directory
cd(currentDir)
