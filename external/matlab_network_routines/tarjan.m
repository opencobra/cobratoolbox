% Find the giant stronly connected component in a directed graph
% Source: Tarjan, R. E. (1972), "Depth-first search and linear graph algorithms", SIAM Journal on Computing 1 (2): 146-160
% Input: graph, set of nodes and edges, in adjacency list format, ex: L{1}=[2], L{2]=[1] is the 1-2 edge
% Outputs: set of strongly connected components, in cell array format
% Other routines used: strongConnComp (embedded)
% Last updated: July 6, 2011, GB

function [GSCC,v] = tarjan(L)


GSCC = {};
ind = 1;                                 % node number counter 
S = [];                                  % An empty stack of nodes
for ll=1:length(L); v(ll).index = []; v(ll).lowlink = []; end  % initialize indices

for vi=1:length(L)
  if isempty(v(vi).index)
    [GSCC,S,ind,v]=strongConnComp(vi,S,ind,v,L,GSCC);  % visit new nodes only
  end
end


function [GSCC,S,ind,v]=strongConnComp(vi,S,ind,v,L,GSCC)

v(vi).index = ind;                % Set the depth index for vi
v(vi).lowlink = ind;
ind = ind + 1;

S = [vi S];                         % Push vi on the stack

for ll=1:length(L{vi})
  vj = L{vi}(ll);                   % Consider successors of vi 
    
  if isempty(v(vj).index)           % Was successor vj visited? 
    
    [GSCC,S,ind,v]=strongConnComp(vj,S,ind,v,L,GSCC);   % Recursion
    v(vi).lowlink = min([v(vi).lowlink, v(vj).lowlink]);
    
  elseif not(isempty(find(S==vj)))            % Is vj on the stack?
    v(vi).lowlink = min([v(vi).lowlink, v(vj).index]);
    
  end
end


if v(vi).lowlink == v(vi).index     % Is v the root of an SCC?
  
  SCC = [vi];
  while 1
    vj = S(1); S = S(2:length(S));
    SCC = [SCC vj];
     
    if vj==vi; SCC = unique(SCC); break; end
  end
  
  GSCC{length(GSCC)+1} = SCC;
  
end