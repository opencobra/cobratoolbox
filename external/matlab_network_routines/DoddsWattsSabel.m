% Add random cross-links on top of a perfect hierarchy
% Non-backbone edges are added with probability P(i,j)=e^(-Dij/lambda)*e^(-xij/ksi),
%     where Dij is the level of the lowest common ancestor and xij is the "organizational" distance
% Source: Dodds, Watts, Sabel, "Information exchange and the robustness of organizational networks", PNAS 100 (21): 12516-12521
% INPUTs: number of nodes (N), tree branch factor (b), m - number of additional edges to add, parameters lambda (lam) and ksi in [0,inf)
% OUTPUTs: adjacency matrix of randomized hierarchy, NxN
% Other routines used: edgeL2adj.m, canonical_nets.m, dijkstra.m

function adj = DoddsWattsSabel(N,b,m,lam,ksi)

% construct a tree with N nodes and branch factor b
adj0=edgeL2adj( canonical_nets(N,'tree',b) ); % backbone adjacency matrix

adj=adj0;
edges=0;

while edges<m
    % pick two nodes at random
    ind1=randi(N); ind2=randi(N);
    
    % if same node or already connected, keep going
    if ind1==ind2 | adj(ind1,ind2)>0 | adj(ind2,ind1)>0; continue; end
    
    % find di,dj and Dij
    [d1,path1]=dijkstra(adj0,ind1,1);  % adjacency, source, target
    [d2,path2]=dijkstra(adj0,ind2,1);
        
    for p=1:length(path1)
        p1=path1(p);
        p2=find(path2==p1);
        if length(p2)>0  % if p1 in path2
          
          di=p-1; dj=p2-1;   % di+dj is the the distance from ind1
                             % to ind2 along the backbone hierarchy
          Dij=length(path1(p:length(path1)))-1;  % the level of the
                                                 % highest common
                                                 % node on the path
                                                 % to the root
          break
        end
    end
    xij=sqrt(di^2+dj^2-2);

    % connect ind1 and ind2 with prob. e^(-Dij/lam)e^(-xij/ksi))
    if rand<exp(-Dij/lam)*exp(-xij/ksi)
        adj(ind1,ind2)=1;
        adj(ind2,ind1)=1;
        edges=edges+1;
    end
end