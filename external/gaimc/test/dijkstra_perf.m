%% Dijkstra's algorithm
% To evaluate the performance of Dijkstra's algorithm, we pick 
graphdir = '../graphs/';
graphs = {'cs-stanford', 'tapir'};
profile off;
if exist('prof','var') && prof, profile on; end
nrep=15; ntests=10; mex_fast=0; mat_fast=0; mex_std=0; mat_std=0;
for rep=1:nrep
    for gi=1:length(graphs)
        load([graphdir graphs{gi} '.mat']); n=size(A,1);
        At=A'; [rp ci ai]=sparse_to_csr(A); As.rp=rp; As.ci=ci; As.ai=ai;
        for ti=1:ntests
            fprintf([repmat('\b',1,66) '%20s rep=%3i graph=%-20s trial=%4i'], ...
                'dijkstra',rep,graphs{gi},ti);
            v=ceil(n*rand(1));
            tic; d2=dijkstra_sp(At,v,struct('istrans',1,'nocheck',1)); 
              mex_fast=mex_fast+toc;
            tic; d4=dijkstra2(As,v); mat_fast=mat_fast+toc;
            if any(d2 ~= d4) 
                error('gaimc:dijkstra','incorrect results from dijkstra');
            end
        end
    end
end
fprintf('\n');
fprintf('mex time: %f\n', mex_fast);
fprintf('mat time: %f\n', mat_fast);
fprintf('\n');
if exist('prof','var') && prof, profile report; end
profile off;


    
