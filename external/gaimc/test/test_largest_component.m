function test_largest_component

fname = 'largest_component'; % function name
ntest = 0; % test number

ntest = ntest+1; tid = sprintf('%32s test %3i : ', fname, ntest);
load_gaimc_graph('dfs_example');
Acc = largest_component(A);
if size(Acc,1) ~= 5
    error('gaimc:test','%s failed on dfs_example', tid);
else
    fprintf([tid 'passed\n']);
end

ntest = ntest+1; tid = sprintf('%32s test %3i : ', fname, ntest);
load_gaimc_graph('dfs_example');
Acc = largest_component(A,1);
if size(Acc,1) ~= 6
    error('gaimc:test','%s failed on sym=1 dfs_example', tid);
else
    fprintf([tid 'passed\n']);
end

ntest = ntest+1; tid = sprintf('%32s test %3i : ', fname, ntest);
load_gaimc_graph('cores_example'); % the graph A is symmetric
Acc1 = largest_component(A);
Acc2 = largest_component(A,1);
if ~isequal(Acc1,Acc2)
    error('gaimc:test','%s failed on cores_example', tid);
else
    fprintf([tid 'passed\n']);
end
    