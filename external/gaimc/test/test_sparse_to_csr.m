function test_sparse_to_csr
%% Previous failure
[ai,aj,av]=find(ones(5));
sparse_to_csr(ai,aj,av);

%% 100 random trials
for t=1:100
    A = sprand(100,80,0.01);
    [rp ci ai]=sparse_to_csr(A);
    i=zeros(length(ai),1); j=i; a=i;
    n = length(rp)-1; nz=0;
    for cr=1:n
        for ri=rp(cr):rp(cr+1)-1
            nz=nz+1; i(nz)=cr; j(nz)=ci(ri); a(nz)=ai(ri);
        end
    end
    A2 = sparse(i,j,a,n,80);
    if ~isequal(A,A2)
        error('gaimc:sparse_to_csr','random sparse test failed');
    end
end

%% empty arguments
[rp ci ai] = sparse_to_csr([]);
