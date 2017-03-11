% Converts an adjacency matrix to a one-line string representation
% INPUTS: adjacency matrix, nxn
% OUTPUTS: string
% The nomenclature used to construct the string is arbitrary. Here we use
% .i1.j1.k1,.i2.j2.k2,....
% Other routines used: kneighbors.m
% GB, Last updated: October 6, 2009

function str=adj2str(adj)

% in '.i1.j1.k1,.i2.j2.k2,....', dot: signifies new neighbor, comma: next node
str='';
n=length(adj);

for i=1:n
    neigh=kneighbors(adj,i,1);
    for k=1:length(neigh); str=strcat(str,'.',num2str(neigh(k))); end
    str=strcat(str,','); % close this node's neighbors list
end