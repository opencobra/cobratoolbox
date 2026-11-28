% The COBRAToolbox: testOptimizeCardinality.m
%
% Purpose:
%     - optimizeCardinality(problem, param) minimises the zero norm of the variables x, maximises
%       that of y and minimises the one norm of z subject to linear constraints, by DC programming
%       on a capped-l1 approximation (a sequence of LPs whose approximation parameter theta
%       grows). The test solves small hand-built problems with the LP solver and checks the
%       invariants: status, constraints and bounds within tolerance, and the cardinality of the
%       solution (one non-zero x where one suffices, every y non-zero where that is feasible, the
%       one-norm optimum of z, one of a complementary pair). It covers the problem forms (sizes
%       p, q, r or Boolean columns), the weights and their defaults, the warm starts, the
%       complementarity problems, the printed report, the feasibility check, and every invalid
%       input (errors, and warnings with status -1). The LP (and QP) solver statuses that the
%       solvers do not give on demand (-1, 0, 2, 3 and an unknown status) come from stand-ins
%       for solveCobraLP and solveCobraQP, written into a tempname folder placed first on the
%       MATLAB path and removed at the end.
%
% Function under test:
%     src/base/solvers/cardOpt/sparseLP/optimizeCardinality.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - hand-built LPs with one to four variables and the default LP solver (any LP solver
%     serves, glpk included, hence 'needsLP'); the warm start 'l2' also runs with the default
%     QP solver where there is one (its lines are reached through the stand-in in any case, so
%     no QP solver is required).
%
% Coverage exemptions:
%     Line 168: unreachable, the field nbMaxIteration is always set by lines 148-150.
%     Lines 236-237: unreachable, inside "if ltp==1" (line 234) the length of p is 1, so the
%         condition of line 235 is false.
%     Lines 248-249: unreachable because of the cosmetic defect "a missing q, r, b or csense
%         stops with MATLAB's error" below: a problem without q stops at line 232.
%     Lines 252-253: unreachable, a non-logical q of length other than 1 makes "problem.q ~= 0"
%         a non-scalar operand of && (line 251), which raises MATLAB's own error first.
%     Lines 258-259: unreachable because of the same defect: a problem without r stops at
%         line 233.
%     Lines 478-479: unreachable, statements after the error call of line 477.
%     Lines 514-519, 522, 524-526: unreachable, the else of "if 1" (line 504).
%     Lines 554-556: unreachable because of the same defect: a problem without b stops at the
%         deal of line 471.
%     Lines 566-568: unreachable because of the same defect: a problem without csense stops at
%         the deal of line 471.
%     Lines 587-588, 590-593: unreachable, inside "if 0" (line 585).
%     Line 602: unreachable, lb > ub has already returned at lines 547-551.
%     Line 634: unreachable, lb2 <= ub2 always holds once lb <= ub (the w bounds are 0 and
%         max(|lb|, |ub|), the t bounds 1 and max(theta |lb|, theta |ub|, 1)).
%     Lines 763-764: unreachable, inside "if 0" (line 762).
%     Lines 821-822: unreachable, inside "if 0" (line 819).
%     Line 917: unreachable, inside "if 0" (line 916).
%     Line 945: unreachable, the condition of line 944 ends in "&& 0".
%     Lines 1060-1062: unreachable, the condition of line 1059 ends in "& 0".
%     Lines 1105-1106: unreachable, inside "if 0" (line 1104).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The random warm start is not protected against infinite bounds
%       SEVERITY: cosmetic
%       TRIGGER: problem = struct('p', 2, 'q', 0, 'r', 0, 'A', [1 1], 'b', 1, 'csense', 'E',
%         'lb', [-inf; -inf], 'ub', [2; 2], 'c', [0; 0]); rng(1); optimizeCardinality(problem,
%         struct('printLevel', 1))
%       OBSERVED: (R2025a, gurobi, 2026-11-23) the starting point is -Inf where lb is -Inf: line
%         747 starts from lb2, not from the clipped minlb2 that lines 742-745 compute "to protect
%         against inf or -inf in bounds"; the first iteration prints ||dx|| = Inf and del_obj =
%         NaN; the result (stat 1, obj 1) is not affected
%       EXPECTED: a finite random starting point between minlb2 and maxub2
%       LINES: 747
%     - DEFECT: A missing q, r, b or csense stops with MATLAB's error instead of the function's message
%       SEVERITY: cosmetic
%       TRIGGER: problem = struct('p', 2, 'q', 0, 'r', 0, 'A', [1 1], 'b', 1, 'csense', 'E',
%         'lb', [0; 0], 'ub', [2; 2], 'c', [0; 0]); optimizeCardinality(rmfield(problem, 'b'))
%         (likewise without q, r or csense)
%       OBSERVED: (R2025a, glpk, 2026-11-25) "Unrecognized field name "b"." at line 471 (q and r:
%         lines 232-233; csense: line 471); the checks written for these fields (lines 247-249,
%         257-259, 553-556, 565-568) come after the first use of the field
%       EXPECTED: the function's own messages, for example "Error: the size/location of vector y
%         is not defined" for q
%       LINES: 232-233, 248-249, 258-259, 471, 554-556, 566-568
%     - DEFECT: Boolean p, q and r whose lengths differ in one pair only pass the size check
%       SEVERITY: cosmetic
%       TRIGGER: problem as above with p = logical([1 1 0]), q = logical([0 0 1]),
%         r = logical([0 0]), A = [1 1 1], lb = [0; 0; 0], ub = [2; 2; 2], c = [0; 0; 0]
%       OBSERVED: (R2025a, glpk, 2026-11-25) "Arrays have incompatible sizes for this
%         operation." at line 475: line 240 tests "ltp~=ltq && ltq~=ltr", which is true only
%         when both pairs differ
%       EXPECTED: "Error: if p,q,r are Boolean vectors, they should be the same dimension"
%         (the test with ||)
%       LINES: 240
%     - DEFECT: The size warning of the one-norm weight vector o names d
%       SEVERITY: cosmetic
%       TRIGGER: problem as above with o = [1; 1; 1]
%       OBSERVED: (R2025a, glpk, 2026-11-25) stat -1 with the warning "Error: the size of weight
%         vector d is not correct"
%       EXPECTED: a warning that names o
%       LINES: 404
%
%     The defect recorded on 2026-11-23, an LP status 3 ending the iterations with status -1
%     because line 912 read "case 1 || 3", was fixed by feature 20261125-161147-blocker-fixes-two
%     and is tested below. The input of the cosmetic defect above, infinite bounds with the
%     random warm start, is not used.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.
%     - Full test after the fix (feature 20261125-161147-blocker-fixes-two), 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOptimizeCardinality'));
cd(fileDir);

