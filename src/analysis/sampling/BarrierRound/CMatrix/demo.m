%install;

load('..\mat\LPnetlib\lp_agg.mat')

A = Problem.A;
p = colamd(A');
A = A(p,:);
w = (0.5+rand(size(A,2),1)).^5;
R = chol((A*(w.*A')));
x = rand(size(A,1),1);
z = R\(R'\x);
d = full(diag(R));
w = diag(sparse(w));

o = AdaptiveChol(A, 1e-8);
acc = o.factorize(w)
z2 = o.solve(ddouble(x), ddouble(w));
z3 = o.solve(ddouble(x), ddouble(w), 2);
z4 = o.solve(ddouble(x), ddouble(w), 3);
z5 = o.solve(ddouble(x), ddouble(w), 4);
d2 = o.diagonal();

norm(z2-z)
norm(z2-z3)
norm(z3-z4)
norm(z4-z5)

%norm(d2-d)
ls = o.leverageScore(100);
max(ls)