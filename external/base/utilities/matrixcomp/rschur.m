function A = rschur(n, mu, x, y)
%RSCHUR   An upper quasi-triangular matrix.
%         A = RSCHUR(N, MU, X, Y) is an N-by-N matrix in real Schur form.
%         All the diagonal blocks are 2-by-2 (except for the last one, if N
%         is odd) and the k'th has the form [x(k) y(k); -y(k) x(k)].
%         Thus the eigenvalues of A are x(k) +/- i*y(k).
%         MU (default 1) controls the departure from normality.
%         Defaults: X(k) = -k^2/10, Y(k) = -k, i.e., the eigenvalues
%                   lie on the parabola x = -y^2/10.

%         References:
%         F. Chatelin, Eigenvalues of Matrices, John Wiley, Chichester, 1993;
%            Section 4.2.7.
%         F. Chatelin and V. Fraysse, Qualitative computing: Elements
%            of a theory for finite precision computation, Lecture notes,
%            CERFACS, Toulouse, France and THOMSON-CSF, Orsay, France,
%            June 1993.

m = floor(n/2)+1;
alpha = 10; beta = 1;

if nargin < 4, y = -(1:m)/beta; end
if nargin < 3, x = -(1:m).^2/alpha; end
if nargin < 2, mu = 1; end

A = diag( mu*ones(n-1,1), 1 );
for i=1:2:2*(m-1)
    j = (i+1)/2;
    A(i:i+1,i:i+1) = [x(j) y(j); -y(j) x(j)];
end
if 2*m ~= n,
   A(n,n) = x(m);
end
