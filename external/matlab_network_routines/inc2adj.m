% Converts an incidence matrix representation to an adjacency
% matrix representation for an arbitrary graph
% INPUTs: incidence matrix, nxm
% OUTPUTs: adjacency matrix, nxn
% GB, October 5, 2009

function adj = inc2adj(inc)

m = size(inc,2); % number of edges
% adj = zeros(size(inc,1));  % initialize adjacency matrix
adj = sparse(size(inc,1));  % initialize adjacency matrix. Hulda: Changed to sparse.

if isempty(find(inc==-1))      % undirected graph

  for e=1:m
    ind=find(inc(:,e)==1);
    if length(ind)==2
      adj(ind(1),ind(2))=1;
      adj(ind(2),ind(1))=1;
    elseif length(ind)==1  % selfloop
      adj(ind,ind)=1;
    else
      'invalid incidence matrix'
      return
    end
  end
    
else                           % directed graph

  for e=1:m
    ind1=find(inc(:,e)==1);
    indm1=find(inc(:,e)==-1);
    if isempty(indm1) & length(ind1)==1  % selfloop
      adj(ind1,ind1)=1;
    elseif length(indm1)==1 & length(ind1)==1
      adj(indm1,ind1)=1;
    else
      'invalid incidence matrix'
      return
    end
  end

end