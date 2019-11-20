function [U, H] = poldec(A)
%POLDEC   Polar decomposition.
%         [U, H] = POLDEC(A) computes a matrix U of the same dimension
%         (m-by-n) as A, and a Hermitian positive semi-definite matrix H,
%         such that A = U*H.
%         U has orthonormal columns if m >= n, and orthonormal rows if m <= n.
%         U and H are computed via an SVD of A.
%         U is a nearest unitary matrix to A in both the 2-norm and the
%         Frobenius norm.

%         Reference:
%         N. J. Higham, Computing the polar decomposition---with applications,
%         SIAM J. Sci. Stat. Comput., 7(4):1160--1174, 1986.
%
%         (The name `polar' is reserved for a graphics routine.)

[m, n] = size(A);

[P, S, Q] = svd(A, 0);  % Economy size.
if m < n                % Ditto for the m<n case.
   S = S(:, 1:m);
   Q = Q(:, 1:m);
end
U = P*Q';
if nargout == 2
   H = Q*S*Q';
   H = (H + H')/2;      % Force Hermitian by taking nearest Hermitian matrix.
end
