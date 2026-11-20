% The COBRAToolbox: testConvertHypergraphToBipartiteGraph.m
%
% Purpose:
%     - testconvertHypergraphToBipartiteGraph tests the convertHypergraphToBipartiteGraph
%     function and its different methods
%
% Note:
%      - test can be extended to test the performance of ConvertHypergraphToBipartiteGraph
%        with B2 = hypergraph2bipartgraph(S~=0);
%
% Function under test:
%     src/analysis/topology/graphHypergraphConversion/convertHypergraphToBipartiteGraph.m
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: trailing empty hyperedges are missing from A and B
%       SEVERITY: wrong-result
%       TRIGGER: [A, B] = convertHypergraphToBipartiteGraph([-1 0 0; 2 -1 0]) (m = 2, n = 3,
%         the last hyperedge empty); also convertHypergraphToBipartiteGraph(zeros(2, 2))
%       OBSERVED: size(A) = [4 4] and size(B) = [4 3] (R2025a, 2026-11-15); for zeros(2, 2)
%         A and B are 0 x 0. B = sparse(rowIndices, colIndices, values) (line 46) takes its row
%         count from the largest index, m + the last nonempty column, and A = inc2adj(B ~= 0)
%         (line 56) inherits it, so an empty hyperedge in the middle is kept as an isolated node
%         but one at the end is not
%       EXPECTED: size(A) = [5 5] and size(B) = [5 3] with node 5 isolated (OUTPUTS: "A:
%         (m+n) x (m+n) adjacency matrix", "B: (m+n) x nnz(S) incidence matrix"); for
%         zeros(2, 2) a 4 x 4 zero A and a 4 x 0 B
%       LINES: 46, 56
%
%     (entry added by feature 20261113-142115-test-backfill-tiers, FR-012; the assertions below
%     are unchanged)
%
% Author:
%     - original file: Marouen BEN GUEBILA - 10/02/2017
%     - integration of test to CI: Laurent Heirendt - February 2017

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConvertHypergraph2BipartiteGraph'));
cd(fileDir);

for flag = 1:2
    if flag == 1
        S = [-1  0  1 ;
              1 -1  0 ;
              0  1 -1 ];
    elseif flag == 2
        S = [-1; 1; 1; 0];
    end

    [A, B1] = convertHypergraphToBipartiteGraph(S);

    fprintf('\nB1\n');
    disp(full(B1));
    fprintf('\nA\n');
    disp(full(A));

    %Compute the strongly connected components of a graph
    [sci, sizes] = scomponents(A);

    if flag == 1
        assert(isequal(sci, [1; 1; 1; 1; 1; 1]));
        assert(sizes == 6)
    elseif flag == 2
        assert(isequal(sci, [1; 1; 1; 2; 1;]));
        assert(isequal(sizes, [4; 1]))
    end
end

% test with ecoli_core_model
load('testDataGraph2Hypergraph.mat');
model = getDistributedModel('ecoli_core_model.mat');

for printLevel = 0:1
    [A, B] = convertHypergraphToBipartiteGraph(model.S, printLevel);

    % compare test data and results
    assert(isequal(A, testA))
    assert(isequal(B, testB))
end

% change the directory
cd(currentDir)
