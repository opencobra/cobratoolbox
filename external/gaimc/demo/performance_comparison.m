%% Compare performance of gaimc to matlab_bgl
% While the |gaimc| library implements its graph routines in Matlab
% "m"-code, the |matlab_bgl| library uses graph algorithms from the Boost
% graph library in C++ through a mex interface.  Folklore has it that
% Matlab code with for loops like those required in the |gaimc| library is
% considerably slower.  This example examines this lore and shows that
% |gaimc| is typically within a factor of 2-4 of the mex code.  

%%
% *This demo is unlikely to work on your own computer.*
% *They depend on having the MatlabBGL routines in one spot.*

%% Setup the environment
% We need MatlabBGL on the path
graphdir = '../graphs/';
matlabbgldir = '~/dev/matlab-bgl/4.0';
try
    addpath(matlabbgldir); % change this to your matlab_bgl path
    ci=components(sparse(ones(5)));
catch
    error('gaimc:performance_comparison','Matlab BGL is not working, halting...');
end

%%
% Check to make sure we are in the correct directory
cwd = pwd; dirtail = ['gaimc' filesep 'demo']; 
if strcmp(cwd(end-length(dirtail)+1:end),dirtail) == 0
    error('%s should be executed from %s\n',mfilename,dirtail);
end

%%
% initalize the results structure
results=[];
mex_fast=0; mat_fast=0; mex_std=0; mat_std=0;

%% Depth first search
% To compare these functions, we have to make a copy and then delete it
copyfile(['..' filesep 'dfs.m'],'dfstest.m');
graphs = {'all_shortest_paths_example', 'clr-24-1', 'cs-stanford', ...
    'minnesota','tapir'};
nrep=30; ntests=100; 
fprintf(repmat(' ',1,76));
for rep=1:nrep
    % Matlab needs 1 iteration to compile the function
    if nrep==2, mex_fast=0; mat_fast=0; mex_std=0; mat_std=0; end
    for gi=1:length(graphs)
        load([graphdir graphs{gi} '.mat']); n=size(A,1);
        At=A'; [rp ci ai]=sparse_to_csr(A); As.rp=rp; As.ci=ci; As.ai=ai;
        for ti=1:ntests
            fprintf([repmat('\b',1,76) '%20s rep=%3i graph=%-30s trial=%4i'], ...
                'dfs',rep,graphs{gi},ti);
            v=ceil(n*rand(1));
            tic; d1=dfs(A,v); mex_std=mex_std+toc;
            tic; d2=dfs(At,v,struct('istrans',1,'nocheck',1)); 
              mex_fast=mex_fast+toc;
            tic; d3=dfstest(A,v); mat_std=mat_std+toc;
            tic; d4=dfstest(As,v); mat_fast=mat_fast+toc;
            if any(d1 ~= d2) || any(d2 ~= d3) || any(d3 ~= d4)
                error('gaimc:dfs','incorrect results from dijkstra');
            end
        end
    end
end
fprintf('\n');
delete('dfstest.m');
results(end+1).name='dfs';
results(end).mex_fast = mex_fast;
results(end).mat_fast = mat_fast;
results(end).mex_std = mex_std;
results(end).mat_std = mat_std;

%% Connected components
% To evaluate the performance of the connected components algorithm, we use
% sets of random graphs.
nrep=30; 
szs=[1 10 100 5000 10000 50000];
comp_results=[mex_fast mat_fast mex_std mat_std];
for szi=1:length(szs)
    fprintf('\n%20s size=%-5i     ', 'scomponents', szs(szi));
    % Matlab needs 1 iteration to compile the function
    if szi==2, mex_fast=0; mat_fast=0; mex_std=0; mat_std=0; end
    for rep=1:nrep
        fprintf('\b\b\b\b'); fprintf(' %3i', rep); 
        A=sprand(szs(szi),szs(szi),25/szs(szi));
        At=A'; [rp ci ai]=sparse_to_csr(A); As.rp=rp; As.ci=ci; As.ai=ai;
        tic; cc1=components(A); mex_std=mex_std+toc;
        tic; cc2=components(At,struct('istrans',1,'nocheck',1));
            mex_fast=mex_fast+toc;
        tic; cc3=scomponents(A); mat_std=mat_std+toc;
        tic; cc4=scomponents(As); mat_fast=mat_fast+toc;
        cs1=accumarray(cc1,1,[max(cc1) 1]);
        cs2=accumarray(cc2,1,[max(cc2) 1]);
        cs3=accumarray(cc3,1,[max(cc3) 1]);
        cs4=accumarray(cc4,1,[max(cc4) 1]);
        if any(cs1 ~= cs2) || any(cs2 ~= cs3) || any(cs2 ~= cs4)
            error('gaimc:scomponents','incorrect results from scomponents');
        end
    end
    comp_results(end+1,:) = [mex_fast mat_fast mex_std mat_std];
