% Build a random modular graph, given number of modules, and link density
% INPUTs: number of nodes, number of modules, total link density,
%         and proportion of links within modules compared to links across
% OUTPUTs: adjacency matrix, modules to which the nodes are assigned
% GB, Last updated: October 19, 2009

function [adj, modules] = random_modular_graph(n,c,p,r)

% n - number of nodes
% c - number of clusters/modules
% p - overall probability of attachment
% r - proportion of links within modules

z=round(p*(n-1));   % z=p(n-1) - Erdos-Renyi average degree

% assign nodes to modules: 1 -> n/c, n/c+1 -> 2n/c, ... , (c-1)n/c -> c(n/c);
modules=cell(c,1);
for k=1:c; modules{k}=round((k-1)*n/c+1):round(k*n/c); end

adj=zeros(n); % initialize adjacency matrix

for i=1:n
  for j=i+1:n
        
      module_i=ceil(c*i/n);   % the module to which i belongs to
      module_j=ceil(c*j/n);   % the module to which j belongs to
        
      if module_i==module_j
        
        % prob of attachment within module
        if rand<=r*z/(n/c-1); adj(i,j)=1; adj(j,i)=1; end
        
      else
      
        % prob of attachment across modules
        if rand<=z*(1-r)/(n-n/c); adj(i,j)=1; adj(j,i)=1; end
        
      end
  end
end