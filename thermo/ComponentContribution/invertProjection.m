% invert a general matrix A using the pseudoinverse
% return values are:
%     inv_A - the pseudoinverse of A
%     r     - the rank of A
%     P_R   - the projection matrix onto the range(A)
%     P_N   - the projection matrix onto the null(A')
function [inv_A, r, P_R, P_N] = invertProjection(A, epsilon)
if nargin < 2
    epsilon = 1e-10;
end

[m, n] = size(A);
%[U, S, V] = svd(A);
[U, S, V] = svds(A,min(size(A))); % Bugfix due to svd convergence problems
r = sum(sum(abs(S) > epsilon));
inv_S = diag(1 ./ S(abs(S) > epsilon));
inv_A = V(:, 1:r) * inv_S(1:r, 1:r) * U(:, 1:r)';
P_R = U(:, 1:r)       * U(:, 1:r)';
P_N = U(:, (r+1):end) * U(:, (r+1):end)';
