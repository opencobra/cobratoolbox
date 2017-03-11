%% Compare performance of gaimc to matlab_bgl
% While the |gaimc| library implements its graph routines in Matlab
% "m"-code, the |matlab_bgl| library uses graph algorithms from the Boost
% graph library in C++ through a mex interface.  Folklore has it that
% Matlab code with for loops like those required in the |gaimc| library is
% considerably slower.  This example examines this lore and shows that
% |gaimc| is typically within a factor of 2-4 of the mex code for one
% function.  The full performance_comparison suite evaluates the rest, but
% it takes a while to run, so I only run it when I'm interested in a
% complete picture and can afford to run it overnight.

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


%% Summarize the results
% We are going to summarize the results in a bar plot based on the
% algorithm.  Each algorithm is a single bar where the performance of the
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

%%
% From this, we see that the connected component codes are about half the
% speed of the Matlab BGL functions and Dijkstra's is about 1/4th the
% speed.  This seems unideal, but the code is much more portable and
% flexible.
%
% The difference between the Standard and Fast results is that the fast
% results eliminate all data translation for both gaimc and MatlabBGL and
% are evaluating the actual algorithm implementation and not any of the
% data translation components.
    
