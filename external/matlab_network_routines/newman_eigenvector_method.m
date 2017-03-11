% Find the "optimal" number of communities given a network using an eigenvector method
% Source: MEJ Newman: Finding community structure using the eigenvectors of matrices, arXiv:physics/0605087
% Newman, "Modularity and community structure in networks", arxiv.org/pdf/physics/0602124v1
% Q=(s^T)Bs, Bij=Aij-kikj/2m
% Bij^g=Bij - delta_ij * (sum k over g)B_ik
% Bij^g=(Aij-kikj/2m)-delta_ij(sum k over g)(A(g)_ik-deg(g)_i deg(k)_j/2(m_g))
% Bij^g=(Aij-kikj/2m)-delta_ij(k_i^(g)-k_i*sum(deg^(g)/2m)
% STEPS:
% 1 define current modularity matrix
% 2 compute eigenvector corresp. to largest eigenvalue
% 3 separate into 2 modules based on signs in eigenvector
% terminate when max eigenvalue is 0 for all subgraphs
% 
% Other functions used: numedges.m, degrees.m, subgraph.m, isconnected.m
% GB, Last modified: November 17, 2009

function modules=newman_eigenvector_method(adj)

modules={};
n=length(adj);
m=numedges(adj);
[deg,~,~]=degrees(adj);
queue{1}=[1:n];   % append all nodes to the queue


while length(queue)>0  % while there is always a divisible subgraph
    
    % compute modularity matrix- Bg
    G=queue{1};            % nodes in current (sub)graph to partition
    adjG=subgraph(adj,G);  % first adjG same as original adj
        
    [degG,~,~]=degrees(adjG);
    Bg=zeros(length(G));
    
    for i=1:length(G)   % nodes are G(i)
        for j=i:length(G)  % nodes are G(j)
                      
          % Bij = adj(G(i),G(j))-deg(G(i))*deg(G(j))/(2*m)
          % delta_ij = (i==j)
          % k_i^g - k_i (d_g)/2m = degG(i)-deg(G(i))*sum(degG)/(2*m)
          Bg(i,j)=( adj(G(i),G(j))-deg(G(i))*deg(G(j))/(2*m) )-(i==j)*(degG(i)-deg(G(i))*sum(degG)/(2*m));
          Bg(j,i)=Bg(i,j);
          
        end
    end
    
    [V,E]=eig(Bg);  % eigenvalues
    
    if abs(max(diag(E)))<=10^(-5) % terminate - indivisible
        queue=queue(2:length(queue));
        modules=[modules G];
        continue
    end
    
    [~,indmax]=max(diag(E));
    u1=V(:,indmax);
    comm1=find(u1>0); comm2=find(u1<0);  % indices in G
    
    if not(isconnected(adj(G(comm1),G(comm1)))) | not(isconnected(adj(G(comm2),G(comm2))))
      
      queue=queue(2:length(queue));   % remove(G)
      modules=[modules G];            % keep original G as indivisible
      %'found disconnected subgraphs - do not explore this option'
      
      continue
    
    end

    queue=[queue G(comm1) G(comm2)];
    queue=queue(2:length(queue));
    
end