% Computes the average degree of neighboring nodes for every vertex
% Note: Works for weighted degrees also
% INPUTs: adjacency matrix
% OUTPUTs: average neighbor degree vector nx1
% Other routines used: degrees.m, kneighbors.m
% GB, Last updated: May 21, 2010

function ave_n_deg=ave_neighbor_deg(adj)

ave_n_deg=zeros(1,length(adj));   % initialize output vector
[deg,~,~]=degrees(adj);

for i=1:length(adj)  % across all nodes
  
  neigh=kneighbors(adj,i,1);  % neighbors of i, one link away
  if isempty(neigh); ave_n_deg(i)=0; continue; end
  ave_n_deg(i)=sum(deg(neigh))/deg(i);
  
end