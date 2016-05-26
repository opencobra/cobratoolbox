% Determine if a graph is connected
% INPUTS: adjacency matrix
% OUTPUTS: Boolean variable {0,1}
% Note: this only works for undirected graphs
% Idea by Ed Scheinerman, circa 2006, source: http://www.ams.jhu.edu/~ers/matgraph/
%                                     routine: matgraph/@graph/isconnected.m

function S = isconnected(adj)

if not(isempty(find(sum(adj)==0))); S = false; return; end

n = length(adj);
x = [1; zeros(n-1,1)]; % [1,0,...0] nx1 vector 

while 1
     y = x;
     x = adj*x + x;
     x = x>0;
     
     if x==y; break; end

end

S = true;
if sum(x)<n; S = false; end


% Alternative 0 ==========================================================
% If the algebraic connectivity is > 0 then the graph is connected
% a=algebraic_connectivity(adj);
% S = false; if a>0; S = true; end

% Alternative 1 ==========================================================
% Uses the fact that multiplying the adj matrix to itself k times give the
% number of ways to get from i to j in k steps. If the end of the
% multiplication in the sum of all matrices there are 0 entries then the
% graph is disconnected. Computationally intensive, but can be sped up by
% the fact that in practice the diameter is very short compared to n, so it
% will terminate in order of 5 steps.
% function S=isconnected(el):
%     
%     S=false;
%     
%     adj=edgeL2adj(el);
%     n=numnodes(adj); % number of nodes
%     adjn=zeros(n);
% 
%     adji=adj;
%     for i=1:n
%         adjn=adjn+adji;
%         adji=adji*adj;
% 
%         if length(find(adjn==0))==0
%             S=true;
%             return
%         end
%     end

% Alternative 2 ==========================================================
% Find all connected components, if their number is 1, the graph is
% connected. Use find_conn_comp(adj).