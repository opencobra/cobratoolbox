% Neearest Symmetric, Positive Definite matrices
% 
% This tool saves your covariance matrices, turning them into something
% that really does have the property you will need. That is, when you are
% trying to use a covariance matrix in a tool like mvnrnd, it makes no
% sense if your matrix is not positive definite. So mvnrnd will fail in
% that case.
%
% But sometimes, it appears that users end up with matrices that are NOT
% symmetric and positive definite (commonly abbreviated as SPD) and they
% still wish to use them to generate random numbers, often in a tool like
% mvnrnd. A solution is to find the NEAREST matrix (based on minimizing the
% Frobenius norm of the difference) that has the desired property of being
% SPD.
% 
% I see the question come up every once in a while, so I looked in the file
% exchange to see what is in there. All I found was nearest_posdef. While
% this usually almost works, it could be better. It actually failed
% completely on most of my test cases, and it was not as fast as I would
% like, using an optimization. In fact, in the comments to nearest_posdef,
% a logical alternative was posed. That alternative too has its failures,
% so I wrote nearestSPD.

%% nearestSPD works on any matrix, and it is reasonably fast.
% As a test, randn generates a matrix that is not symmetric nor is it at
% all positive definite in general.
U = randn(100);

%%
% nearestSPD will be able to convert U into something that is indeed SPD,
% and for a 100 by 100 matrix, do it quickly enough
tic,Uj = nearestSPD(U);toc

%%
% The ultimate test of course, is to use chol. If chol returns a second
% argument that is zero, then MATLAB (and mvnrnd) will be happy!
[R,p] = chol(Uj);
p

%%
% As you can see, mvnrnd did not complain at all.
mvnrnd(zeros(1,100),Uj,1)

%%
% nearest_posdef would have failed here, as U was not even symmetric, nor
% does it even have positive diagonal entries.

%% A realistic test case
% Next I'll try a simpler test case. This one will have positive diamgonal
% entries, and it will indeed be symmetric. So this matrix is much closer
% to a true covariance matrix than that first mess we tried. And since
% nearest_posdef was quite slow on a 100x100 matrix, I'll use something
% smaller.
U = rand(25);
U = (U + U')/2;

%%
% Really, it is meaningless as a covariance matrix, because it is clearly
% not positive definite. We can see many negative eigenvalues, and chol
% gets upset. So mvnrnd would fail here.
eig(U)'
[R,p] = chol(U);
p

%%
% nearest_posdef took a bit of time, about 9 seconds on my machine.
% Admittedly, much of that time was wasted in doing fancy graphics that
% nobody actually needs if they just need a result.
tic,Um = nearest_posdef(U);toc

%%
% Is Um truly positive definite according to chol? Sadly, it is usually not.
[R,p] = chol(Um);
p

%%
% We can see how it failed, by looking at what eig returns.
eig(Um)
%%
% There will usually be some tiny negative eigenvalues
min(real(eig(Um)))
%%
% and sometimes even some imaginary eigenvalues. All usually tiny, but
% still enough to upset chol.
max(imag(eig(Um)))

%%
% The trick suggested by Shuo Han is pretty fast, but it too fails. Since
% U is already symmetric, we need not symmetrize it first, but chol still
% gets upset.
%
% Note that the slash used by Shuo was not a good idea. transpose would
% have been sufficient.
[V,D] = eig(U);
U_psd = V * max(D,0) / V;
[R,p] = chol(U_psd);
p

%%
% Whereas nearestSPD works nicely.
Uj = nearestSPD(U);
[R,p] = chol(Uj);

%%
% nearestSPD returns a solution that is a bit closer to the original
% matrix U too. Thus comparing 1,2,inf and Frobenius norms, nearestSPD was
% better under all norms in my tests, even though it is designed only to
% optimize the Frobenius norm.
[norm(U - Um,1), norm(U - Um,2), norm(U - Um,inf), norm(U - Um,'fro')]
[norm(U - Uj,1), norm(U - Uj,2), norm(U - Uj,inf), norm(U - Uj,'fro')]

