% The COBRAToolbox: testGmscale.m
%
% Purpose:
%     - gmscale computes geometric-mean row and column scale factors that equilibrate a matrix.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/subspaces/gmscale.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None expected; the iteration-limit break (npass == maxpass) shares a line with the convergence test and is executed.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found. With iprint > 0 the function prints a scaling report to the console (console noise, not suppressed, see Constitution VII-A).
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGmscale'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons: the scale factors are products and square roots of
% the matrix entries, so double-precision rounding (1e-12) is a safe bound
tol = 1e-12;

%% badly scaled 2 x 2 matrix

A = [1 100; 0.01 1];
[colScale, rowScale] = gmscale(A, 0, 0.9);
assert(norm(colScale - [0.1; 10]) < tol);
assert(norm(rowScale - [10; 0.1]) < tol);
% invariant: with these factors every entry of the scaled matrix equals 1
scaledMatrix = diag(1 ./ rowScale) * A * diag(1 ./ colScale);
assert(norm(scaledMatrix - ones(2, 2), 'fro') < tol);

%% matrix with zero entries

B = [4 0 0; 0 9 1];
[colScale, rowScale] = gmscale(B, 0, 0.9);
assert(norm(colScale - [1; 3; 1/3]) < tol);
assert(norm(rowScale - [4; 3]) < tol);
scaledMatrix = diag(1 ./ rowScale) * B * diag(1 ./ colScale);
% scaled non-zero entries are exactly 1, zeros stay zero
assert(norm(scaledMatrix - [1 0 0; 0 1 1], 'fro') < tol);

%% zero row and zero column are given the scale 1

[colScale, rowScale] = gmscale([0 0; 0 5], 0, 0.9);
% (the values are 1 and 5 up to rounding of about 1e-15, hence the tolerance rather than isequal)
assert(norm(colScale - [1; 1]) < tol);
assert(norm(rowScale - [1; 5]) < tol);

%% sparse input and the printed report (iprint > 0)

% sparse input is accepted; the report is printed to the console (not suppressed)
[colScale, rowScale] = gmscale(sparse([1 1e6; 1e-6 1]), 1, 0.5);
% the entries span 12 orders of magnitude, so the factors are only converged to about 1e-12
% relative accuracy; compare relative errors against 1e-9 (well above that, well below any
% real change)
expectedColScale = [1e-4; 100];
expectedRowScale = [1e4; 1e-2];
assert(max(abs(colScale - expectedColScale) ./ expectedColScale) < 1e-9);
assert(max(abs(rowScale - expectedRowScale) ./ expectedRowScale) < 1e-9);

% change the directory
cd(currentDir)
