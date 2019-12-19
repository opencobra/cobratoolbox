function [U, R, V] = cod(A, tol)
%COD    Complete orthogonal decomposition.
%       [U, R, V] = COD(A, TOL) computes a decomposition A = U*T*V,
%       where U and V are unitary, T = [R 0; 0 0] has the same dimensions as
%       A, and R is upper triangular and nonsingular of dimension rank(A).
%       Rank decisions are made using TOL, which defaults to approximately
%       LENGTH(A)*NORM(A)*EPS.
%       By itself, COD(A, TOL) returns R.

%       Reference:
%       G. H. Golub and C. F. Van Loan, Matrix Computations, third
%       edition, Johns Hopkins University Press, Baltimore, Maryland,
%       1996; sec. 5.4.2.

[m, n] = size(A);

% QR decomposition.
[U, R, P] = qr(A);    % AP = UR
V = P';               % A = URV;
if nargin == 1, tol = max(m,n)*eps*abs(R(1,1)); end  % |R(1,1)| approx NORM(A).

% Determine r = effective rank.
r = sum(abs(diag(R)) > tol);
r = r(1);             % Fix for case where R is vector.
R = R(1:r,:);         % Throw away negligible rows (incl. all zero rows, m>n).

if r ~= n

   % Reduce nxr R' =  r  [L]  to lower triangular form: QR' = [Lbar].
   %                 n-r [M]                                  [0]

   [Q, R] = trap2tri(R');
   V = Q*V;
   R = R';

end

if nargout <= 1, U = R; end
