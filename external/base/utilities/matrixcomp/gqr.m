function [U, Q, L, S] = gqr(A, B, partial)
%GQR     Generalized QR factorization.
%        [U, Q, L, S] = GQR(A, B, partial) factorizes
%        the m-by-n A and p-by-n B, where m >= n >= p, as
%        A = U*L*Q^T, B = S*Q^T, with U and Q orthogonal
%        and L = [0; L1], S = [S1 0], with L1 and S1 lower triangular.
%        If a nonzero third argument is present then only a partial reduction
%        of A is performed: the first p columns of A are not reduced to
%        triangular form (which is sufficient for solving the LSE problem).

%        Reference:
%        N. J. Higham, Accuracy and Stability of Numerical Algorithms,
%        Second edition, Society for Industrial and Applied Mathematics,
%        Philadelphia, PA, 2002; sec. 20.9.

[m n]  = size(A);
[p n1] = size(B);
if nargin < 3, partial = 0; end

if n ~= n1, error('A and B must have same number of columns!'), end

if partial
   limit = p+1;
else
   limit = 1;
end

[Q, S] = qr(B');
S = S';

U = eye(m);
A = A*Q;

% QL factorization of AQ.

for i = n:-1:limit

    % Vector-reversal so that Householder eliminates leading
    % rather than trailing elements.
    temp = A(1:m-n+i,i); temp = temp(end:-1:1);
    [v, beta] = gallery('house',temp);
    v = v(end:-1:1);

    temp = A(1:m-n+i,1:i);
    A(1:m-n+i,1:i) = temp - beta*v*(v'*temp);

    % Put zeros where they're supposed to be!
    A(1:m-n+i-1,i) = zeros(m-n+i-1,1);

    temp = U(:,1:m-n+i);
    U(:,1:m-n+i) = temp - beta*temp*v*v';

end

L = A;
