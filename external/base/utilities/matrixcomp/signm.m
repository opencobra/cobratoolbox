function [S, N] = signm(A)
%SIGNM   Matrix sign decomposition.
%        [S, N] = SIGNM(A) is the matrix sign decomposition A = S*N,
%        computed via the Schur decomposition.
%        S is the matrix sign function, sign(A).

%        Reference:
%        N. J. Higham, The matrix sign decomposition and its relation to the
%        polar decomposition, Linear Algebra and Appl., 212/213:3-20, 1994.

[Q, T] = schur(A,'complex');
S = Q * matsignt(T) * Q';

% Only problem with Schur method is possible nonzero imaginary part when
% A is real.  Next line takes care of that.
if ~any(imag(A)), S = real(S); end

if nargout == 2
   N = S*A;
end
