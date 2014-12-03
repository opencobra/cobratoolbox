% A relaxed/smoothed definition of diameter: the number "d" at which
% a threshold fraction "p" of pairs of nodes are at distance at most
% "d". Can be non-integer using interpolation.
% Idea: Leskovec et al, "Graphs over Time: Densiﬁcation Laws, Shrinking Diameters and Possible Explanations"
% Input: adjacency matrix of graph and diameter threshold, p in [0,1]
% Output: relaxed or "effective" diameter
% Other routines used: simple_dijkstra.m

function diam = smooth_diameter(adj,p)

n=size(adj,1);

dij=[];
for i=1:n; dij=[dij; simple_dijkstra(adj,i)]; end

dij(find(dij==0))=inf;
for i=1:n-1; ddist(i)=length(find(dij<=i)); end
ddist=ddist/(n*(n-1));

lb = max(find(ddist<=p)); % lower bound
ub = min(find(ddist>=p)); % upper bound

if p==1; diam = ub;
elseif ub==lb; diam = lb;
elseif p<ddist(1); diam=0;
else
  % interpolation: yj = y1 + (y2-y1)*(xi-x1)/(x2-x1), where ys are diameters, xs are fractions
  diam = lb + (ub - lb) * (p - ddist(lb)) / (ddist(ub)-ddist(lb));
end