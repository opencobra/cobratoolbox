% Converts an edgelist matrix representation to a Pajek .net readable format
% INPUT: an edgelist matrix, [mx3], a filename, [string]
% OUTPUT: text format of Pajek readable .net file
% See also: adj2pajek.m
% Other routines used: edgeL2adj.m, issymmetric.m
% EXAMPLE
% *Vertices    4
%        1 "14"                                     0.1000    0.5000    0.5000
%        2 "31"                                     0.1000    0.4975    0.5000
%        3 "46"                                     0.1000    0.4950    0.5000
%        4 "51"                                     0.1001    0.4925    0.5000
% *Edges
%       14       31  1 
%       46       51  1 
%       51       60  1 
% GB, Last updated: October 7, 2009

function []=edgeL2pajek(el,filename)

nodes=unique([el(:,1)', el(:,2)']);
n=length(nodes);  % number of nodes
m = size(el,1); % number of edges

fid = fopen(filename,'wt','native');

fprintf(fid,'*Vertices  %6i\n',n);

for i=1:n
    fprintf(fid,'     %3i %s                     %1.4f    %1.4f   %1.4f\n',i,strcat('"v',num2str(nodes(i)),'"'),rand,rand,0);
end

adj = edgeL2adj(el);
if issymmetric(adj); fprintf(fid,'*Edges\n'); end;  % undirected version
if not(issymmetric(adj)); fprintf(fid,'*Arcs\n'); end;  % directed version
for i=1:m
  fprintf(fid,'    %4i   %4i   %2i\n',el(i,1),el(i,2),el(i,3));
end

fclose(fid);