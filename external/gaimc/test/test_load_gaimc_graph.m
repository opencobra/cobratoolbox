function load_test_gaimc_graph

%%
P1=load('../graphs/kt-7-2.mat');
P2=load_gaimc_graph('kt-7-2.mat');
if ~isequal(P1,P2)
    error('gaimc_graph failed on kt-7-2.mat');
else
    fprintf('gaimc_graph passed load test on kt-7-2.mat\n');
end

%%
P1=load('../graphs/kt-7-2');
P2=load_gaimc_graph('kt-7-2');
if ~isequal(P1,P2)
    error('gaimc_graph failed on kt-7-2');
else
    fprintf('gaimc_graph passed load test on kt-7-2\n');
end

%%
load('../graphs/clr-24-1');
P1 = struct('A',A,'labels',labels,'xy',xy);
load_gaimc_graph('clr-24-1');
P2 = struct('A',A,'labels',labels,'xy',xy);

if ~isequal(P1,P2)
    error('gaimc_graph failed on clr-24-1');
else
    fprintf('gaimc_graph passed load test on clr-24-1\n');
end