% declare the requirements of this test: an LP solver for the sub-problems (any LP solver,
% glpk included). No QP solver is required: the warm start 'l2' uses one only where available
solvers = prepareTest('needsLP', true);

% the solvers are changed below: save the solver state and the global variables that exist now,
% to restore them at the end
globalsBefore = who('global');
initialSolverState = CobraSolverState.get();
changeCobraSolver(solvers.LP{1}, 'LP', 0);

% the random warm start (the default) and the warm start 'original' draw from rand
rng(0);

% feasTol is the LP solver's primal feasibility tolerance, which optimizeCardinality also uses
% as its threshold eta for a non-zero entry; a constraint row adds up to four entries that may
% each be off by feasTol, hence 10 * feasTol for the residuals and bounds
feasTol = getCobraSolverParams('LP', 'feasTol');
tol = 10 * feasTol;

% x in R^3: the entries of x sum to 1 and 0 <= x <= 2; the fewest non-zero entries is one
minCardProblem = struct('p', 3, 'q', 0, 'r', 0, 'A', [1 1 1], 'b', 1, 'csense', 'E', ...
    'lb', zeros(3, 1), 'ub', 2 * ones(3, 1), 'c', zeros(3, 1));

%% default parameters (param omitted or empty): one non-zero entry, constraints satisfied

solution = optimizeCardinality(minCardProblem);
assert(solution.stat == 1);
assertFeasible(minCardProblem, [solution.x; solution.y; solution.z], tol);
assert(nnz(abs(solution.x) > feasTol) == 1);
assert(isempty(solution.y) && isempty(solution.z));
% the outer objective is the capped-l1 term of the one non-zero entry, between 0 and lambda0 = 1
assert(solution.obj >= -tol && solution.obj <= 1 + tol);
assert(isfield(solution, 'origStat') && isfield(solution, 'solver'));

solution = optimizeCardinality(minCardProblem, []);
assert(solution.stat == 1 && nnz(abs(solution.x) > feasTol) == 1);
assertFeasible(minCardProblem, solution.x, tol);

%% x of either sign: the auxiliary w variables are kept (lb < 0), also without condensing

