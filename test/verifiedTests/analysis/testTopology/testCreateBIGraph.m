% The COBRAToolbox: testCreateBIGraph.m
%
% Purpose:
%     - createBIGraph turns a bond graph into a bond-instance graph: the energy node "E" is removed and every edge of bond multiplicity w is replaced by w parallel edges of weight 1.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/topology/reactingMoieties/createBIGraph.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects / quirks pinned (NOT fixed here):
%     If removing the energy node leaves no edges, the function errors inside MATLAB (an empty edge property cannot be assigned to the new graph). The error is pinned below.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCreateBIGraph'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% energy node removed, multiple bonds expanded into parallel edges

% bond graph: C1 = O2 (double bond), O2 - C3 (single bond), C3 - E4 (energy node)
bondGraph = graph([1 2 3], [2 3 4], [2 1 1]);
bondGraph.Nodes.Element = {'C'; 'O'; 'C'; 'E'};
bondGraph.Edges.Bond = [10; 20; 30];       % an extra edge property that must be carried along

bondInstanceGraph = createBIGraph(bondGraph);

% the result is a directed graph without the energy node
assert(isa(bondInstanceGraph, 'digraph'));
assert(numnodes(bondInstanceGraph) == 3);
assert(isequal(bondInstanceGraph.Nodes.Element, {'C'; 'O'; 'C'}));

% the double bond appears twice, the single bond once; the edge to E is gone
assert(isequal(bondInstanceGraph.Edges.EndNodes, [1 2; 1 2; 2 3]));
% every instance has weight 1 and keeps the other properties of its bond
assert(isequal(bondInstanceGraph.Edges.Weight, [1; 1; 1]));
assert(isequal(bondInstanceGraph.Edges.Bond, [10; 10; 20]));
% instances are numbered consecutively
assert(isequal(bondInstanceGraph.Edges.EdgeIndex, [1; 2; 3]));

%% a graph whose only edges touch the energy node cannot be converted

energyOnly = graph([1 2], [2 3], [1 1]);
energyOnly.Nodes.Element = {'C'; 'E'; 'O'};
assert(verifyCobraFunctionError('createBIGraph', 'inputs', {energyOnly}));

% change the directory
cd(currentDir)
