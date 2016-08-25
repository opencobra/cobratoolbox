% Returns the complement of a graph
% INPUTs: adj - original graph adjacency matrix
% OUTPUTs: complement graph adjacency matrix
% Note: Assumes no multiedges
% GB, February 2, 2006

function adj_c = graph_complement(adj)

adj_c=ones(size(adj))-adj;