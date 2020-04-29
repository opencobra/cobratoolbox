function x = lse(A, b, B, d, method)
%LSE     Solve the equality constrained least squares problem.
%        [x, flopcount] = LSE(A, b, B, d, METHOD) finds the least squares
%        solution of the system Ax = b subject to the constraint Bx = d.
%        METHOD = 1 (default), 2 or 3 specifies the variant of the null-space
%        method to be used.  METHOD 3 is the most efficient.

%        Note: Should really apply Householder transformations in factored form.
%        Not done here.
%
%        Reference:
%        A. J. Cox and N. J. Higham. Accuracy and stability of the null space
%           method for solving the equality constrained least squares problem.
%           BIT, 39(1):34-50, 1999.
%        N. J. Higham, Accuracy and Stability of Numerical Algorithms,
%           Second edition, Society for Industrial and Applied Mathematics,
%           Philadelphia, PA, 2002; sec. 20.9.

b = b(:); d = d(:);
[m n] = size(A);
m2 = length(b);
[p n2] = size(B);
p2 = length(d);

if m ~= m2 | p ~= p2 | n ~= n2
 error('Dimensions do not match!')
end

if nargin < 5, method = 1; end

partial = (method == 2 | method == 3);
[U, Q, L, S] = gqr(A, B, partial);
y1 = S(:,1:p)\d;

L21 = L(m-n+p+1:m,1:p);
L22 = L(m-n+p+1:m,p+1:n);

if method == 1

   c = U'*b;
   c3 = c(m-n+p+1:m);
   y2 = L22 \ (c3 - L21*y1);

elseif method == 2

   W1 = A*Q(:,1:p);
   g = U'*(b - W1*y1);
   g2 = g(m-n+p+1:m);
   y2 = L22\g2;

elseif method == 3

   W1y1 = A*(Q(:,1:p)*y1);
   g = U'*(b - W1y1);
   g2 = g(m-n+p+1:m);
   y2 = L22\g2;

end

y = [y1; y2];
x = Q*y;
