% The COBRAToolbox: testStandardize_problem.m
%
% Purpose:
%     - standardize_problem validates a polytope problem structure (equality and inequality
%     constraints, bounds, centre and objective) and fills in the missing standard fields.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/sampling/BarrierRound/PolytopeSimplifier/standardize_problem.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testStandardize_problem'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a polytope problem in three variables: x1 + x2 + x3 = 1 and 0 <= x <= 1
base = struct('Aeq', [1 1 1], 'beq', 1, 'lb', [0; 0; 0], 'ub', [1; 1; 1]);

%% an equality-constrained problem gets the missing standard fields

P = standardize_problem(base);
assert(isequal(size(P.Aineq), [0 3]) && isempty(P.bineq));
assert(isempty(P.center) && isempty(P.f) && isempty(P.df) && isempty(P.ddf));
assert(isequal(P.Aeq, [1 1 1]) && P.beq == 1);

%% missing bounds, right-hand sides and matrices are filled using the dimension

% only an inequality system: the dimension comes from Aineq
P = standardize_problem(struct('Aineq', [1 0; 0 1; 1 1], 'bineq', [1; 1; 1]));
assert(isequal(size(P.Aeq), [0 2]) && isempty(P.beq));
assert(isequal(P.lb, [-Inf; -Inf]) && isequal(P.ub, [Inf; Inf]));

% the right-hand side defaults to zeros of the right size
P = standardize_problem(struct('Aeq', [1 0; 0 1]));
assert(isequal(P.beq, [0; 0]));
P = standardize_problem(struct('Aineq', [1 0; 0 1]));
assert(isequal(P.bineq, [0; 0]));

%% the dimension can come from the bounds or the centre

P = standardize_problem(struct('lb', [0; 0; 0]));
assert(isequal(size(P.Aeq), [0 3]) && isequal(P.ub, [Inf; Inf; Inf]));
P = standardize_problem(struct('ub', [1; 1]));
assert(isequal(P.lb, [-Inf; -Inf]));
P = standardize_problem(struct('center', [1; 2; 3; 4]));
assert(isequal(size(P.Aineq), [0 4]) && isequal(P.center, [1; 2; 3; 4]));

%% the old field A is rejected

verifyCobraFunctionError('standardize_problem', 'inputs', {struct('A', [1 1])}, ...
    'testMessage', 'Use Aeq or Aineq instead of A');

%% an unconstrained problem needs a centre

verifyCobraFunctionError('standardize_problem', 'inputs', {struct()}, ...
    'testMessage', 'For unconstrained problems, an initial point "center" is required.');

%% objective given as a gradient vector

P = base;
P.df = [1; 0; 0];
P = standardize_problem(P);
assert(isequal(P.df, [1; 0; 0]) && isempty(P.f) && isempty(P.ddf));

% a zero gradient vector counts as no objective
P = base;
P.df = [0; 0; 0];
P = standardize_problem(P);
assert(isempty(P.df));

%% objective given as function handles

P = base;
P.f = @(x) sum(x.^2);
P.df = @(x) 2 * x;
P.ddf = @(x) 2 * ones(size(x));
Q = standardize_problem(P);
assert(isa(Q.f, 'function_handle') && isa(Q.df, 'function_handle') && isa(Q.ddf, 'function_handle'));

% a vector Hessian is allowed and a missing one is empty
P.ddf = [2; 2; 2];
Q = standardize_problem(P);
assert(isequal(Q.ddf, [2; 2; 2]));
P = rmfield(P, 'ddf');
Q = standardize_problem(P);
assert(isempty(Q.ddf));

%% inconsistent problems are rejected by assertions

% a gradient handle without an objective handle
bad = base;
bad.df = @(x) 2 * x;
assertFails(@() standardize_problem(bad));
% a gradient vector of the wrong size
bad = base;
bad.df = [1; 0];
assertFails(@() standardize_problem(bad));
% lower bound above upper bound
bad = base;
bad.lb = [2; 0; 0];
assertFails(@() standardize_problem(bad));
% a right-hand side of the wrong size
bad = base;
bad.beq = [1; 1];
assertFails(@() standardize_problem(bad));
% a function handle that does not return a scalar
bad = base;
bad.f = @(x) x;
bad.df = @(x) 2 * x;
assertFails(@() standardize_problem(bad));
% a gradient handle that does not return a vector of the right size
bad = base;
bad.f = @(x) sum(x);
bad.df = @(x) 1;
assertFails(@() standardize_problem(bad));
% a Hessian handle of the wrong size
bad = base;
bad.f = @(x) sum(x);
bad.df = @(x) ones(size(x));
bad.ddf = @(x) 1;
assertFails(@() standardize_problem(bad));
% a Hessian vector of the wrong size
bad.ddf = [1; 1];
assertFails(@() standardize_problem(bad));
% a Hessian without a gradient
bad = base;
bad.ddf = [1; 1; 1];
assertFails(@() standardize_problem(bad));


function assertFails(fun)
% Assert that calling fun raises an error.
failed = false;
try
    fun();
catch
    failed = true;
end
assert(failed, 'the call was expected to fail');
end

% change the directory
cd(currentDir)
