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
load([CBTDIR, filesep, 'test' filesep 'models' filesep 'ecoli_core_model.mat'], 'model');

for printLevel = 0:1
    [A, B] = convertHypergraphToBipartiteGraph(model.S, printLevel);

    % compare test data and results
    assert(isequal(A, testA))
    assert(isequal(B, testB))
end

% change the directory
cd(currentDir)
