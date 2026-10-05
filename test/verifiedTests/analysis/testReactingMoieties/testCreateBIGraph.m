% The COBRAToolbox: testCreateBIGraph.m
%
% Purpose:
%     - Characterization test for createBIGraph (feature 029-vectorize-atm-loops,
%       tasks.md T013a, spec Edge Cases, research.md R4/R5). Pins the current
%       behaviour on small synthetic bond graphs with hand-computed expected
%       outputs, so the vectorized rewrite of its edge-expansion loop can be
%       checked against the same expectations. Cases (a)-(d), (f) and (g) were
%       written first and passed against the unmodified function. Case (e) is the
%       one deliberate behaviour change: the unmodified function crashed there, and
%       feature 029 makes it return an empty BIG instead.
%     - Covers: (a) all Weight == 1; (b) mixed weights expand edge-major with
%       Weight forced to 1; (c) a cell-array edge property copied per instance;
%       (d) the energy node (Element == 'E') and its edges removed; (e) zero
%       edges left after that removal; (f) EdgeIndex == (1:n)'; (g) a
%       non-integer, a zero and a negative weight behave as the original
%       `for bInstance = 1:bondMult` loop (truncate; emit nothing).
%
% Authors:
%     - COBRA Toolbox, feature 029-vectorize-atm-loops

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% --- (b), (c), (d), (f): mixed weights, a cell property, and an energy node ---
% Edges are listed in the sorted (min, max) endpoint order that graph() stores them in,
% so the expected expanded order below is the loop's edge-major, instance-minor order.
nodeTable = table({'C'; 'C'; 'O'; 'N'; 'H'; 'E'}, (1:6)', ...
    'VariableNames', {'Element', 'AtomIndex'});
edgeTable = table([1 2; 1 3; 2 4; 4 5; 5 6], [1; 2; 3; 1; 1], [10; 11; 12; 13; 14], ...
    {'CC'; 'CO'; 'CN'; 'NH'; 'HE'}, ...
    'VariableNames', {'EndNodes', 'Weight', 'BondIndex', 'BondLabel'});
BG = graph(edgeTable, nodeTable);

BIG = createBIGraph(BG);

% (d) the energy node is removed, with its incident edge (5,6)
assert(isequal(BIG.Nodes, nodeTable(1:5, :)), ...
    'createBIGraph must keep every non-energy node and drop the Element == ''E'' node.');
% (b) one row per bond instance: 1 + 2 + 3 + 1 = 7, edge-major
expectedEndNodes = [1 2; 1 3; 1 3; 2 4; 2 4; 2 4; 4 5];
assert(numedges(BIG) == 7, 'createBIGraph must emit one edge per bond instance (sum of weights, excluding energy-node edges).');
assert(isequal(BIG.Edges.EndNodes, expectedEndNodes), ...
    'createBIGraph must expand edges in edge-major, instance-minor order.');
assert(isequal(BIG.Edges.Weight, ones(7, 1)), 'createBIGraph must set Weight to 1 for every expanded instance.');
assert(isequal(BIG.Edges.BondIndex, [10; 11; 11; 12; 12; 12; 13]), ...
    'createBIGraph must copy numeric edge properties once per instance.');
% (c) cell-array property copied per instance
assert(isequal(BIG.Edges.BondLabel, {'CC'; 'CO'; 'CO'; 'CN'; 'CN'; 'CN'; 'NH'}), ...
    'createBIGraph must copy cell-array edge properties once per instance.');
% (f) EdgeIndex numbers the expanded edges 1..n
assert(isequal(BIG.Edges.EdgeIndex, (1:7)'), 'createBIGraph must assign EdgeIndex = (1:n)''.');
assert(isa(BIG, 'digraph'), 'createBIGraph must return a digraph.');

% --- (a) every Weight == 1: exactly one output row per input edge ---
nodesA = table({'C'; 'O'; 'N'}, (1:3)', 'VariableNames', {'Element', 'AtomIndex'});
edgesA = table([1 2; 1 3; 2 3], [1; 1; 1], [21; 22; 23], ...
    'VariableNames', {'EndNodes', 'Weight', 'BondIndex'});
BIGA = createBIGraph(graph(edgesA, nodesA));
assert(isequal(BIGA.Edges.EndNodes, [1 2; 1 3; 2 3]), 'With every Weight == 1, createBIGraph must emit one row per input edge.');
assert(isequal(BIGA.Edges.BondIndex, [21; 22; 23]), 'With every Weight == 1, edge properties must be carried over unchanged.');
assert(isequal(BIGA.Edges.EdgeIndex, (1:3)'), 'EdgeIndex must be (1:n)'' when no edge is expanded.');

% --- (g) non-integer, zero and negative weights follow the loop's 1:bondMult semantics ---
% 1:2.7 is [1 2] (two instances); 1:0 and 1:-1 are empty (no instances).
nodesG = table({'C'; 'O'; 'N'; 'S'}, (1:4)', 'VariableNames', {'Element', 'AtomIndex'});
edgesG = table([1 2; 1 3; 2 4], [2.7; 0; -1], [41; 42; 43], ...
    'VariableNames', {'EndNodes', 'Weight', 'BondIndex'});
BIGG = createBIGraph(graph(edgesG, nodesG));
assert(isequal(BIGG.Edges.EndNodes, [1 2; 1 2]), ...
    'A non-integer weight must truncate (2.7 -> 2 instances) and zero/negative weights must emit nothing.');
assert(isequal(BIGG.Edges.BondIndex, [41; 41]), 'Only the truncated non-integer-weight edge may contribute instances.');
assert(isequal(BIGG.Edges.Weight, [1; 1]), 'Every emitted instance must have Weight 1.');

% --- (e) zero edges left once the energy node is removed ---
% Placed last on purpose. The pre-change createBIGraph crashed here
% (MATLAB:table:UnrecognizedVarNameDeleting, line 81); feature 029 fixes that and
% returns an empty BIG (spec Clarifications, zero-edge entry). A run against the old
% code therefore checks every other case before failing here.
nodesE = table({'C'; 'E'}, (1:2)', 'VariableNames', {'Element', 'AtomIndex'});
edgesE = table([1 2], 1, 31, 'VariableNames', {'EndNodes', 'Weight', 'BondIndex'});
BIGE = createBIGraph(graph(edgesE, nodesE));
assert(numedges(BIGE) == 0, 'createBIGraph must return no edges when every edge touches the energy node.');
assert(isequal(BIGE.Nodes, nodesE(1, :)), 'createBIGraph must still keep the non-energy nodes when no edges remain.');

% change the directory back
cd(currentDir);
