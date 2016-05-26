% Create a k-regular graph
% INPUTs: n - # nodes, k - degree of each vertex
% OUTPUTs: el - edge list of the k-regular undirected graph
% GB, Last updated: January 12, 2011

function eln = kregular(n,k)

el={};

if k>n-1; fprintf('a simple graph with n nodes and k>n-1 does not exist\n'); return; end
if mod(k,2)==1 & mod(n,2)==1; fprintf('no solution for this case\n'); return; end


half_degree=floor(k/2);  % k/2 if k even, else (k-1)/2
    

for node=1:n
    for kk=1:half_degree
      
        node_f=mod(node+kk,n);
        if node_f==0; node_f=n; end
        edge_f=strcat(num2str(node),'+',num2str(node_f));
   
        node_b=mod(node-kk,n);
        if node_b==0; node_b=n; end
        edge_b=strcat(num2str(node),'+',num2str(node_b));
        
        if sum(ismember(el,edge_f))==0
            el{length(el)+1}=edge_f;
        end
        if sum(ismember(el,edge_b))==0
            el{length(el)+1}=edge_b;
        end
            
    end
end

if mod(k,2)==1 & mod(n,2)==0
    % connect mirror nodes
    for node=1:n/2
        
        node_m=mod(node+n/2,n);
        if node_m==0; node_m=n; end
        edge_m=strcat(num2str(node),'+',num2str(node_m));
        
        if sum(ismember(el,edge_m))==0
            el{length(el)+1}=edge_m;
        end
        
    end 
end


eln=[];
for edge=1:length(el)
    edge=el{edge};
    plus=find(edge=='+');
    eln=[eln; str2num(edge(1:plus-1)), str2num(edge(plus+1:length(edge))), 1];
end
eln=symmetrize_edgeL(eln);