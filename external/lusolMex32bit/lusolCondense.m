function [AA,bb,p,rankA] = lusolCondense(A,b,mode)
%
%        [AA,bb,p] = lusolCondense(A,b,mode);
% extracts from A a submatrix AA = A(p,:) of full row rank, and
% the corresponding subvector bb = b(p), where A should be sparse
% and have nonzero entries not too much bigger than 1.
%
%INPUT
% A     m x n sparse matrix
% b     m x 1 vector
%
%OPTIONAL INPUT
% mode
% If mode=1, LUSOL operates on A itself.
% If mode=2, LUSOL operates on A'.
%
%OUTPUT
% AA        row reduced A
% bb        row reduced B
% p         AA = A(p,:),bb = b(p)
% rankA     rank of A
%

% 27 May 2007: Michael Saunders: 
%              First version of lusolCondense, intended as a
%              more efficient substitute for [Q,R,P] = qr(full(A')).
%              Michael Saunders 
% 20 Jan 2011: Ronan Fleming
%              64bit linux support  

if ~exist('mode','var')
    mode=1; %what is the best default.
end

if ~issparse(A)
  A=sparse(A);
end


[m,n]   = size(A);
if isempty(b)
    b=sparse(m,1);
end

options = lusolSet;
options.Pivoting  = 'TRP';
options.FactorTol = 1.5;

if mode==1   % Factorize A itself
  [L,U,p,q,options] = lusolFactor(A,options);
  inform   = options.Inform;
  rankA    = options.Rank;

  if rankA==m
    fprintf('\nA has full row rank %g\n', m)
    AA = A;
    bb = b;
    p  = (1:m)';
  else
    fprintf('\nA has low row rank %g  (< %g)\n', rankA,m)
    AA = A(p(1:rankA),:);
    bb = b(p(1:rankA));
  end

else         % Factorize A'
  [L,U,p,q,options] = lusolFactor(A',options);
  inform  = options.Inform;
  rankA    = options.Rank;

  if rankA==m
    fprintf('\nA has full row rank %g\n', m)
    AA = A;
    bb = b;
    p  = (1:m)';
  else
    fprintf('\nA has low row rank %g  (< %g)\n', rankA,m)
    p  = q;
    AA = A(p,:);
    bb = b(p);
  end
end
