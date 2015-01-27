% Edge betweenness routine, based on shortest paths
% INPUTs: edgelist, mx3, m - number of edges
% OUTPUTs: w - betweenness per edge
% Note: Valid for undirected graphs only
% Source: Newman, Girvan, "Finding and evaluating community structure in networks"
% Other routines used: adj2edgeL.m, numnodes.m, numedges.m, kneighbors.m
% Last modified: November 14, 2009

function ew = edge_betweenness(adj)

el=adj2edgeL(adj);  % the corresponding edgelist
n = numnodes(adj);  % number of nodes
m = numedges(adj);  % number of edges

ew = zeros(size(el,1),3); % edge betweenness - output


for s=1:n % across all (source) nodes
    
    % compute the distances and weights starting at source node i
    d=inf(n,1); w=inf(n,1);
    d(s)=0; w(s)=1; % source node distance and weight
    queue=[s];      % add to queue
    visited=[];
    
    while not(isempty(queue))
        j=queue(1); % pop first member
        visited=[visited j];
        neigh=kneighbors(adj,j,1); % find all adjacent nodes, 1 step away
        
        for x=1:length(neigh)  % add to queue if unvisited
            nei=neigh(x);
            
            if isempty(find(visited==nei)) & isempty(find(queue==nei)); queue=[queue nei]; end
        
        end
        for x=1:length(neigh)
        
            nei=neigh(x);
            if d(nei)==inf   % not assigned yet
                d(nei)=1+d(j);
                w(nei)=w(j);
            elseif d(nei)<inf & d(nei)==d(j)+1  % assigned already, add the new path
                w(nei)=w(nei)+w(j);
            elseif d(nei)<inf & d(nei)<d(j)+1
                'do nothing';
            end
        end
        queue=queue(2:length(queue));  % remove the first element
    end
    
    eww = zeros(size(el,1),3);   % edge betweenness for every source node (iteration)
    
    % find every leaf - no path from "s" to other vertices goes through the leaf
    leaves = find(d==max(d)); % farthest away from source
    for l=1:length(leaves)
        leaf=leaves(l);
        neigh=kneighbors(adj,leaf,1);
        nei2rem=[];
        for x=1:length(neigh)
            
            if isempty(find(leaves==neigh(x))); nei2rem=[nei2rem neigh(x)]; end
        
        end
        neigh=nei2rem;  % remove other leaves among the neighbors
        for x=1:length(neigh)
            indi=find(el(:,1)==neigh(x));
            indj=find(el(:,2)==leaf);
            indij=intersect(indi,indj);   % should be only one element at the intersection
            eww(indij,3)=w(neigh(x))/w(leaf);
        end
    end
    
    dsort=unique(d);
    dsort=-sort(-dsort);  % reverse sort of unique distance values
    
    for x=1:length(dsort)
        leaves=find(d==dsort(x));
        for l=1:length(leaves)
            leaf=leaves(l);
            neigh=kneighbors(adj,leaf,1);
            up_neigh=[]; down_neigh=[];
            for x=1:length(neigh)
                if d(neigh(x))<d(leaf)
                    up_neigh=[up_neigh neigh(x)];
                elseif d(neigh(x))>d(leaf)
                    down_neigh=[down_neigh neigh(x)];
                end
            end
            sum_down_edges=0;
            for x=1:length(down_neigh)
                indi=find(el(:,1)==leaf);
                indj=find(el(:,2)==down_neigh(x));
                indij=intersect(indi,indj);
                sum_down_edges=sum_down_edges+eww(indij,3);
            end
            for x=1:length(up_neigh)
                indi=find(el(:,1)==up_neigh(x));
                indj=find(el(:,2)==leaf);
                indij=intersect(indi,indj);
                eww(indij,3)=w(up_neigh(x))/w(leaf)*(1+sum_down_edges);
            end
        end
    end
    
    for e=1:size(ew,1); ew(e,3)=ew(e,3)+eww(e,3); end

end

for e=1:size(ew,1)
    ew(e,1)=el(e,1);
    ew(e,2)=el(e,2);
    ew(e,3)=ew(e,3)/n/(n-1);   % normalize by the total number of paths
end