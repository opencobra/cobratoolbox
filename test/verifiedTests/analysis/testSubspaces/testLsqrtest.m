% The COBRAToolbox: testLsqrtest.m
%
% Purpose:
%     - lsqrtest is the example driver of the toolbox lsqr solver: it builds the right-hand
%       side b = A*xtrue, with xtrue = (n:-1:1)' and the m x n test matrix A of lsqraprod
%       (A(i,i) = i, A(i+1,i) = i), and returns the lsqr solution of A*x = b (damp = 0) or of the
%       damped least-squares problem min ||A*x - b||^2 + damp^2*||x||^2, with tolerances 1e-6,
%       printing the lsqr iteration log and the first and last elements of x.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: the solutions are compared with xtrue and with direct dense solutions
%       of the same problems computed below from the explicit matrix A (built column by column
%       with lsqraprod), within tolerances derived from the lsqr stopping tolerances (no
%       first-run value is needed).
%
% Function under test:
%     src/analysis/subspaces/lsqr/lsqrtest.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The function handle is printed by a statement without a semicolon
%       SEVERITY: cosmetic
%       TRIGGER: any call
%       OBSERVED: 'aprodfunc = function_handle with value: @(mode,m,n,x)lsqraprod(...)' is printed
%         before the lsqr log
%       EXPECTED: no output for the assignment (debug leftover)
%       LINES: 33
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLsqrtest'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the toolbox lsqr (signature lsqr(m, n, aprod, b, damp, ...)) shadows the MATLAB lsqr
assert(contains(which('lsqr'), fullfile('src', 'analysis', 'subspaces', 'lsqr')));

% the explicit test matrix of lsqraprod, column by column
buildTestMatrix = @(m, n) cell2mat(arrayfun(@(j) lsqraprod(1, m, n, double((1:n)' == j), 0, 0), 1:n, 'UniformOutput', false));

%% square system, no damping: the solution is xtrue

m = 10;
n = 10;
A = buildTestMatrix(m, n);
xTrue = (n:-1:1)';
b = A * xTrue;

x = lsqrtest(m, n, 0);

assert(isequal(size(x), [n, 1]) && all(isfinite(x)));
% lsqr stops when ||A*x - b|| <= btol*||b|| + atol*||A||*||x|| with atol = btol = 1e-6
% (||A|| is estimated by lsqr from below by the Frobenius norm)
assert(norm(A * x - b) <= 1e-6 * norm(b) + 1e-6 * norm(A, 'fro') * norm(x));
% the relative error is at most cond(A) (about 44) times the relative residual, so 1e-4 is
% a safe bound (about 1e-7 is observed)
assert(norm(x - xTrue) / norm(xTrue) < 1e-4);

%% more rows than columns, no damping: the consistent system is solved exactly

m = 20;
n = 10;
A = buildTestMatrix(m, n);
xTrue = (n:-1:1)';
b = A * xTrue;

x = lsqrtest(m, n, 0);

assert(isequal(size(x), [n, 1]));
assert(norm(A * x - b) <= 1e-6 * norm(b) + 1e-6 * norm(A, 'fro') * norm(x));
assert(norm(x - xTrue) / norm(xTrue) < 1e-4);

%% square system with damping: the damped least-squares solution

m = 10;
n = 10;
damp = 0.1;
A = buildTestMatrix(m, n);
b = A * (n:-1:1)';

x = lsqrtest(m, n, damp);

% the damped solution solves the normal equations (A'*A + damp^2*I)*x = A'*b; lsqr stops when
% the normal-equation residual is below atol = 1e-6 relative to ||[A; damp*I]||*||r||, and the
% condition number of [A; damp*I] (below 50) bounds the relative error, so 1e-4 is a safe bound
xDamped = (A' * A + damp^2 * eye(n)) \ (A' * b);
assert(isequal(size(x), [n, 1]));
assert(norm(x - xDamped) / norm(xDamped) < 1e-4);
% damping moves the solution away from xtrue
assert(norm(x - (n:-1:1)') > 1e-3);

%% fewer rows than columns: the minimum-norm solution

m = 5;
n = 8;
A = buildTestMatrix(m, n);
b = A * (n:-1:1)';

x = lsqrtest(m, n, 0);

% lsqr started from zero returns the minimum-norm solution pinv(A)*b of the consistent
% underdetermined system
assert(isequal(size(x), [n, 1]));
assert(norm(A * x - b) <= 1e-6 * norm(b) + 1e-6 * norm(A, 'fro') * norm(x));
assert(norm(x - pinv(A) * b) / norm(pinv(A) * b) < 1e-4);

% change the directory
cd(currentDir)
