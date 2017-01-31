% Test whether a graph is bipartite, if yes, return the two vertex sets
% Inputs: graph in the form of adjancency list (neighbor list, see adj2adjL.m)
% Outputs: True/False (boolean), empty set (if False) or two sets of vertices
% Note: This only works for undirected graphs
% Last updated: April 28, 2011

function [isit,A,B]=isbipartite(L)

isit=true; % default
A=[]; B=[];

queue=[1]; % initialize to first vertex arbitrarily
visited=[]; % initilize to empty
A=[1]; % put the first node on the queue in A, arbitrarily

while not(isempty(queue))
  
  i=queue(1);
  visited=[visited, i];
  
  if length(find(A==i))>0
    for j=1:length(L{i})
      B=[B,L{i}(j)];
      if length(find(visited==L{i}(j)))==0; queue=[queue, L{i}(j)]; end
    end
      
  elseif length(find(B==i))>0
   
    for j=1:length(L{i})
      A=[A,L{i}(j)];
      if length(find(visited==L{i}(j)))==0; queue=[queue, L{i}(j)]; end
    end
  
  end
  
  queue=queue(2:length(queue)); % remove the visited node
  
  % if A and B overlap, return false, [],[] ====
  A=unique(A); B=unique(B);
  if not(isempty(intersect(A,B))); isit=false; A=[]; B=[]; return; end
  % ============================================
  
end