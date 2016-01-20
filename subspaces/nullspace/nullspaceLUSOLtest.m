function [Z,nullS,rankS] = nullspaceLUSOLtest(S,printLevel)
%[Z,nullS,rankS] = nullspaceLUSOLtest(S,printLevel)
% tests computation of an operator form of the nullspace
% of the m x n sparse matrix S of rank r (r <= m < n).
% It uses nullS = nullspaceLUSOLform(S) to form the operator,
% and then    Z = nullspaceLUSOLapply(V)

% 16 May 2008: (MAS) First version of nullspaceLUSOLtest.m.
%    addpath ~/SOLVERS/lusol/matlab     makes LUSOL accessible
%    load iCore_stoich_mu_Stanford.mat  loads a stoichiometric matrix A.
%    Z = nullspaceLUSOLtest(S);         computes the nullspace explicitly.
 
if ~exist('printLevel','var')
    printLevel=1;
end

[m,n] = size(S);
gmscale=1;%by default, use geometric mean scaling of S
nullS = nullspaceLUSOLform(S,gmscale,printLevel);        % forms a structure nullS.
rankS = nullS.rank;
V     = speye(n-rankS,n-rankS);       % is a sparse I of order n-rankS.
Z     = nullspaceLUSOLapply(nullS,V); % satisfies S*Z = 0.

% Check if S*Z = 0.
SZ    = S*Z;
normSZ= norm(SZ,inf);

if printLevel
    whos S Z SZ
    fprintf('norm(S*Z,inf) = %8.1e\n', normSZ)
end
