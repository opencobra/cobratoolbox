% Converts a string graph representation to an adjacency matrix
% Note: The string nomenclature is arbitrary
% INPUTs: string variable of the format: .i1.j1.k1,.i2.j2.k2,....
% OUTPUTs: adjacency matrix, nxn
% Note 1: Valid for a general graph
% Note 2: This is the reverse routine for adj2str.m
% GB, October 6, 2009

function adj = str2adj(str)

commas=find(str==',');
n=length(commas); % number of nodes
adj=zeros(n); % initialize adjacency matrix

if commas(1)>1
  % Extract the neighbors of the first node only
  neigh=str(1:commas(1)-1);
  dots=find(neigh=='.');
  for d=1:length(dots)-1; adj(1,str2num(neigh(dots(d)+1:dots(d+1)-1)))=1; end
  adj(1,str2num(neigh(dots(length(dots))+1:length(neigh))))=1;
end

% Extract the neighbors of the remaining 2:n nodes
for i=2:n
    neigh=str(commas(i-1)+1:commas(i)-1);
    if isempty(neigh); continue; end
    
    dots=find(neigh=='.');
    for d=1:length(dots)-1; adj(i,str2num(neigh(dots(d)+1:dots(d+1)-1)))=1; end

    adj(i,str2num(neigh(dots(length(dots))+1:length(neigh))))=1;

end