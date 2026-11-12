% The COBRAToolbox: testFindAndExtractMolecularGraphs.m
%
% Purpose:
%     - Regression test for findAndExtractMolecularGraphs (feature
%       20260921-154310-reacting-moiety-optimisation, spec FR-004, FR-013).
%       The expected outputs in data/bondSubgraphReference.mat were captured from the
%       function BEFORE its body was rewritten for speed, so this test fails if any of
%       its six outputs drift.
%     - Covers: the bond subgraphs and bond mapping graphs of the r0317/ACONTm/r0426
%       Recon3D fixture, as produced by the pre-change extractBondSubgraphs, so this
%       test does not depend on extractBondSubgraphs itself.
%
% Function under test:
%     src/analysis/topology/reactingMoieties/findAndExtractMolecularGraphs.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - stored reference graphs, no model and no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - COBRA Toolbox, feature 20260921-154310-reacting-moiety-optimisation
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

% only base MATLAB graph functions are used: no solver or toolbox requirement
prepareTest();

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

reference = load(['data' filesep 'bondSubgraphReference.mat']);
ciInputs = reference.ciInputs;
ciExpected = reference.ciExpected;

% --- three-input form ---
[CMTG, RMTG, CMG, RMG, conservedGroup, reactingGroups] = ...
    findAndExtractMolecularGraphs(ciInputs.BIG, ciExpected.BMG, ciExpected.bondSubgraphs);
assertMatchesReference(ciExpected, CMTG, RMTG, CMG, RMG, conservedGroup, reactingGroups, ...
    'three-input form');

% --- four-input form: EdgeIndex cache given, given empty, and given in another order ---
cacheFromBMG = cellfun(@(g) g.Edges.EdgeIndex, ciExpected.BMG, 'UniformOutput', false);
cacheForms = {cacheFromBMG, [], cellfun(@flipud, cacheFromBMG, 'UniformOutput', false)};
cacheLabels = {'four-input form, cache from BMG', 'four-input form, empty cache', ...
    'four-input form, cache in reversed order'};
for c = 1:numel(cacheForms)
    [CMTG, RMTG, CMG, RMG, conservedGroup, reactingGroups] = findAndExtractMolecularGraphs( ...
        ciInputs.BIG, ciExpected.BMG, ciExpected.bondSubgraphs, cacheForms{c});
    assertMatchesReference(ciExpected, CMTG, RMTG, CMG, RMG, conservedGroup, reactingGroups, ...
        cacheLabels{c});
end

%% One subgraph is the whole conserved group: there is no reacting group, so RMTG and RMG are empty
% (the reacting transition graph is built from an empty set of subgraphs)
[CMTG, RMTG, CMG, RMG, conservedGroup, reactingGroups] = findAndExtractMolecularGraphs( ...
    ciInputs.BIG, ciExpected.BMG(1, :), ciExpected.bondSubgraphs(1, :));
assert(isequal(conservedGroup, 1) && isempty(reactingGroups), ...
    'A single subgraph must be the conserved group, with no reacting group.');
assert(numnodes(RMTG) == 0 && numedges(RMTG) == 0, 'With no reacting group RMTG must be empty.');
assert(numedges(RMG) == 0 && numnodes(RMG) == numnodes(ciInputs.BIG), ...
    'With no reacting group RMG must hold the nodes of BIG and no edges.');
assert(numedges(CMTG) == numedges(ciExpected.bondSubgraphs{1, 1}), ...
    'The conserved transition graph must be the single subgraph.');
assert(numedges(CMG) == numel(ciExpected.BMG{1}.Edges.EdgeIndex), ...
    'The conserved molecular graph must hold the edges of the single bond mapping graph.');

% change the directory
cd(currentDir)

function assertMatchesReference(expected, CMTG, RMTG, CMG, RMG, conservedGroup, reactingGroups, label)
% Assert that the six outputs equal the pre-change reference (groups: value and orientation).
assert(isequal(conservedGroup, expected.conservedGroup), ...
    sprintf('findAndExtractMolecularGraphs conservedGroup differs from the reference (%s).', label));
assert(isequal(reactingGroups, expected.reactingGroups), ...
    sprintf('findAndExtractMolecularGraphs reactingGroups differs from the reference (%s).', label));
assert(isGraphEqual(CMTG, expected.CMTG), ...
    sprintf('findAndExtractMolecularGraphs CMTG differs from the reference (%s).', label));
assert(isGraphEqual(RMTG, expected.RMTG), ...
    sprintf('findAndExtractMolecularGraphs RMTG differs from the reference (%s).', label));
assert(isGraphEqual(CMG, expected.CMG), ...
    sprintf('findAndExtractMolecularGraphs CMG differs from the reference (%s).', label));
assert(isGraphEqual(RMG, expected.RMG), ...
    sprintf('findAndExtractMolecularGraphs RMG differs from the reference (%s).', label));
end

function isSame = isGraphEqual(A, B)
% True when two graph/digraph objects have the same class and equal Nodes and Edges tables
% (table equality: variable names, types, values and row order all have to match).
isSame = strcmp(class(A), class(B)) && isequal(A.Nodes, B.Nodes) && isequal(A.Edges, B.Edges);
end
