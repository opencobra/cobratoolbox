% The COBRAToolbox: testMaxstar.m
%
% Purpose:
%     - maxstar computes the numerically stable log(sum(w .* exp(x))) along a dimension, with optional (positive or negative) weights.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/thermo/utilities/maxstar.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below. (The function body check "nargin > 3" is shadowed by MATLAB itself rejecting a 4th argument with "Too many input arguments".)
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMaxstar'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons: results are logarithms of sums of exponentials,
% so 1e-10 is far above rounding error and far below any real difference
tol = 1e-10;

%% no weights: log(sum(exp(x)))

% row vector: summed along its own dimension
assert(abs(maxstar([1 2 3]) - log(exp(1) + exp(2) + exp(3))) < tol);
% a scalar is its own result
assert(abs(maxstar(5) - 5) < tol);
% matrix: summed down the columns by default (dim = 1), result is a row
columnResult = maxstar([1 2; 3 4]);
assert(norm(columnResult - [log(exp(1) + exp(3)), log(exp(2) + exp(4))]) < tol);
% dim = 2 sums along the rows, result is a column
rowResult = maxstar([1 2; 3 4], [], 2);
assert(norm(rowResult - [log(exp(1) + exp(2)); log(exp(3) + exp(4))]) < tol);
% dim = 2 for a row vector gives the same value as the default
assert(abs(maxstar([1 2 3], [], 2) - maxstar([1 2 3])) < tol);

%% positive weights

% weights of the same size as x
assert(abs(maxstar([1 2 3], [1 2 3]) - log(1 * exp(1) + 2 * exp(2) + 3 * exp(3))) < tol);
% a weight vector as long as the summed dimension is expanded over the other dimension
weightedColumns = maxstar([1 2; 3 4], [1; 1], 1);
assert(norm(weightedColumns - columnResult) < tol);
% orientation of the weight vector does not matter
assert(abs(maxstar([1; 2; 3], [1 1 1]') - maxstar([1 2 3])) < tol);

%% negative weights (subtracted terms)

assert(abs(maxstar([1 2 3], [1 -0.1 2]) - log(exp(1) - 0.1 * exp(2) + 2 * exp(3))) < tol);

%% invalid calls

% no input
assert(verifyCobraFunctionError('maxstar', 'testMessage', 'Wrong number of input arguments.'));
% weight vector whose length does not match size(x, dim)
assert(verifyCobraFunctionError('maxstar', 'inputs', {[1 2 3], [1 1]}, 'testMessage', 'Length of w must match size(x,dim).'));

% change the directory
cd(currentDir)