end
comp_results=diff(comp_results);
results(end+1).name='scomponents';
results(end).mex_fast = mex_fast;
results(end).mat_fast = mat_fast;
results(end).mex_std = mex_std;
results(end).mat_std = mat_std;

%%
% Plot the data for connected components
% This plot isn't too meaningful, so I've omitted it.

% plot(szs, comp_results,'.-'); 
% legend('mex fast','mat fast','mex std','mat std','Location','Northwest');
% ylabel('time'); xlabel('graph size');

%% Dijkstra's algorithm
% To evaluate the performance of Dijkstra's algorithm, we pick 
graphs = {'clr-25-2', 'clr-24-1', 'cs-stanford', ...
    'minnesota', 'tapir'};
nrep=30; ntests=100; mex_fast=0; mat_fast=0; mex_std=0; mat_std=0;
for rep=1:nrep
    for gi=1:length(graphs)
        load([graphdir graphs{gi} '.mat']); n=size(A,1);
        At=A'; [rp ci ai]=sparse_to_csr(A); As.rp=rp; As.ci=ci; As.ai=ai;
        for ti=1:ntests
            fprintf([repmat('\b',1,66) '%20s rep=%3i graph=%-20s trial=%4i'], ...
                'dijkstra',rep,graphs{gi},ti);
            v=ceil(n*rand(1));
            tic; d1=dijkstra_sp(A,v); mex_std=mex_std+toc;
            tic; d2=dijkstra_sp(At,v,struct('istrans',1,'nocheck',1)); 
              mex_fast=mex_fast+toc;
            tic; d3=dijkstra(A,v); mat_std=mat_std+toc;
            tic; d4=dijkstra(As,v); mat_fast=mat_fast+toc;
            if any(d1 ~= d2) || any(d2 ~= d3) || any(d3 ~= d4)
                error('gaimc:dijkstra','incorrect results from dijkstra');
            end
        end
    end
end
fprintf('\n');
results(end+1).name='dijkstra';
results(end).mex_fast = mex_fast;
results(end).mat_fast = mat_fast;
results(end).mex_std = mex_std;
results(end).mat_std = mat_std;

%% Directed Clustering coefficients
nrep=30; mex_fast=0; mat_fast=0; mex_std=0; mat_std=0;
comp_results=[mex_fast mat_fast mex_std mat_std];
szs=[1 10 100 5000 10000 50000];
for szi=1:length(szs)
    fprintf('\n%20s size=%-5i     ', 'dirclustercoeffs', szs(szi));
    % Matlab needs 1 iteration to compile the function
    if szi==2, mex_fast=0; mat_fast=0; mex_std=0; mat_std=0; end
    for rep=1:nrep
        fprintf('\b\b\b\b'); fprintf(' %3i', rep); 
        A=sprand(szs(szi),szs(szi),25/szs(szi));
        At=A'; 
        [rp ci ai]=sparse_to_csr(A); As.rp=rp; As.ci=ci; As.ai=ai;
        [cp ri ati]=sparse_to_csr(At); As.cp=cp; As.ri=ri; As.ati=ati;
        tic; cc1=clustering_coefficients(A); mex_std=mex_std+toc;
        tic; cc2=clustering_coefficients(At,struct('istrans',1,'nocheck',1));
            mex_fast=mex_fast+toc;
        tic; cc3=dirclustercoeffs(A); mat_std=mat_std+toc;
        tic; cc4=dirclustercoeffs(As); mat_fast=mat_fast+toc;
    end
    comp_results(end+1,:) = [mex_fast mat_fast mex_std mat_std];
end
fprintf('\n');
comp_results=diff(comp_results);
results(end+1).name='dirclustercoeffs';
results(end).mex_fast = mex_fast;
results(end).mat_fast = mat_fast;
results(end).mex_std = mex_std;
results(end).mat_std = mat_std;

