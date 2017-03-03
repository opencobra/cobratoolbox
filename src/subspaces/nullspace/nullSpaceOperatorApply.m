function W = nullSpaceOperatorApply(nullS,V)
% Computes a sparse matrix W from V such that S*W = 0.
% W = nullSpaceOperatorApply(nullS,V)
%
% First, nullS = nullSpaceOperator(S);
% computes a structure nullS from an m x n sparse matrix S (m < n), with rank r.
%
% Second, if V is an (n-r) x k sparse matrix (k >= 1),
%        W = nullSpaceOperatorApply(nullS,V);
% computes an n x k sparse matrix W from V such that S*W = 0.
%
% This is an operator form of finding an n x (n-r) matrix Z
% such that S*Z = 0 and then computing W = Z*V.
% The aim is to obtain W without forming Z explicitly.

% 16 May 2008: (MAS) First version of nullspaceLUSOLapply.m.
%              See nullspaceLUSOLtest.m for testing.
% 20 Jan 2015: Updated to use Nick Henderson's 64 bit LUSOL interface
%              Ronan Fleming

Cinv    = nullS.Cinv; % Column scales
L       = nullS.L;    % Strictly triangular L
p       = nullS.p;    % Column permutation for S
rankS   = nullS.rank; % rank(S)

[n ,n ] = size(L);
[mV,nV] = size(V);

B       = [sparse(rankS,nV)
           V        ];
Z       = (L')\B;
W       = Z;
W(p,:)  = Z;
W       = Cinv*W;
return