signedProblem = minCardProblem;
signedProblem.lb = -2 * ones(3, 1);
% param without the iteration fields: their defaults are filled in
solution = optimizeCardinality(signedProblem, struct('printLevel', 0));
assert(solution.stat == 1 && nnz(abs(solution.x) > feasTol) == 1);
assertFeasible(signedProblem, solution.x, tol);
% no condensing of w and t, the outer objective without the one-norm term, printLevel default
param = struct('nbMaxIteration', 100, 'condenseW', 0, 'condenseT', 0, 'regularizeOuter', 0);
solution = optimizeCardinality(signedProblem, param);
assert(solution.stat == 1 && nnz(abs(solution.x) > feasTol) == 1);
assertFeasible(signedProblem, solution.x, tol);

%% maximal cardinality of y: the entries of y sum to 3 with 0 <= y <= 2, so all three are non-zero

maxCardProblem = struct('p', 0, 'q', 3, 'r', 0, 'A', [1 1 1], 'b', 3, 'csense', 'E', ...
    'lb', zeros(3, 1), 'ub', 2 * ones(3, 1), 'c', zeros(3, 1), 'd', [1; 2; 3]);
solution = optimizeCardinality(maxCardProblem, struct('printLevel', 0));
assert(solution.stat == 1);
assertFeasible(maxCardProblem, solution.y, tol);
assert(nnz(abs(solution.y) > feasTol) == 3);
% also without condensing the t variables (every sub-problem keeps them)
solution = optimizeCardinality(maxCardProblem, struct('printLevel', 0, 'condenseT', 0));
assert(solution.stat == 1 && nnz(abs(solution.y) > feasTol) == 3);
assertFeasible(maxCardProblem, solution.y, tol);

%% one norm of z (alpha1 = 1) and the report with p = q = 0 (printLevel 1)

% z1 + z2 = 1, 0 <= z <= 2, c = [0; 1]: min z2 + |z1| + |z2| has the unique optimum z = [1; 0]
oneNormProblem = struct('p', 0, 'q', 0, 'r', 2, 'A', [1 1], 'b', 1, 'csense', 'E', ...
    'lb', zeros(2, 1), 'ub', 2 * ones(2, 1), 'c', [0; 1], 'alpha1', 1);
solution = optimizeCardinality(oneNormProblem, struct('printLevel', 1));
assert(solution.stat == 1 && isempty(solution.x) && isempty(solution.y));
assert(norm(solution.z - [1; 0], inf) <= tol);

%% the report with x and y but no z (printLevel 1); a premature stop after one iteration

% x + y = 1, 0 <= x, y <= 2: the fewest non-zero x and the most non-zero y give x = 0, y = 1
xyProblem = struct('p', 1, 'q', 1, 'r', 0, 'A', [1 1], 'b', 1, 'csense', 'E', ...
    'lb', [0; 0], 'ub', [2; 2], 'c', [0; 0]);
solution = optimizeCardinality(xyProblem, struct('printLevel', 1));
assert(solution.stat == 1);
assert(abs(solution.x) <= tol && abs(solution.y - 1) <= tol);
% one iteration only: a solution of the first sub-problem, feasible but not necessarily optimal
solution = optimizeCardinality(xyProblem, struct('printLevel', 1, 'nbMaxIteration', 1));
assert(solution.stat == 1);
assertFeasible(xyProblem, [solution.x; solution.y], tol);

%% theta at its maximum ends the iterations after the first one

solution = optimizeCardinality(minCardProblem, struct('printLevel', 0, 'thetaMax', 0.1));
assert(solution.stat == 1);
assertFeasible(minCardProblem, solution.x, tol);

%% weights and global parameters, problem given by the sizes p, q, r

% given k and o, lambda0 and delta0 without lambda1 and delta1 (set to feasTol)
weightedProblem = minCardProblem;
weightedProblem.k = [1; 2; 3];
weightedProblem.o = ones(3, 1);
weightedProblem.lambda0 = 1;
weightedProblem.delta0 = 1;
solution = optimizeCardinality(weightedProblem, struct('printLevel', 0));
assert(solution.stat == 1 && nnz(abs(solution.x) > feasTol) == 1);
assertFeasible(weightedProblem, solution.x, tol);

% an empty o is replaced by ones; lambda = delta = 0: no zero-norm term, a feasible point
unweightedProblem = minCardProblem;
unweightedProblem.o = [];
unweightedProblem.lambda = 0;
unweightedProblem.delta = 0;
solution = optimizeCardinality(unweightedProblem, struct('printLevel', 0));
assert(solution.stat == 1);
assertFeasible(unweightedProblem, solution.x, tol);

