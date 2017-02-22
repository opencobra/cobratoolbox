% Newman fast community finding algorithm
% Source: "Fast algorithm for detecting community structure in networks", Mark Newman
% Input: adjacency matrix
% Output: group (cluster) formation over time, modularity metric for each cluster breakdown
% Other functions used: numedges.m
% Originally: June 6, 2007, GB, last modified May 4, 2011


function [groups_hist,Q]=newman_comm_fast(adj)


groups={};
groups_hist={};
Q=[];
n=size(adj,1); % number of vertices
groups_hist{1}={};

for i=1:n
  groups{i}=i; % each node starts out as one community
  groups_hist{1}{i}=i;
end

Q(1) = Qfn(groups,adj);

for s=1:n-1 % all possible iterations
  
  % print all groups
  %fprintf('modules at iteration: %4i\n',s);
  %for ss=1:length(groups)
  %  fprintf('%3i',groups{ss})
  %  fprintf('\n')
  %end
  
  dQ=zeros(length(groups));

  for i=1:length(groups)
    for j=i+1:length(groups)
      group_i=groups{i};
      group_j=groups{j};
      
      dQ(i,j)=0; % default
      
      % check if connected
      connected=0;
      if sum(sum(adj([group_i group_j],[group_i group_j])))>sum(sum(adj(group_i,group_i)))+sum(sum(adj(group_j,group_j)))
	connected=1;
      end
      
      if connected & not(isempty(group_i)) & not(isempty(group_j))
	% join groups i and j?
	dQ(i,j)=deltaQ(groups,adj,i,j);
      end
      
    end
  end
  
  
  % pick max nonzero dQ
  dQ(find(dQ==0))=-Inf;    
  [minv,minij]=max(dQ(:));
    
  [mini,minj]=ind2sub([size(dQ,1),size(dQ,1)],minij);   % i and j corresponding to min dQ
    groups{mini}=sort([groups{mini} groups{minj}]);
  groups{minj}=groups{length(groups)}; % swap minj with last group
  groups=groups(1:length(groups)-1);
  
  groups_hist{length(groups_hist)+1}=groups; % save current snapshot
  Q(length(Q)+1) = Qfn(groups,adj);
  
end % end of all iterations

num_modules=[];
for g=1:length(groups_hist)
  num_modules=[num_modules length(groups_hist{g})];
end

set(gcf,'Color',[1 1 1],'Colormap',jet);
plot(num_modules,Q,'ko-')
xlabel('number of modules / communities')
ylabel('modularity metric, Q')


function dQ=deltaQ(groups,adj,i,j)

% computing the delta Q between two community configurations
% dQ = 2(e_ij - ai*aj) or (Q_groups_(i,j)_merged - Q_original)
% inputs: current community assignments: groups, adjacency matrix, i,j to be joined
% outputs: delta Q value (real number)

% $$$ Q1=Qfn(groups,adj);
% $$$ groups{i}=[groups{i} groups{j}];
% $$$ groups{j}=groups{length(groups)};
% $$$ groups=groups(1:length(groups)-1);
% $$$ Q2=Qfn(groups,adj);
% $$$ dQ = Q2-Q1;

% alternative dQ = 2(e_ij - ai*aj) from paper;
nedges=numedges(adj); % compute the total number of edges
e_ii = numedges( adj(groups{i},groups{i}) ) / nedges;
e_jj = numedges( adj(groups{j},groups{j}) ) / nedges;
e_ij = numedges( adj([groups{i} groups{j}],[groups{i} groups{j}]) ) / nedges - e_ii - e_jj;

a_i=sum(sum(adj(groups{i},:)))/nedges-e_ii;
a_j=sum(sum(adj(groups{j},:)))/nedges-e_jj;

dQ = 2*(e_ij-a_i*a_j);



function Q=Qfn(modules,adj) % ======== same as modularity_metric.m ======

% computing the modularity for the final module break-down
% Defined as: Q=sum_over_modules_i (eii-ai^2) (eq 5) in Newman and Girvan.
% eij = fraction of edges that connect community i to community j
% ai=sum_j (eij)

nedges=numedges(adj); % compute the total number of edges

Q = 0;
for m=1:length(modules)  

  e_mm=numedges(adj(modules{m},modules{m}))/nedges;
  a_m=sum(sum(adj(modules{m},:)))/nedges - e_mm; % counting e_mm only once
  
  Q = Q + (e_mm - a_m^2);
end