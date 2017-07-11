function [U1, D1, V1, r] = subspaceSVD(S)
% Returns quantities satisfying :math:`S = U1 D1 V1^T`,
% where `U1` and `V1` have `r` orthonormal columns,
% and `D1` is `r x r` diagonal and has numerical rank `r`.
%
% The matrix `S` may be diagonal.
% Matrices `U1` and `V1` may be used by `projectSVD.m`
% to project given vectors onto certain subspaces.
%
% USAGE:
%
%    [U1, D1, V1, r] = subspaceSVD(S)
%
% INPUT:
%    S:             matrix
%
% OUTPUTS:
%    U1, D1, V1:    matrices
%    r:             numerical rank of `D1`
%
% .. Author: - Michael Saunders, 29 Jul 2009 First version of subspaceSVD.m
%            written as alternative to Ronan's subspaceProjector.m.

[U1,D1,V1] = svd(full(S),'econ');
d          = diag(D1);
dmax       = max(d);
tol        = 1e-12;
pos        = find(d > dmax*tol);   % pos = 1:r = indices of positive d
r          = length(pos);

U1         = U1( : ,1:r);
D1         = D1(1:r,1:r);
V1         = V1( : ,1:r);