% lambda1 = delta1 = 0: no one-norm term on x and y
noOneNormProblem = xyProblem;
noOneNormProblem.lambda0 = 1;
noOneNormProblem.lambda1 = 0;
noOneNormProblem.delta0 = 1;
noOneNormProblem.delta1 = 0;
solution = optimizeCardinality(noOneNormProblem, struct('printLevel', 0));
assert(solution.stat == 1 && abs(solution.x) <= tol && abs(solution.y - 1) <= tol);

%% problem given by Boolean columns: x, y, z in the columns of A, and the output xyz

% columns [y1 x1 z1 x2]: x1 + x2 = 1, so one non-zero x suffices; y1 + z1 = 1 with 0 <= y1 <= 2
% and -1 <= z1 <= 1. The DC iterations reach a local optimum: y1 = 0 is one (no gain in the
% capped-l1 term of y1 at theta 0.5), so y is checked only where its weight d is given below
boolProblem = struct('p', logical([0; 1; 0; 1]), 'q', logical([1; 0; 0; 0]), ...
    'r', logical([0; 0; 1; 0]), 'A', [0 1 0 1; 1 0 1 0], 'b', [1; 1], ...
    'csense', ['E'; 'E'], 'lb', [0; 0; -1; 0], 'ub', [2; 2; 1; 2], 'c', zeros(4, 1));
solution = optimizeCardinality(boolProblem, struct('printLevel', 0));
assert(solution.stat == 1);
assert(isequal(size(solution.xyz), [4, 1]));
assert(isequal(solution.xyz(boolProblem.p), solution.x));
assert(isequal(solution.xyz(boolProblem.q), solution.y));
assert(isequal(solution.xyz(boolProblem.r), solution.z));
assertFeasible(boolProblem, solution.xyz, tol);
assert(nnz(abs(solution.x) > feasTol) == 1);

% given k, d and o (every o check passes: lambda1, delta1 and alpha1 non-zero)
weightedBoolProblem = boolProblem;
weightedBoolProblem.k = ones(4, 1);
weightedBoolProblem.d = ones(4, 1);
weightedBoolProblem.o = ones(4, 1);
weightedBoolProblem.alpha1 = 1;
solution = optimizeCardinality(weightedBoolProblem, struct('printLevel', 0));
assert(solution.stat == 1 && nnz(abs(solution.x) > feasTol) == 1);
assertFeasible(weightedBoolProblem, solution.xyz, tol);
% with the weights given, y1 is non-zero (gurobi and glpk give y1 = 2, z1 = -1, a local optimum)
assert(abs(solution.y) > feasTol);

% lambda = delta = 0 (k and d zero): a feasible point
unweightedBoolProblem = boolProblem;
unweightedBoolProblem.lambda = 0;
unweightedBoolProblem.delta = 0;
solution = optimizeCardinality(unweightedBoolProblem, struct('printLevel', 0));
assert(solution.stat == 1);
assertFeasible(unweightedBoolProblem, solution.xyz, tol);

% lambda1 = delta1 = 0
noOneNormBoolProblem = boolProblem;
noOneNormBoolProblem.lambda0 = 1;
noOneNormBoolProblem.lambda1 = 0;
noOneNormBoolProblem.delta0 = 1;
noOneNormBoolProblem.delta1 = 0;
solution = optimizeCardinality(noOneNormBoolProblem, struct('printLevel', 0));
assert(solution.stat == 1 && nnz(abs(solution.x) > feasTol) == 1);
assertFeasible(noOneNormBoolProblem, solution.xyz, tol);

%% warm starts: each gives one non-zero entry of x with the constraints satisfied

warmStartMethods = {'inverseTheta', 'original', '0', 'l1'};
for i = 1:numel(warmStartMethods)
    solution = optimizeCardinality(minCardProblem, ...
        struct('printLevel', 0, 'warmStartMethod', warmStartMethods{i}));
    assert(solution.stat == 1 && nnz(abs(solution.x) > feasTol) == 1);
    assertFeasible(minCardProblem, solution.x, tol);
end
% the warm start 'l2' solves a QP: with the default QP solver where there is one
if isfield(solvers, 'QP') && ~isempty(solvers.QP)
    changeCobraSolver(solvers.QP{1}, 'QP', 0);
    solution = optimizeCardinality(minCardProblem, ...
        struct('printLevel', 0, 'warmStartMethod', 'l2'));
    assert(solution.stat == 1 && nnz(abs(solution.x) > feasTol) == 1);
    assertFeasible(minCardProblem, solution.x, tol);
