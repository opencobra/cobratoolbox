% Return the leaf edges of the graph: edges with one adjacent edge only
% Leaf edges have only one associated leaf node, otherwise they are single floating disconnected edges.
% Assumptions: 
% Note 1: For a directed graph, leaf edges are those that "flow into" the leaf node
% Note 2: There could be other definitions of leaves ex: farthest away from a given root node
% Note 3: Edges that are self-loops are not considered leaf edges.
% Input: adjacency matrix
% Output: set of leaf edges: a (num edges x 2) matrix where every row containts the leaf edge nodal indices
% Last updated: June 27, 2011, by GB


function edges=leaf_edges(adj)

adj=int8(adj>0);

lves=find(sum(adj)==1);  % same as leaf_nodes.m

edges=[];

for i=1:length(lves); edges=[edges; find(adj(:,lves(i))==1),lves(i)]; end