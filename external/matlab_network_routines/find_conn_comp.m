% Algorithm for finding connected components in a graph
% Valid for undirected graphs only
% INPUTS: adj - adjacency matrix
% OUTPUTS: a list of the components comp{i}=[j1,j2,...jk}
% Other routines used: find_conn_compI.m (embedded), degrees.m, kneighbors.m 
% GB, Last updated: October 2, 2009


function comp_mat = find_conn_comp(adj)

[deg,~,~]=degrees(adj);   % degrees
comp_mat={};                       % initialize components matrix

for i=1:length(deg)
    if deg(i)>0
        done=0;
        for x=1:length(comp_mat)
            if length(find(comp_mat{x}==i))>0   % i in comp_mat(x).mat
                done=1;
                break
            end
        end
        if not(done)
            comp=find_conn_compI(adj,i);
            comp_mat{length(comp_mat)+1}=comp;
        end
        
    elseif deg(i)==0
        comp_mat{length(comp_mat)+1}=[i];
    end
end


function comp=find_conn_compI(adj,i)
% heuristic for finding the conn component to which "i" belongs to
% works well in practice for large datasets
% INPUTS: adjacency matrix and index of the key node
% OUTPUTS: all node indices of the nodes to which "i" belongs to
        
neigh1=kneighbors(adj,i,1);
neigh1=unique([neigh1 i]); % add i to its own component
        
while 1
  len0=length(neigh1);
  for j=1:len0
    neigh2=kneighbors(adj,neigh1(j),1);
    neigh1=unique([neigh1, neigh2]);
  end
  if len0==length(neigh1)
    comp=neigh1;
    return
  end
end