else
    fprintf('warm start l2 with a QP solver skipped: no QP solver (the stand-in runs it below)\n');
end

%% feasibility check of the first sub-problem: feasible

solution = optimizeCardinality(minCardProblem, struct('printLevel', 0, 'checkFeasibility', 1));
assert(solution.stat == 1 && nnz(abs(solution.x) > feasTol) == 1);

%% complementarity: x1 + x2 = y with 1 <= y <= 2, at most one of x1, x2 non-zero

% columns [x1 x2 y]; the pair (x1, x2) is linked to y; c, k and d are zero outside the pair, so
% this is a total complementarity problem, which stops once the pair is complementary
compProblem = struct('p', logical([1; 1; 0]), 'q', logical([0; 0; 1]), 'r', false(3, 1), ...
    'A', [1 1 -1], 'b', 0, 'csense', 'E', 'lb', [0; 0; 1], 'ub', [2; 2; 2], 'c', zeros(3, 1), ...
    'complementaritykBool', logical([1 0; 0 1; 0 0]), 'complementaritydBool', logical([0; 0; 1]));
solution = optimizeCardinality(compProblem, struct('printLevel', 1));
assert(solution.stat == 1);
assertFeasible(compProblem, solution.xyz, tol);
assert(nnz(abs(solution.x) > feasTol) == 1);
% theta at its maximum ends the iterations after the first one
solution = optimizeCardinality(compProblem, struct('printLevel', 0, 'thetaMax', 0.1));
assert(solution.stat == 1);
assertFeasible(compProblem, solution.xyz, tol);
% a column z with a cost (not a total complementarity problem): z = 1 is fixed by the second row
partialCompProblem = struct('p', logical([1; 1; 0; 0]), 'q', logical([0; 0; 1; 0]), ...
    'r', logical([0; 0; 0; 1]), 'A', [1 1 -1 0; 0 0 0 1], 'b', [0; 1], 'csense', ['E'; 'E'], ...
    'lb', [0; 0; 1; 0], 'ub', [2; 2; 2; 2], 'c', [0; 0; 0; 1], ...
    'complementaritykBool', logical([1 0; 0 1; 0 0; 0 0]), ...
    'complementaritydBool', logical([0; 0; 1; 0]));
solution = optimizeCardinality(partialCompProblem, struct('printLevel', 0));
assert(solution.stat == 1);
assertFeasible(partialCompProblem, solution.xyz, tol);
assert(nnz(abs(solution.x) > feasTol) == 1);

%% invalid inputs that raise an error

assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', ...
    {minCardProblem, struct('lambda0', 1)}, 'testMessage', ...
    'param should not contain lambda* field(s), rather they are problem fields'));
badProblem = minCardProblem;
badProblem.lambda = 1;
badProblem.lambda0 = 1;
assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', {badProblem}, 'testMessage', ...
    'optimizeCardinality expecting problem.lambda or problem.lambda0 and problem.lambda1'));
badProblem = minCardProblem;
badProblem.delta = 1;
badProblem.delta1 = 1;
assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', {badProblem}, 'testMessage', ...
    'optimizeCardinality expecting problem.delta or problem.delta0 and problem.delta1'));
assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', ...
    {rmfield(minCardProblem, 'p')}, 'testMessage', 'Error: the size of vector x is not defined'));
badProblem = boolProblem;
badProblem.q = logical([1; 0]);
badProblem.r = true;
assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', {badProblem}, 'testMessage', ...
    'Error: if p,q,r are Boolean vectors, they should be the same dimension'));
badProblem = boolProblem;
badProblem.r = double(boolProblem.r);
assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', {badProblem}, 'testMessage', ...
    'Error: r should be a logical vector'));
assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', ...
    {rmfield(minCardProblem, 'A')}, 'testMessage', 'Error: LHS matrix is not defined'));
badProblem = minCardProblem;
badProblem.A = [1 1];
assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', {badProblem}, 'testMessage', ...
    'Error: the number of columns of A is not correct'));
badProblem = boolProblem;
badProblem.A = [1 1 0; 0 0 1];
assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', {badProblem}, 'testMessage', ...
    'The number of columns of A is not consistent with the dimension of boolean vectors p,q,r.'));
assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', ...
    {rmfield(minCardProblem, 'lb')}, 'testMessage', 'Error: lower bound vector is not defined'));
badProblem = minCardProblem;
badProblem.lb = [0; 0];
assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', {badProblem}, 'testMessage', ...
    'Error: the size of vector lb is not correct'));
badProblem = boolProblem;
badProblem.lb = [0; 0];
assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', {badProblem}, 'testMessage', ...
    'Error: the size of vector lb is not correct'));
assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', ...
    {rmfield(minCardProblem, 'ub')}, 'testMessage', 'Error: upper bound vector is not defined'));
badProblem = minCardProblem;
badProblem.ub = [2; 2];
assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', {badProblem}, 'testMessage', ...
    'Error: the size of vector ub is not correct'));
badProblem = boolProblem;
badProblem.ub = [2; 2];
assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', {badProblem}, 'testMessage', ...
    'Error: the size of vector ub is not correct'));
badProblem = minCardProblem;
badProblem.k = [1; 1];
assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', {badProblem}, 'testMessage', ...
    'Error: the size of weight vector k is not correct'));
badProblem.k = [1; 0; 1];
assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', {badProblem}, 'testMessage', ...
    'Error: the weight vector k should be strictly positive'));
badProblem = boolProblem;
badProblem.k = [1; 1];
assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', {badProblem}, 'testMessage', ...
    'Error: the size of weight vector k is not correct'));
badProblem.k = [1; 0; 1; 1];
assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', {badProblem}, 'testMessage', ...
    'Error: the weight vector k(problem.p) should be strictly positive'));
% a column that is none of x, y, z
badProblem = boolProblem;
badProblem.r = false(4, 1);
assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', {badProblem}, 'testMessage', ...
    ['The number of columns of A is not consistent with the total number of nonzeros of ' ...
    'boolean vectors p,q,r.']));
assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', ...
    {rmfield(compProblem, 'complementaritydBool')}, 'testMessage', ...
    'Either both complementaritykBool and complementaritydBool are present, or neither'));

%% invalid inputs that give a warning and status -1 (no solver is called)

badProblem = xyProblem;
badProblem.d = [1; 1];
assertInvalidInputWarning(badProblem, 'Error: the size of weight vector d is not correct');
badProblem.d = 0;
assertInvalidInputWarning(badProblem, 'Error: the weight vector d should be strictly positive');
badProblem = boolProblem;
badProblem.d = [1; 1];
assertInvalidInputWarning(badProblem, 'Error: the size of weight vector d is not correct');
badProblem.d = [0; 1; 1; 1];
assertInvalidInputWarning(badProblem, ...
    'Error: the weight vector d(problem.q) should be strictly positive');
% the size check of o (sizes p, q, r) names d in its message
badProblem = minCardProblem;
badProblem.o = [1; 1];
assertInvalidInputWarning(badProblem, 'Error: the size of weight vector d is not correct');
badProblem.o = [1; -1; 1];
assertInvalidInputWarning(badProblem, ...
    'Error: the one norm weight vector o should be non-negative.');
badProblem = boolProblem;
badProblem.o = [1; 1];
assertInvalidInputWarning(badProblem, 'Error: the size of weight vector o is not correct.');
badProblem.o = [1; -1; 1; 1];
assertInvalidInputWarning(badProblem, ...
    'Error: the one norm weight vector o(problem.p) should be non-negative.');
badProblem.o = [-1; 1; 1; 1];
assertInvalidInputWarning(badProblem, ...
    'Error: the one norm weight vector o(problem.q) should be non-negative.');
badProblem.o = [1; 1; -1; 1];
badProblem.alpha1 = 1;
assertInvalidInputWarning(badProblem, ...
    'Error: the one norm weight vector o(problem.r) should be non-negative.');
badProblem = minCardProblem;
badProblem.lb = [0; 3; 0];
assertInvalidInputWarning(badProblem, 'Error: lb is greater than ub');
badProblem = minCardProblem;
badProblem.b = [1; 1];
assertInvalidInputWarning(badProblem, 'Error: the number of rows of A is not correct');
badProblem = minCardProblem;
badProblem.csense = ['E'; 'E'];
assertInvalidInputWarning(badProblem, 'Error: the size of vector csense is not correct');

%% solver statuses from stand-ins for solveCobraLP and solveCobraQP

