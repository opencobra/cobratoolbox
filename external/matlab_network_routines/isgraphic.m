% Check whether a sequence of number is graphical, i.e. a graph with this degree sequence exists
% INPUTs: a sequence (vector) of numbers
% OUTPUTs: boolean, true or false
% Note: not generalized to directed graph degree sequences
% Source: Erdős, P. and Gallai, T. "Graphs with Prescribed Degrees of Vertices" [Hungarian]. Mat. Lapok. 11, 264-274, 1960.

function B = isgraphic(seq)

if not(isempty(find(seq<=0))) | mod(sum(seq),2)==1
    % there are non-positive degrees or their sum is odd
    B = false; return;
end

n=length(seq);
seq=-sort(-seq);  % sort in decreasing order

for k=1:n-1
    sum_dk = sum(seq(1:k));
    sum_dk1 = sum(min([k*ones(1,n-k);seq(k+1:n)]));
    
    if sum_dk > k*(k-1) + sum_dk1; B = false; return; end

end

B = true;