%% Minimum spanning tree
nrep=30; mex_fast=0; mat_fast=0; mex_std=0; mat_std=0;
comp_results=[];
szs=[10 100 5000 10000];
for szi=1:length(szs)
    fprintf('\n%20s size=%-5i     ', 'mst_prim', szs(szi));
    % Matlab needs 1 iteration to compile the function
    if szi==2, mex_fast=0; mat_fast=0; mex_std=0; mat_std=0; end
    for rep=1:nrep
        fprintf('\b\b\b\b'); fprintf(' %3i', rep); 
        A=abs(sprandsym(szs(szi),25/szs(szi)));
        At=A'; 
        [rp ci ai]=sparse_to_csr(A); As.rp=rp; As.ci=ci; As.ai=ai;
        tic; T1=prim_mst(A); mex_std=mex_std+toc;
        tic; [t1i t1j t1v]=prim_mst(At,struct('istrans',1,'nocheck',1));
            mex_fast=mex_fast+toc;
        tic; T2=mst_prim(A,0); mat_std=mat_std+toc;
        tic; [t2i t2j t2v]=mst_prim(As,0); mat_fast=mat_fast+toc;
        T1f=sparse(t1i,t1j,t1v,size(A,1),size(A,2));
        T2f=sparse(t2i,t2j,t2v,size(A,1),size(A,2));
        if ~isequal(T1,T2) || ~isequal(T1f+T1f',T2f+T2f') || ...
                ~isequal(T1,T2f+T2f')
            keyboard
            warning('gaimc:mst_prim',...
                'incorrect results from mst_prim (%i,%i)', szi, rep);
        end     
    end
    comp_results(end+1,:) = [mex_fast mat_fast mex_std mat_std];
end
fprintf('\n');
comp_results=diff(comp_results);
results(end+1).name='mst_prim';
results(end).mex_fast = mex_fast;
results(end).mat_fast = mat_fast;
results(end).mex_std = mex_std;
results(end).mat_std = mat_std;

%% Undirected Clustering coefficients
nrep=30; mex_fast=0; mat_fast=0; mex_std=0; mat_std=0;
undircc_results=[mex_fast mat_fast mex_std mat_std];
szs=[1 10 100 5000 10000 50000];
for szi=1:length(szs)
    fprintf('\n%20s size=%-5i     ', 'clustercoeffs', szs(szi));
    % Matlab needs 1 iteration to compile the function
    if szi==2, mex_fast=0; mat_fast=0; mex_std=0; mat_std=0; end
    for rep=1:nrep
        fprintf('\b\b\b\b'); fprintf(' %3i', rep); 
        A=abs(sprandsym(szs(szi),25/szs(szi)));
        At=A'; 
        [rp ci ai]=sparse_to_csr(A); As.rp=rp; As.ci=ci; As.ai=ai;
        tic; cc1=clustering_coefficients(A,struct('undirected',1)); mex_std=mex_std+toc;
        tic; cc2=clustering_coefficients(At,struct('undirected',1,'istrans',1,'nocheck',1));
            mex_fast=mex_fast+toc;
        tic; cc3=clustercoeffs(A); mat_std=mat_std+toc;
        tic; cc4=clustercoeffs(As); mat_fast=mat_fast+toc;
    end
    undircc_results(end+1,:) = [mex_fast mat_fast mex_std mat_std];
end
%%
fprintf('\n');
undircc_results=diff(undircc_results);
results(end+1).name='clustercoeffs';
results(end).mex_fast = mex_fast;
results(end).mat_fast = mat_fast;
results(end).mex_std = mex_std;
results(end).mat_std = mat_std;

%% Summarize the results
% We are going to summarize the results in a bar plot based on the
% algorithm.  Each algorithm is a single bar
graphs = {'all_shortest_paths_example', 'clr-24-1', 'cs-stanford', ...
    'minnesota','tapir'};, where the performance of the
% mex code is 1.  
nresults=length(results);
Ystd = zeros(nresults,1);
Yfast = zeros(nresults,1);
for i=1:nresults
    Ystd(i)=results(i).mat_std/results(i).mex_std;
    Yfast(i)=results(i).mat_fast/results(i).mex_fast;
end
bar(1:nresults,[Ystd Yfast]); set(gca,'XTickLabel',{results.name});
legend('Standard','Fast','Location','Northwest');


    
