% Compute the rich club metric for a graph
% INPUTs: adjacency matrix, nxn, k - threshold number of links
% OUTPUTs: rich club metric
% Source: Colizza, Flammini, Serrano, Vespignani, "Detecting rich-club ordering in complex networks", Nature Physics, vol 2, Feb 2006
% Other routines used: degrees.m, subgraph.m, numedges.m
% GB, Last updated: October 16, 2009

function phi=rich_club_metric(adj,k)

[deg,~,~]=degrees(adj);

Nk=find(deg>=k);       % find the nodes with degree > k
if isempty(Nk); phi = 0; return; end

adjk=subgraph(adj,Nk);
phi=2*numedges(adjk)/(length(Nk)*(length(Nk)-1));