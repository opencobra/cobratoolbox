function [est, x, k] = pnorm(A, p, tol, prnt)
%PNORM   Estimate of matrix p-norm (1 <= p <= inf).
%        [EST, x, k] = PNORM(A, p, TOL) estimates the Holder p-norm of a
%        matrix A, using the p-norm power method with a specially
%        chosen starting vector.
%        TOL is a relative convergence tolerance (default 1E-4).
%        Returned are the norm estimate EST (which is a lower bound for the
%        exact p-norm), the corresponding approximate maximizing vector x,
%        and the number of power method iterations k.
%        A nonzero fourth input argument causes trace output to the screen.
%        If A is a vector, this routine simply returns NORM(A, p).
%
%        See also NORM, NORMEST, NORMEST1.

%        Note: The estimate is exact for p = 1, but is not always exact for
%        p = 2 or p = inf.  Code could be added to treat p = 2 and p = inf
%        separately.
%
%        Calls DUAL.
%
%        Reference:
%        N. J. Higham, Estimating the matrix p-norm, Numer. Math.,
%             62 (1992), pp. 539-555.
%        N. J. Higham, Accuracy and Stability of Numerical Algorithms,
%           Second edition, Society for Industrial and Applied Mathematics,
%           Philadelphia, PA, 2002; sec. 15.2.

if nargin < 2, error('Must specify norm via second parameter.'), end
[m,n] = size(A);
if min(m,n) == 1, est = norm(A,p); return, end

if nargin < 4, prnt = 0; end
if nargin < 3 | isempty(tol), tol = 1e-4; end

% Stage I.  Use Algorithm OSE to get starting vector x for power method.
% Form y = B*x, at each stage choosing x(k) = c and scaling previous
% x(k+1:n) by s, where norm([c s],p)=1.

sm = 9;  % Number of samples.
y = zeros(m,1); x = zeros(n,1);

for k=1:n

    if k == 1
       c = 1; s = 0;
    else
       W = [A(:,k) y];

       if p == 2   % Special case.  Solve exactly for 2-norm.
          [U,S,V] = svd(full(W));
          c = V(1,1); s = V(2,1);

       else

          fopt = 0;
          for th=linspace(0,pi,sm)
              c1 = cos(th); s1 = sin(th);
              nrm = norm([c1 s1],p);
              c1 = c1/nrm; s1 = s1/nrm;   % [c1 s1] has unit p-norm.
              f = norm( W*[c1 s1]', p );
              if f > fopt
                 fopt = f;
                 c = c1; s = s1;
              end
          end

       end
    end

    x(k) = c;
    y = x(k)*A(:,k) + s*y;
    if k > 1, x(1:k-1) = s*x(1:k-1); end

end

est = norm(y,p);
if prnt, fprintf('Alg OSE: %9.4e\n', est), end

% Stage II.  Apply Algorithm PM (the power method).

q = dual(p);
k = 1;

while 1

    y = A*x;
    est_old = est;
    est = norm(y,p);

    z = A' * dual(y,p);

    if prnt
        fprintf('%2.0f: norm(y) = %9.4e,  norm(z) = %9.4e', ...
                 k, norm(y,p), norm(z,q))
        fprintf('  rel_incr(est) = %9.4e\n', (est-est_old)/est)
    end

    if ( norm(z,q) <= z'*x | abs(est-est_old)/est <= tol ) & k > 1
       return
    end

    x = dual(z,q);
    k = k + 1;

end
