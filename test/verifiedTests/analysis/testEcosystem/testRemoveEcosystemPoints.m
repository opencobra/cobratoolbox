% The COBRAToolbox: testRemoveEcosystemPoints.m
%
% Purpose:
%     - removeEcosystemPoints labels a set of grid points of an ecosystem structure as
%       unfeasible, deletes their rows from the qualitative results (qualPointIndex,
%       qualVectors, fvaResults) when these exist, and resets the clustering (clusters, k).
%       This test removes points given as indices and as a logical mask from a hand-built
%       ecosystem structure, with and without qualitative results, and checks every error the
%       function raises for an invalid input. Expected values are the input rows that remain,
%       read off the hand-built structure.
%
% Function under test:
%     src/analysis/ecosystem/removeEcosystemPoints.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; the ecosystem structure is hand-built with the fields the
%     function reads (points, feasiblePoints, qualPointIndex, qualVectors, fvaResults).
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
fileDir = fileparts(which('testRemoveEcosystemPoints'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a grid of five points [f, mu]; point 5 is already unfeasible. Qualitative results exist for
% the feasible points 1 to 4 (one row each, two reactions, two FVA bounds)
eco = struct();
eco.points = [0 0; 0.5 0; 0.5 1; 1 1; 1 2];
eco.feasiblePoints = [true; true; true; true; false];
eco.qualPointIndex = [1; 2; 3; 4];
eco.qualVectors = [1 0; 2 0; 3 -1; 4 -1];
eco.fvaResults = cat(3, [1 2; 3 4; 5 6; 7 8], [10 20; 30 40; 50 60; 70 80]);
eco.clusters = [1; 1; 2; 2];
eco.k = 2;

%% points given as indices: flags cleared, qualitative rows removed, clustering reset

ecoOut = removeEcosystemPoints(eco, [2 4]);
% the remaining rows are rows 1 and 3 of the input (exact: logical and integer data)
assert(isequal(ecoOut.feasiblePoints, [true; false; true; false; false]));
assert(isequal(ecoOut.qualPointIndex, [1; 3]));
assert(isequal(ecoOut.qualVectors, [1 0; 3 -1]));
assert(isequal(ecoOut.fvaResults, eco.fvaResults([1 3], :, :)));
assert(isempty(ecoOut.clusters) && isempty(ecoOut.k));
% the grid itself is not changed
assert(isequal(ecoOut.points, eco.points));

%% points given as a logical mask over the grid: same result as the indices

mask = [false; true; false; true; false];
assert(isequal(removeEcosystemPoints(eco, mask), ecoOut));

%% removing an already unfeasible point that has no qualitative row changes only the reset

ecoOut = removeEcosystemPoints(eco, 5);
assert(isequal(ecoOut.feasiblePoints, eco.feasiblePoints));
assert(isequal(ecoOut.qualPointIndex, eco.qualPointIndex));
assert(isequal(ecoOut.qualVectors, eco.qualVectors));
assert(isempty(ecoOut.clusters) && isempty(ecoOut.k));

%% no qualitative results yet: only the feasibility flags change, clusters and k are created

ecoGrid = struct('points', eco.points, 'feasiblePoints', eco.feasiblePoints);
ecoOut = removeEcosystemPoints(ecoGrid, 1);
assert(isequal(ecoOut.feasiblePoints, [false; true; true; true; false]));
assert(~isfield(ecoOut, 'qualPointIndex') && ~isfield(ecoOut, 'qualVectors'));
assert(isfield(ecoOut, 'clusters') && isempty(ecoOut.clusters));
assert(isfield(ecoOut, 'k') && isempty(ecoOut.k));

% an empty qualPointIndex is treated as no qualitative results
ecoGrid.qualPointIndex = [];
ecoGrid.qualVectors = [];
ecoOut = removeEcosystemPoints(ecoGrid, 1);
assert(isempty(ecoOut.qualPointIndex) && isempty(ecoOut.qualVectors));

%% qualitative point list without vectors or FVA results: only the list is filtered

ecoIndexOnly = eco;
ecoIndexOnly.qualVectors = [];
ecoIndexOnly = rmfield(ecoIndexOnly, 'fvaResults');
ecoOut = removeEcosystemPoints(ecoIndexOnly, 3);
assert(isequal(ecoOut.qualPointIndex, [1; 2; 4]));
assert(isempty(ecoOut.qualVectors));
assert(~isfield(ecoOut, 'fvaResults'));

% an empty fvaResults field stays empty
ecoIndexOnly.fvaResults = [];
ecoOut = removeEcosystemPoints(ecoIndexOnly, 3);
assert(isempty(ecoOut.fvaResults));

%% errors for missing or invalid inputs

assert(verifyCobraFunctionError('removeEcosystemPoints', 'inputs', {eco}, ...
    'testMessage', 'eco and pointIndex must be provided.'));
assert(verifyCobraFunctionError('removeEcosystemPoints', 'inputs', {1, 1}, ...
    'testMessage', 'eco must be an ecosystem structure with a grid.'));
assert(verifyCobraFunctionError('removeEcosystemPoints', 'inputs', {struct('points', 1), 1}, ...
    'testMessage', 'eco must be an ecosystem structure with a grid.'));
assert(verifyCobraFunctionError('removeEcosystemPoints', 'inputs', ...
    {struct('feasiblePoints', true), 1}, 'testMessage', 'eco must be an ecosystem structure with a grid.'));
assert(verifyCobraFunctionError('removeEcosystemPoints', 'inputs', ...
    {setfield(eco, 'feasiblePoints', []), 1}, 'testMessage', 'Feasible points have not been computed.'));
assert(verifyCobraFunctionError('removeEcosystemPoints', 'inputs', {eco, true(3, 1)}, ...
    'testMessage', 'A logical pointIndex must have one element per grid point.'));
assert(verifyCobraFunctionError('removeEcosystemPoints', 'inputs', {eco, 0}, ...
    'testMessage', 'pointIndex contains invalid indices.'));
assert(verifyCobraFunctionError('removeEcosystemPoints', 'inputs', {eco, 6}, ...
    'testMessage', 'pointIndex contains invalid indices.'));
assert(verifyCobraFunctionError('removeEcosystemPoints', 'inputs', {eco, {1}}, ...
    'testMessage', 'pointIndex contains invalid indices.'));

% change the directory
cd(currentDir)