% the stand-ins return, call after call, the statuses set by setStandIn (the last one repeated)
% and a fixed point; clearing removeStandIns removes them from the path and from the disk
[removeStandIns, standInDir] = putStandInSolversFirst(); %#ok<ASGLU> cleared below
assert(strcmp(fileparts(which('solveCobraLP')), standInDir));
% the point x = [1; 0; 0] is feasible for minCardProblem and has one non-zero entry
point = [1; 0; 0];

% status 3 (solution exists, not proven optimal) for every sub-problem: the iterations proceed
% (fixed 2026-11-25; before, the first status 3 ended them with status -1 and the start point)
setStandIn(3, point, true, struct('vbasis', [1; 2; 3]));
solution = optimizeCardinality(minCardProblem, struct('printLevel', 0));
standIn = getappdata(0, 'testOptimizeCardinalityStandIn');
assert(solution.stat == 3);
assert(standIn.calls == 2);
assert(isequal(solution.x, point) && solution.origStat == 103);
assertFeasible(minCardProblem, solution.x, tol);
assert(strcmp(solution.origStatText, 'stand-in status') && strcmp(solution.solver, 'standIn'));
% status 3 and then 1: the final status is that of the last sub-problem
setStandIn([3, 1], point, true, []);
solution = optimizeCardinality(minCardProblem, struct('printLevel', 1));
assert(solution.stat == 1 && isequal(solution.x, point));

% status -1, 0 and 2 of the first sub-problem end the iterations with that status and no point
expectedStatus = [-1, 0, 2];
for i = 1:numel(expectedStatus)
    setStandIn(expectedStatus(i), point, true, []);
    solution = optimizeCardinality(minCardProblem, struct('printLevel', 0));
    assert(solution.stat == expectedStatus(i) && solution.origStat == 100 + expectedStatus(i));
    assert(isempty(solution.x) && isempty(solution.y) && isempty(solution.z));
end

% an unknown status ends the iterations with status -1 and the previous iterate: the start point
% (zero for the warm start '0') at the first sub-problem, the first solution at the second
setStandIn(4, point, true, []);
solution = optimizeCardinality(minCardProblem, struct('printLevel', 0, 'warmStartMethod', '0'));
assert(solution.stat == -1 && solution.origStat == 104 && isequal(solution.x, zeros(3, 1)));
assert(strcmp(solution.origStatText, 'stand-in status'));
setStandIn([1, 4], point, false, []);
solution = optimizeCardinality(minCardProblem, struct('printLevel', 0, 'warmStartMethod', '0'));
assert(solution.stat == -1 && isequal(solution.x, point) && ~isfield(solution, 'origStatText'));

% a failed sub-problem with printLevel 4 also solves it with relaxed bounds and prints both
setStandIn([0, 1], point, true, []);
solution = optimizeCardinality(minCardProblem, struct('printLevel', 4));
assert(solution.stat == 0);

% feasibility check of an infeasible first sub-problem: reported, the iterations go on
setStandIn([0, 1], point, true, []);
solution = optimizeCardinality(minCardProblem, struct('printLevel', 0, 'checkFeasibility', 1));
assert(solution.stat == 1 && isequal(solution.x, point));
% with printLevel 3 it is also solved with relaxed bounds (feasible, or not), then an error
setStandIn([0, 1], point, true, []);
assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', ...
    {minCardProblem, struct('printLevel', 3, 'checkFeasibility', 1)}, 'testMessage', ...
    'Infeasible before the iterations begin'));
setStandIn(0, point, true, []);
assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', ...
    {minCardProblem, struct('printLevel', 3, 'checkFeasibility', 1)}, 'testMessage', ...
    'Infeasible before the iterations begin'));

% the warm start 'l1': an infeasible LP returns status 0, any other non-optimal status an error
setStandIn(0, point, true, []);
solution = optimizeCardinality(minCardProblem, struct('printLevel', 0, 'warmStartMethod', 'l1'));
assert(solution.stat == 0 && isempty(solution.x));
setStandIn(2, point, true, []);
assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', ...
    {minCardProblem, struct('printLevel', 0, 'warmStartMethod', 'l1')}, 'testMessage', ...
    'L1 problem is neither solved nor infeasible'));

% the warm start 'l2' (QP): optimal, then the LPs; infeasible returns status 0; otherwise an error
setStandIn(1, point, true, []);
solution = optimizeCardinality(minCardProblem, struct('printLevel', 0, 'warmStartMethod', 'l2'));
assert(solution.stat == 1 && isequal(solution.x, point));
setStandIn(0, point, true, []);
solution = optimizeCardinality(minCardProblem, struct('printLevel', 0, 'warmStartMethod', 'l2'));
assert(solution.stat == 0 && isempty(solution.x));
setStandIn(2, point, true, []);
assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', ...
    {minCardProblem, struct('printLevel', 0, 'warmStartMethod', 'l2')}, 'testMessage', ...
    'L2 problem is neither solved nor infeasible'));

