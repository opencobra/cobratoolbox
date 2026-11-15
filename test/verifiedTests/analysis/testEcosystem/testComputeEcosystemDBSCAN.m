% The COBRAToolbox: testComputeEcosystemDBSCAN.m
%
% Purpose:
%     - computeEcosystemDBSCAN(D, epsilon, minPoints) clusters points from their matrix of
%       distances D with DBSCAN: a point is a core point when at least minPoints points
%       (itself included) are at distance <= epsilon; clusters grow from core points taken in
%       the order of the points and are labelled 0, 1, 2, ... in the order found; points
%       reachable from no core point are noise (-1).
%     - This test checks labels worked out by hand from that definition for points on a line:
%       two clusters and a noise point; border points (reachable but not core) and the
%       resulting noise; the order of the labels; a point reached twice during the search;
%       the boundary distance equal to epsilon; the default epsilon (0.05) and minPoints (5);
%       and the documented errors.
%
% Function under test:
%     src/analysis/ecosystem/computeEcosystemDBSCAN.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built distance matrices.
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
fileDir = fileparts(which('testComputeEcosystemDBSCAN'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% points on a line, given as integers divided by 10 so that distances compare without
% rounding surprises at epsilon: 0, 0.1, 0.2 | 5, 5.1 | 10
positions = [0 1 2 50 51 100] / 10;
D = abs(positions' - positions);

%% two clusters and one noise point (labels are integers: exact comparisons)

% epsilon 0.15, minPoints 2: points 1-3 each have a neighbour within 0.15 (core), as do 4
% and 5; point 6 has only itself (noise). Clusters are labelled in the order of their first
% core point: {1, 2, 3} -> 0, {4, 5} -> 1
labels = computeEcosystemDBSCAN(D, 0.15, 2);
assert(isequal(labels, [0; 0; 0; 1; 1; -1]));

%% border points and noise

% minPoints 3: only point 2 (neighbours 1, 2, 3) is a core point; 1 and 3 are border
% points of its cluster and are not expanded further; 4, 5 (two points) and 6 are noise
labels = computeEcosystemDBSCAN(D, 0.15, 3);
assert(isequal(labels, [0; 0; 0; -1; -1; -1]));

%% the order of the labels follows the order of the points

% the same points in reverse order: {10} is noise, {5.1, 5} is found first (label 0)
reverseOrder = 6:-1:1;
labels = computeEcosystemDBSCAN(D(reverseOrder, reverseOrder), 0.15, 2);
assert(isequal(labels, [-1; 0; 0; 1; 1; 1]));

%% a point reached twice and the boundary distance equal to epsilon

% epsilon 0.2 (a distance equal to epsilon is a neighbour) and minPoints 3: points 1, 2, 3
% are all neighbours of each other, so point 2 is pushed by point 1 and again by point 3
% before it is labelled; it is labelled once
labels = computeEcosystemDBSCAN(D, 0.2, 3);
assert(isequal(labels, [0; 0; 0; -1; -1; -1]));

%% default parameters: epsilon 0.05 and minPoints 5

% no point has five points within 0.05: all are noise; empty arguments mean the defaults
assert(isequal(computeEcosystemDBSCAN(D), -ones(6, 1)));
assert(isequal(computeEcosystemDBSCAN(D, [], []), -ones(6, 1)));
% five identical points (distance 0) and a sixth one far away: the five form cluster 0
Dfive = [zeros(5) ones(5, 1); ones(1, 5) 0];
assert(isequal(computeEcosystemDBSCAN(Dfive), [0; 0; 0; 0; 0; -1]));

%% errors: missing, non-numeric or non-square D, invalid epsilon or minPoints

squareMessage = 'D must be a square matrix of distances.';
assert(verifyCobraFunctionError('computeEcosystemDBSCAN', 'testMessage', squareMessage));
assert(verifyCobraFunctionError('computeEcosystemDBSCAN', 'inputs', {{1}}, 'testMessage', squareMessage));
assert(verifyCobraFunctionError('computeEcosystemDBSCAN', 'inputs', {ones(2, 3)}, 'testMessage', squareMessage));
assert(verifyCobraFunctionError('computeEcosystemDBSCAN', 'inputs', {ones(2, 2, 2)}, 'testMessage', squareMessage));
epsilonMessage = 'epsilon must be a positive scalar.';
assert(verifyCobraFunctionError('computeEcosystemDBSCAN', 'inputs', {D, -1}, 'testMessage', epsilonMessage));
assert(verifyCobraFunctionError('computeEcosystemDBSCAN', 'inputs', {D, 0}, 'testMessage', epsilonMessage));
assert(verifyCobraFunctionError('computeEcosystemDBSCAN', 'inputs', {D, [0.1 0.2]}, 'testMessage', epsilonMessage));
assert(verifyCobraFunctionError('computeEcosystemDBSCAN', 'inputs', {D, '1'}, 'testMessage', epsilonMessage));
minPointsMessage = 'minPoints must be a scalar >= 1.';
assert(verifyCobraFunctionError('computeEcosystemDBSCAN', 'inputs', {D, 0.5, 0}, 'testMessage', minPointsMessage));
assert(verifyCobraFunctionError('computeEcosystemDBSCAN', 'inputs', {D, 0.5, [1 2]}, 'testMessage', minPointsMessage));
assert(verifyCobraFunctionError('computeEcosystemDBSCAN', 'inputs', {D, 0.5, 'a'}, 'testMessage', minPointsMessage));

% change the directory
cd(currentDir)
