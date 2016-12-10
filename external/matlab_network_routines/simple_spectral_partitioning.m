% Uses the fiedler vector to assign nodes to groups
% INPUTS: adj - adjancency matrix, k - desired number of nodes in groups [n1, n2, ..], [optional]
% OUTPUTs: modules - [k] partitioned groups of nodes
% Other functions used: fiedler_vector.m

function modules = simple_spectral_partitioning(adj,k)

% find the Fiedler vector: eigenvector corresponding to the second smallest eigenvalue of the Laplacian matrix
fv = fiedler_vector(adj);
[~,I]=sort(fv);

% depending on k, partition the nodes
if nargin==1
    
    modules{1}=[]; modules{2}=[];
    % choose 2 groups based on signs of fv components
    for v=1:length(fv)
        if fv(v)>0; modules{2} = [modules{2}, v]; end
        if fv(v)<=0; modules{1} = [modules{1}, v]; end
    end
end

if nargin==2

  k = [0 k];
    
  for kk=1:length(k)
        
    modules{kk}=[];
    for x=1:k(kk); modules{kk} = [modules{kk} I(x+k(kk-1))]; end
         
  end

  modules = modules(2:length(modules));
end


set(gcf,'Color',[1 1 1])
subplot(1,2,1)
plot(fv(I),'k.');
xlabel('index i')
ylabel('fv(i)')
title('sorted fiedler vector')
axis('tight')
axis('square')

subplot(1,2,2)
spy(adj(I,I),'k')
title('sorted adjacency matrix')