% a sub-problem solution that breaks x1 + x2 = y of a complementarity problem is an error
setStandIn(1, [1; 1; 0], true, []);
assert(verifyCobraFunctionError('optimizeCardinality', 'inputs', ...
    {compProblem, struct('printLevel', 0)}, 'testMessage', ...
    'something wrong, should be almost zero'));

% remove the stand-ins: the real solveCobraLP is back
clear removeStandIns
rmappdata(0, 'testOptimizeCardinalityStandIn');
assert(~strcmp(fileparts(which('solveCobraLP')), standInDir) && ~isfolder(standInDir));

% restore the solver state and remove the global variables created here
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
for i = 1:numel(newGlobals)
    clearvars('-global', newGlobals{i});
end

% change the directory
cd(currentDir)

%% local functions

function assertFeasible(problem, v, tol)
% Asserts that v satisfies the bounds and the constraints (senses E, L, G) of problem within tol.
    assert(all(v >= problem.lb - tol) && all(v <= problem.ub + tol));
    residual = problem.A * v - problem.b;
    senses = problem.csense(:);
    assert(all(abs(residual(senses == 'E')) <= tol));
    assert(all(residual(senses == 'L') <= tol) && all(residual(senses == 'G') >= -tol));
end

function assertInvalidInputWarning(problem, expectedWarning)
% Asserts that optimizeCardinality warns with expectedWarning and returns status -1 and no point.
    lastwarn('');
    solution = optimizeCardinality(problem, struct('printLevel', 0));
    assert(strcmp(lastwarn(), expectedWarning));
    assert(solution.stat == -1 && isempty(solution.x));
end

function setStandIn(statuses, point, withText, basis)
% Sets what the stand-in solvers return: one status per call (the last one repeated), the point
% (the first entries of the solution), whether origStatText is given, and the basis.
    setappdata(0, 'testOptimizeCardinalityStandIn', struct('stat', statuses, 'point', point, ...
        'withText', withText, 'basis', basis, 'calls', 0));
end

function [removeStandIns, standInDir] = putStandInSolversFirst()
% Writes the stand-ins solveCobraLP and solveCobraQP into a temporary folder placed first on the
% MATLAB path. Clearing the returned onCleanup object removes them from the path and the disk.
    standInDir = tempname;
    mkdir(standInDir);
    removeStandIns = onCleanup(@() removeStandInFolder(standInDir));
    standInNames = {'solveCobraLP', 'solveCobraQP'};
    for i = 1:numel(standInNames)
        fid = fopen(fullfile(standInDir, [standInNames{i} '.m']), 'w');
        fprintf(fid, 'function solution = %s(problem, varargin)\n', standInNames{i});
        fprintf(fid, '%% stand-in written by testOptimizeCardinality\n');
        fprintf(fid, 'standIn = getappdata(0, ''testOptimizeCardinalityStandIn'');\n');
        fprintf(fid, 'standIn.calls = standIn.calls + 1;\n');
        fprintf(fid, 'setappdata(0, ''testOptimizeCardinalityStandIn'', standIn);\n');
        fprintf(fid, 'stat = standIn.stat(min(standIn.calls, numel(standIn.stat)));\n');
        fprintf(fid, 'full = zeros(size(problem.A, 2), 1);\n');
        fprintf(fid, 'full(1:numel(standIn.point)) = standIn.point;\n');
        fprintf(fid, ['solution = struct(''full'', full, ''obj'', problem.c'' * full, ' ...
            '''stat'', stat, ''origStat'', 100 + stat, ''solver'', ''standIn'', ' ...
            '''basis'', standIn.basis);\n']);
        fprintf(fid, ['if standIn.withText\n' ...
            '    solution.origStatText = ''stand-in status'';\nend\n']);
        fprintf(fid, 'end\n');
        fclose(fid);
    end
    addpath(standInDir, '-begin');
    clear solveCobraLP solveCobraQP
    rehash
end

function removeStandInFolder(standInDir)
% Removes the stand-in folder from the MATLAB path and from the disk.
    rmpath(standInDir);
    rmdir(standInDir, 's');
    clear solveCobraLP solveCobraQP
    rehash
end
