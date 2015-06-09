% Return the list of edges for varying representation types
% Inputs: graph structure (matrix or cell or struct) and type of structure (string)
% Outputs: edge list
% 'type' can be: 'adj','edgelist','adjlist' (neighbor list),'inc' (incidence matrix)
% Note: symmetric edges will both twice, also in undirected graphs, (i.e. [n1,n2] and [n2,n1])
% Other routines used: adj2edgeL.m, adjL2edgeL.m, inc2edgeL.m

function edges = getEdges(graph,type)

if strcmp(type,'adj')
    edges=adj2edgeL(graph);
    
elseif strcmp(type,'edgelist')
    edges=graph; % the graph structure is the edge list
    
elseif strcmp(type,'adjlist')
    edges=adjL2edgeL(graph);
    
elseif strcmp(type,'inc')
    edges=inc2edgeL(graph);
else
    fprintf('"type" input can only be "adj" (adjacency, nxn matrix), "edgelist" (mx3 matrix)\n, "adjlist" (neighbor list, nx1 cell) and "inc" incidence (nxm matrix)\n')
end