% Converts an adjacency matrix representation to a Pajek .net read format
% INPUT: an adjacency matrix, [nxn], a filename, [string], node coordinates (optional)
% OUTPUT: text format of Pajek readable .net (or .txt) file in the same directory
% Note 1: If node coordinates are not provided, random numbers between 0 and 1 are chosen
% Note 2: to add node names, add one additional input variable, the list of
% names, indexed 1 through n, either vector or cell. Node/edge colors are
% straightforward to add with an additional variable as well, see:
% http://code.google.com/p/graphviz4matlab/source/browse/trunk/util/adj2pajek2.m?r=48
% Other routines used: issymmetric.m
% EXAMPLE
% *Vertices    4
%        1 "v1"                                     0.1000    0.5000    0.5000
%        2 "v2"                                     0.1000    0.4975    0.5000
%        3 "v3"                                     0.1000    0.4950    0.5000
%        4 "v4"                                     0.1001    0.4925    0.5000
% *Edges
%       14       31 1 
%       46       51 1 
%       51       60 1 
% GB, October 7, 2009

function []=adj2pajek(adj,filename,x,y,z)

n = size(adj,1); % number of nodes 
fid = fopen(filename,'wt','native');

fprintf(fid,'*Vertices  %6i\n',n);
if nargin <=2  % no coordinates specified - select random x,y,z=0
  for i=1:n
    fprintf(fid,'     %3i %s                     %1.4f    %1.4f   %1.4f\n',i,strcat('"v',num2str(i),'"'),rand,rand,0);
  end
elseif nargin >2 & nargin < 5  % 2D only, z is unspecified, put everything in one plane.
  for i=1:n
    fprintf(fid,'     %3i %s                     %1.4f    %1.4f   %1.4f\n',i,strcat('"v',num2str(i),'"'),x(i),y(i),0);
  end
else % 3D coords
  for i=1:n
    fprintf(fid,'     %3i %s                     %1.4f    %1.4f   %1.4f\n',i,strcat('"v',num2str(i),'"'),x(i),y(i),z(i));
  end
end

if issymmetric(adj); fprintf(fid,'*Edges\n'); end  % undirected graph version
if not(issymmetric(adj)); fprintf(fid,'*Arcs\n'); end  % directed graph version

edges=find(adj>0);
for e=1:length(edges)
    [i,j]=ind2sub([n,n],edges(e));
    fprintf(fid,'    %4i   %4i   %2i\n',i,j,adj(i,j));
end

fclose(fid);