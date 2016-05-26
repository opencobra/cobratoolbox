function test_bipartite_matching
%% Info
% David F. Gleich
% Copyright, Stanford University, 2008-2009

% 2009-05-15: Initial version

%% empty input
val = bipartite_matching([]);

%% exact answer
A = [5 1 1 1 1;
     1 5 1 1 1;
     1 1 5 1 1;
     1 1 1 5 1;
     1 1 1 1 5;
     1 1 1 1 1];
[val m1 m2] = bipartite_matching(A);
if val ~= 25 || any(m1 ~= m2)
    error('gaimc:test_bipartite_matching','failed on known answer');
end

%% test triple input/output
A = ones(6,5); A = A-spdiags(diag(A),0,size(A,1),size(A,2));
[ai aj av] = find(A);
ai = [(1:5)';ai];
aj = [(1:5)';aj];
av = [5*ones(5,1);av];
[val m1 m2 mi] = bipartite_matching(av,ai,aj);
mitrue = zeros(length(av),1); mitrue(1:5)=1;
if val ~= 25 || any(m1 ~= m2) || sum(mi) ~= 5 || any(mi~=mitrue)
    error('gaimc:test_bipartite_matching','failed on known answer');
end

%% 100 random trials against dmperm
for t=1:100
    A = sprand(500,400,5/500); % 5 nz per row
    A = spones(A);
    p = dmperm(A);
    val = bipartite_matching(A);
    if sum(p>0)~=val
        error('gaimc:test_bipartite_matching','failed unweighted dmperm test');
    end
end
        
