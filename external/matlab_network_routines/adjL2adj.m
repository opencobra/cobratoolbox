% Convert an adjacency list to an adjacency matrix
% INPUTS: adjacency list: {n}
% OUTPUTS: adjacency matrix nxn
% Note: Assume that if node i has no neighbours, L{i}=[];
% GB, Last updated: October 6, 2009

function adj=adjL2adj(adjL)

adj = zeros(length(adjL));

for i=1:length(adjL)
    for j=1:length(adjL{i}); adj(i,adjL{i}(j))=1; end
end