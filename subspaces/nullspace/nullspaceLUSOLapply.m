function W = nullspaceLUSOLapply(nullS,V)

% First,
%        nullS = nullspaceLUSOLform(S);
% computes a structure nullS from an m x n sparse matrix S (m < n).
%
% Second, if V is an (n-m) x k sparse matrix (k >= 1),
%        W = nullspaceLUSOLapply(nullS,V);
% computes an n x k sparse matrix W from V such that S*W = 0.
%
% This is an operator form of finding an n x (n-m) matrix Z
% such that S*Z = 0 and then computing W = Z*V.
% The aim is to obtain W without forming Z explicitly.

% 16 May 2008: (MAS) First version of nullspaceLUSOLapply.m.
%              See nullspaceLUSOLtest.m for testing.

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
