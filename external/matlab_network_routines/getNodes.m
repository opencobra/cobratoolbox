% return the list of nodes for varying representation types
% inputs: graph structure (matrix or cell or struct) and type of structure
% (string)
% 'type' can be: 'adj','edgelist','adjlist' (neighbor list),'inc' (incidence matrix)
% Note 1: only the edge list allows/returns non-consecutive node indexing
% Note 2: no build-in error check for graph structure - type matching

function nodes = getNodes(graph,type)

if strcmp(type,'adj') | strcmp(type,'adjlist')
    nodes=[1:max([size(graph,1) size(graph,2)])];
 
elseif strcmp(type,'edgelist')
    nodes=unique([graph(:,1)' graph(:,2)']);
    
elseif strcmp(type,'inc')
    nodes=[1:size(graph,1)];
else
    fprintf('"type" input can only be "adj" (adjacency, nxn matrix), "edgelist" (mx3 matrix)\n, "adjlist" (neighbor list, nx1 cell) and "inc" incidence (nxm matrix)\n')
end