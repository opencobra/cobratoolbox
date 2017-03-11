%% bfs
load_gaimc_graph('bfs_example.mat') % use the dfs example from Boost
d = bfs(A,1)

%% bipartite_matching
A = rand(10,8); % bipartite matching between random data
[val mi mj] = bipartite_matching(A);
val

%% clustercoeffs
load_gaimc_graph('clique-10');
cc = clustercoeffs(A) % they are all equal! as we expect in a clique


%% dfs
load_gaimc_graph('dfs_example.mat') % use the dfs example from Boost
d = dfs(A,1)

%% dijkstra
% Find the minimum travel time between Los Angeles (LAX) and
% Rochester Minnesota (RST).
load_gaimc_graph('airports')
A = -A; % fix funny encoding of airport data
lax=247; rst=355;
[d pred] = dijkstra(A,lax);
fprintf('Minimum time: %g\n',d(rst));
% Print the path
fprintf('Path:\n');
path =[]; u = rst; while (u ~= lax) path=[u path]; u=pred(u); end
fprintf('%s',labels{lax}); 
for i=path; fprintf(' --> %s', labels{i}); end, fprintf('\n');

%% dirclustercoeffs
load_gaimc_graph('celegans'); % load the C elegans nervous system network
cc=dirclustercoeffs(A);
[maxval maxind]=max(cc)
labels(maxind) % most clustered vertex in the nervous system

%% graph_draw
load_gaimc_graph('dfs_example');
graph_draw(A,xy);


%% mst_prim
load_gaimc_graph('airports'); % A(i,j) = negative travel time
A = -A; % convert to travel time.
A = max(A,A'); % make the travel times symmetric
T = mst_prim(A);
gplot(T,xy); % look at the minimum travel time tree in the US
 
%% scomponents
% scomponents
load_gaimc_graph('cores_example'); % the graph A has three components
ci = scomponents(A)
ncomp = max(ci)               % should be 3
R = sparse(1:size(A,1),ci,1,size(A,1),ncomp); % create a restriction matrix
CG = R'*A*R;                  % create the graph with each component 
                              % collapsed into a single node.

%% load_gaimc_graph                             
% equivalent to load('graphs/airports.mat') run from the gaimc directory
load_gaimc_graph('airports') 
% equivalent to P=load('graphs/kt-7-2.mat') run from the gaimc directory
P=load_gaimc_graph('kt-7-2.mat') 
% so you don't have to put the path in for examples!


%% largest_component
load_gaimc_graph('dfs_example')
[Acc p] = largest_component(A); % compute the largest component
xy2 = xy(p,:); labels2 = labels(p); % get component metadata
% draw original graph
subplot(1,2,1); graph_draw(A,xy,'labels',labels); title('Original');
% draw component
subplot(1,2,2); graph_draw(Acc,xy2,'labels',labels2); title('Component');

%% corenums
load_gaimc_graph('cores_example'); % the graph A has three components
corenums(A)

%% sparse_to_csr
A=sparse(6,6); A(1,1)=5; A(1,5)=2; A(2,3)=-1; A(4,1)=1; A(5,6)=1; 
[rp ci ai]=sparse_to_csr(A);

%% csr_to_sparse
A=sparse(6,6); A(1,1)=5; A(1,5)=2; A(2,3)=-1; A(4,1)=1; A(5,6)=1; 
[rp ci ai]=sparse_to_csr(A); 
A2 = csr_to_sparse(rp,ci,ai);
