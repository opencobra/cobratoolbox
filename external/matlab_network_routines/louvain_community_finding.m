% Implementation of a community finding algorithm by Blondel et al
% Source: "Fast unfolding of communities in large networks", July 2008
% https://sites.google.com/site/findcommunities/
% Note: This is just the first step of the Louvain community
% finding algorithm, to extract fewer communities, need to repeat with the resulting modules themselves
% INPUTs: adjancency matrix, nxn
% OUTPUTs: modules, and node community labels
% Other routines used: numedges.m, kneighbors.m, purge.m

function [modules,inmodule] = louvain_community_finding(adj)

m = numedges(adj);

inmodule = {};  % inmodule{node} = module
for mm=1:length(adj); inmodule{mm} = mm; end;

modules = inmodule; % equal only for this step; modules{ind} = [nodes in module]

% for all nodes, visit and assess joining to their neighbors
% revisit until no improvement in dQ is available

converged = false;

while not(converged)
  
  converged = true;
  
  for i=1:length(adj)
    
    neigh = kneighbors(adj,i,1);
    dQ = zeros(1,length(neigh));
    
    for nei=1:length(neigh) 
      % attempt to join i and neigh(nei)
      % that is: move i from modules{i} to modules{neigh(nei)}
      % 2 dQs: modules{i} minus i & modules{neigh(nei)} plus i
      % if dQs balance is positive, do move; else: move on
      
      % sum_in = sum of weights of links inside C
      % sum_tot = sum of weights of links incident to nodes in C
      % ki = sum of weights of links incident to node i
      % ki_in = sum of weights of links from i to nodes in C
      % m = sum of weights of all links in the network
      
      if inmodule{i}==inmodule{neigh(nei)}; dQ(nei)=0; continue; end
      
      % removing i from modules{i}, expect dQ1 to be smaller than dQ2
      C = inmodule{neigh(nei)};
      sum_in = sum(sum(adj(modules{C},modules{C})))/2;
      sum_tot = sum(sum(adj(modules{C},:))); % /2 ???? -sum_in
      ki = sum(adj(i,:));
      ki_in = sum(sum(adj(i,modules{C})));
      
      dQ1 = ((sum_in+ki_in)/(2*m)-(sum_tot+ki)^2/(4*m^2)) - (sum_in/(2*m)-sum_tot^2/(4*m^2)-ki^2/(4*m^2));
      
      % adding i to modules{neigh(nei)}, this is hopefully a modularity gain
      C = inmodule{i};
      sum_in = sum(sum(adj(modules{C},modules{C})))/2;
      sum_tot = sum(sum(adj(modules{C},:))); % /2 ???? -sum_in
      ki = sum(adj(i,:));
      ki_in = sum(sum(adj(i,modules{C})));
      
      dQ2 = ((sum_in+ki_in)/(2*m)-(sum_tot+ki)^2/(4*m^2)) - (sum_in/(2*m)-sum_tot^2/(4*m^2)-ki^2/(4*m^2));
      dQ2 = - dQ2;
  
      dQ(nei) = dQ1+dQ2;
    end
    
    [maxv,maxnei]=min(dQ);   % maximizing dQ2-dQ1
    
    if maxv>0
  
      modules{inmodule{i}} = purge(modules{inmodule{i}},i);
      inmodule{i}=inmodule{neigh(maxnei)};
      modules{inmodule{neigh(maxnei)}} = [modules{inmodule{neigh(maxnei)}} i];
      
      converged = false;
    end
          
  end
  
end

% remove empty modules
new_modules={};
for mm=1:length(modules)
  if length(modules{mm})>0; new_modules{length(new_modules)+1}=modules{mm}; end
end

modules=new_modules;

fprintf('found %3i modules\n',length(modules))