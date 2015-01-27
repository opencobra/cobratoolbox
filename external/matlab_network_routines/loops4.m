% Finds loops of length 4 in a graph; Note: Quite basic and slow, but works
% INPUTs: adj - adjacency matrix of graph
% OUTPUTs: number of loops of size 4
% Note: assumes undirected graph
% Other functions used: adj2adjL.m
% Last Updated: May 25, 2010, originally April 2006

function l4 = loops4(adj)

n = size(adj,1); % number of nodes
L = adj2adjL(adj); % adjacency list or list of neighbors

l4 = {};  % initialize loops of size 4

for i=1:n-1
    for j=i+1:n
        
        int=intersect(L{i},L{j});
        int=setdiff(int,[i j]);
        
        if length(int)>=2
            % enumerate pairs in the intersection
            for ii=1:length(int)-1
                for jj=ii+1:length(int)
                    loop4=sort([i,j,int(ii),int(jj)]);
                    loop4=strcat(num2str(loop4(1)),'-',num2str(loop4(2)),'-',num2str(loop4(3)),'-',num2str(loop4(4)));
                    
                    if sum(ismember(l4,loop4))>0; continue; end
                    l4{length(l4)+1}=loop4;
                
                end
            end
        end
   
        
    end
end