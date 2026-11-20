% The COBRAToolbox: testFvaJaccardIndex.m
%
% Purpose:
%     - fvaJaccardIndex(minFlux, maxFlux) compares, reaction by reaction, the flux ranges
%       [minFlux(i, j), maxFlux(i, j)] of k > 1 models: J(i) = length of the intersection of
%       the k ranges / length of their union, 0 when the ranges do not overlap and 1 when the
%       union is shorter than 1e-6 (fixed fluxes). This test checks hand-calculated indices for
%       partly overlapping, identical, disjoint, touching and fixed ranges, three models, the
%       shape of the output, and the two documented errors.
%
% Function under test:
%     src/analysis/FVA/fvaJaccardIndex.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built flux ranges.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFvaJaccardIndex'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the indices are ratios of differences of small numbers written exactly in binary or of
% one-third; 1e-12 allows only rounding of the division
tol = 1e-12;

%% two models: overlap, identical, disjoint, touching and fixed ranges (hand calculation)

% row 1: [0, 2] and [1, 3]: intersection [1, 2] (length 1), union [0, 3] (length 3) -> 1/3
% row 2: [0, 1] twice: intersection = union -> 1
% row 3: [-1, 1] and [2, 4]: no overlap (gap of 1) -> 0
% row 4: [0, 1] and [1, 2]: they only touch, intersection of length 0, union 2 -> 0
% row 5: both fixed at 5: union of length 0 (< 1e-6) -> 1 by definition
% row 6: [0, 0] and [0, 1e-7]: union shorter than 1e-6 -> 1 by definition
minFlux = [0 1; 0 0; -1 2; 0 1; 5 5; 0 0];
maxFlux = [2 3; 1 1; 1 4; 1 2; 5 5; 0 1e-7];
J = fvaJaccardIndex(minFlux, maxFlux);
assert(isequal(size(J), [6, 1]));
assert(max(abs(J - [1/3; 1; 0; 0; 1; 1])) < tol);

%% three models: the intersection and union of all k ranges

% row 1: [0, 4], [1, 5], [2, 6]: intersection [2, 4] (2), union [0, 6] (6) -> 1/3
% row 2: [-2, 2], [-1, 1], [0, 3]: intersection [0, 1] (1), union [-2, 3] (5) -> 1/5
% row 3: [0, 1], [0, 1], [3, 4]: the third range is disjoint from the others -> 0
minFlux = [0 1 2; -2 -1 0; 0 0 3];
maxFlux = [4 5 6; 2 1 3; 1 1 4];
J = fvaJaccardIndex(minFlux, maxFlux);
assert(isequal(size(J), [3, 1]));
assert(max(abs(J - [1/3; 1/5; 0])) < tol);

%% errors: different numbers of models in minFlux and maxFlux, and a single model

assert(verifyCobraFunctionError('fvaJaccardIndex', 'inputs', {zeros(3, 2), ones(3, 3)}, ...
    'testMessage', 'The size the minFlux and maxFlux matrices is different.'));
assert(verifyCobraFunctionError('fvaJaccardIndex', 'inputs', {zeros(3, 1), ones(3, 1)}, ...
    'testMessage', 'In order to calculate a Jaccard index, please input flux vectors of more than only one model (k > 1).'));

% change the directory
cd(currentDir)
