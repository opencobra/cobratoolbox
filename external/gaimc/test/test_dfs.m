function test_dfs

%% Line graph test
for n=10:10:100
    A=spdiags(ones(n,2),[-1 1],n,n);
    [d dt ft pred]=dfs(A,1);
    if any(d~=(0:n-1)') || ...
            any(dt~=(0:n-1)') || ...
            any(ft~=(2*n-1:-1:n)') || ...
            any(pred~=0:n-1)
        error('gaimc:dfs','line graph test error');
    end
end

%%  