% The minimum vertex eccentricity is the graph radius
% Inputs: adjacency matrix (nxn)
% Outputs: graph radius
% Other routines used: vertex_eccentricity.m

function Rg=graph_radius(adj)

Rg=min( vertex_eccentricity(adj) );