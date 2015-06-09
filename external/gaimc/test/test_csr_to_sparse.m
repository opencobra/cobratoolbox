function test_csr_to_sparse
%% empty arguments
A = csr_to_sparse(1,[],[]);
if ~isequal(A,sparse([]))
    error('gaimc:csr_to_sparse','failed to convert empty matrix');
end

A = csr_to_sparse(1,[],[],50);
if size(A,2)~=50
    error('gaimc:csr_to_sparse','incorrect empty size output');
end

%% exact test
% clique to sparse
rp = 1:5:26;
ci = reshape(repmat(1:5,5,1)',25,1);
ai = ones(25,1);
A=csr_to_sparse(rp,ci,ai);
if ~isequal(A,sparse(full(ones(5))))
    error('gaimc:csr_to_sparse','failed to convert clique');
end

%% 100 random trials of round trips between sparse_to_csr and csr_to_sparse
for t=1:100
    A = sprand(100,80,0.01);
    [rp ci ai]=sparse_to_csr(A);
    A2 = csr_to_sparse(rp,ci,ai,80);
    if ~isequal(A,A2)
        error('gaimc:csr_to_sparse','random sparse test failed');
    end
end


