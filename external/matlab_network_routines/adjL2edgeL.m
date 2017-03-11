% Converts adjacency list to an edge list
% INPUTS: adjacency list
% OUTPUTS: edge list
% GB, Last Updated: October 6, 2009

function el = adjL2edgeL(adjL)

el = []; % initialize edgelist
for i=1:length(adjL)
    for j=1:length(adjL{i}); el=[el; i, adjL{i}(j), 1]; end
end