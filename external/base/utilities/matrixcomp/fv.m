function [f, e] = fv(B, nk, thmax, noplot)
%FV     Field of values (or numerical range).
%       FV(A, NK, THMAX) evaluates and plots the field of values of the
%       NK largest leading principal submatrices of A, using THMAX
%       equally spaced angles in the complex plane.
%       The defaults are NK = 1 and THMAX = 16.
%       (For a `publication quality' picture, set THMAX higher, say 32.)
%       The eigenvalues of A are displayed as `x'.
%       Alternative usage: [F, E] = FV(A, NK, THMAX, 1) suppresses the
%       plot and returns the field of values plot data in F, with A's
%       eigenvalues in E.   Note that NORM(F,INF) approximates the
%       numerical radius,
%                 max {abs(z): z is in the field of values of A}.

%       Theory:
%       Field of values FV(A) = set of all Rayleigh quotients. FV(A) is a
%       convex set containing the eigenvalues of A.  When A is normal FV(A) is
%       the convex hull of the eigenvalues of A (but not vice versa).
%               z = x'Ax/(x'x),  z' = x'A'x/(x'x)
%               => REAL(z) = x'Hx/(x'x),   H = (A+A')/2
%       so      MIN(EIG(H)) <= REAL(z) <= MAX(EIG(H)),
%       with equality for x = corresponding eigenvectors of H.  For these x,
%       RQ(A,x) is on the boundary of FV(A).
%
%       Based on an original routine by A. Ruhe.
%
%       References:
%       R. A. Horn and C. R. Johnson, Topics in Matrix Analysis, Cambridge
%            University Press, 1991; sec. 1.5.
%       A. S. Householder, The Theory of Matrices in Numerical Analysis,
%            Blaisdell, New York, 1964; sec. 3.3.
%       C. R. Johnson, Numerical determination of the field of values of a
%            general complex matrix, SIAM J. Numer. Anal., 15 (1978),
%            pp. 595-602.

if nargin < 2 | isempty(nk), nk = 1; end
if nargin < 3 | isempty(thmax), thmax = 16; end
thmax = thmax - 1;  % Because code below uses thmax + 1 angles.

iu = sqrt(-1);
[n, p] = size(B);
if n ~= p, error('Matrix must be square.'), end
f = [];
z = zeros(2*thmax+1,1);
e = eig(B);

% Filter out cases where B is Hermitian or skew-Hermitian, for efficiency.
if isequal(B,B')

   f = [min(e) max(e)];

elseif isequal(B,-B')

   e = imag(e);
   f = [min(e) max(e)];
   e = iu*e; f = iu*f;

else

for m = 1:nk

   ns = n+1-m;
   A = B(1:ns, 1:ns);

   for i = 0:thmax
      th = i/thmax*pi;
      Ath = exp(iu*th)*A;               % Rotate A through angle th.
      H = 0.5*(Ath + Ath');             % Hermitian part of rotated A.
      [X, D] = eig(H);
      [lmbh, k] = sort(real(diag(D)));
      z(1+i) = rq(A,X(:,k(1)));         % RQ's of A corr. to eigenvalues of H
      z(1+i+thmax) = rq(A,X(:,k(ns)));  % with smallest/largest real part.
   end

   f = [f; z];

end
% Next line ensures boundary is `joined up' (needed for orthogonal matrices).
f = [f; f(1,:)];

end
if thmax == 0; f = e; end

if nargin < 4

   ax = cpltaxes(f);
   plot(real(f), imag(f))      % Plot the field of values
   axis(ax);
   axis('square');

   hold on
   plot(real(e), imag(e), 'x')    % Plot the eigenvalues too.
   hold off

end

function z = rq(A,x)
%RQ      Rayleigh quotient.
%        RQ(A,x) is the Rayleigh quotient of A and x, x'*A*x/(x'*x).

z = x'*A*x/(x'*x);
