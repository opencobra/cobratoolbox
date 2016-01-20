function nullS = nullspaceLUSOLform(S,gmscale,printLevel)

%        nullS = nullspaceLUSOLform(S);
% computes a structure nullS from which
%        W = nullspaceLUSOLapply(nullS,V);
% can compute W from matrix V such that S*W = 0.
%
% We assume S is m x n with m < n.
% nullS.rank returns the rank of S (rank <= m).
% It doesn't matter if rank < m.
%
% REQUIRED: lusolSet.m and lusolFactor.m (which calls the LUSOL mex-file).

% 02 May 2008: (MAS) First version of nullspaceLUSOLform.m.
%              load iCore_stoich_mu_Stanford.mat   % loads a matrix A;
%              nullS = nullspaceLUSOLform(A);      % forms Z.

%by default turn on scaling
if ~exist('gmscale','var')
    gmscale=1;
end
if ~exist('printLevel','var')
    printLevel=1;
end

[m,n] = size(S);
if printLevel
    fprintf('\nsize(S) = %10g x %10g', m,n);
end

% if m >= n
%   fprintf('\nS must have fewer rows than columns\n')
%   return
% end

if ~issparse(S)
    if printLevel
        disp('Converting dense S to sparse(S)')
    end
    S = sparse(S);
end

if printLevel
    fprintf('\n nnz(S) = %10g\n\n', nnz(S))
end

if gmscale
    %%%%%%% Scale S
    tic
    iprint  = 1;
    scltol  = 0.9;
    [cscale,rscale] = gmscal(S,sign(printLevel),scltol);
    
    C = spdiags(cscale,0,n,n);   Cinv = spdiags(1./cscale,0,n,n);
    R = spdiags(rscale,0,m,m);   Rinv = spdiags(1./rscale,0,m,m);
    A = Rinv*S*Cinv;
    
    if printLevel
        toc
    else
        t=toc;
    end
    
    %%%%%%% Factorize A = the scaled S
end
tic
options = lusolSet;
options.Pivoting  = 'TRP';
options.FactorTol = 1.5;
options.nzinit = 1e7;

[L,U,p,q,options] = lusolFactor(A',options);   % Note A'
rankS = options.Rank;
L     = L(p,p);      % New L is strictly lower triangular (and square).
% U     = U(p,q);      % New U would be upper trapezoidal the size of S'.

if printLevel
    toc
else
    t=toc;
end

% P*S'(:,q) = L*U means inv(L)*P*S'*Q = U, where Q is the perm from q
% and the bottom rows of U are zero: U(rank+1:n,:) = 0.
% This means (Q'*S*P')*inv(L') = U'   has its last columns = 0.
% Hence,         S*(P'*inv(L') = Q*U' has its last columns = 0.
% Q has no effect.
% Hence the null space of S is Z = the last cols of P'*inv(L'):
% When S is scaled as S = R*A*C, we have Z = Cinv*P'*inv(L')[0;I].

nullS.Cinv = Cinv;
nullS.L    = L;
nullS.p    = p;
nullS.q    = q;
nullS.rank = rankS;

if printLevel
    fprintf('\nnRows(S) = %10g', m)
    fprintf('\nnCols(S) = %10g', n)
    fprintf('\nrank(S) = %10g', rankS)
    fprintf('\nnnz(L)  = %10g', nnz(L))
    fprintf('\nnnz(U)  = %10g', nnz(U))
    fprintf('\nnull(S) is represented by L, permutation p, and column scaling Cinv\n\n')
end
return
