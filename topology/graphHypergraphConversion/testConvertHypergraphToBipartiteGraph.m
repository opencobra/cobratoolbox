%testConvertHypergraphToBipartiteGraph
clear

flag=3;
switch flag
    case 1
    S=  [-1     0       1 ;
        1      -1      0 ;
        0      1       -1 ];
    case 2
    S=[-1;
        1;
        1;
        0];
    case 3
        load ecoli_core_xls2model.mat
        S=model.S;
end
 
tic
[A,B1]=convertHypergraphToBipartiteGraph(S,0);
toc

switch flag
    case 1 | 2
        disp('B1')
        disp(full(B1))
        disp('')
        disp('A')
        disp(full(A))
end

%compare with nikos code
tic
B2 = hypergraph2bipartgraph(S~=0);
toc

switch flag
    case 1 | 2
        disp('B2')
        disp(full(B2))
        disp('')
        disp('A')
        disp(full(A))
end

if 0
    %Compute the strongly connected components of a graph
    [sci,sizes] = scomponents(A)
    
    %should be one connected component
    % sci =
    %
    %      1
    %      1
    %      1
    %      1
    %      1
    %      1
    %
    % sizes =
    %
    %      6
end