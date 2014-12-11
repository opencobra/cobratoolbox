function [rankA,p,q] = getRankLUSOL(A)
%Get the rank of a matrix using treshold rook pivoting
%
% uses lusolFactor computes the sparse factorization A = L*U
% for a square or rectangular matrix A.  The vectors p, q
% are row and column permutations giving the pivot order.
%
% Requires a 64 bit implementation of lusol, available from
% https://github.com/nwh/lusol_mex
%
%INPUT
% A     m x n rectangular matrix
%
%OUTPUT
% rankA     rank of A
% p         row permutations giving the pivot order
%           Note: p(1:rankA) gives indices of independent rows
%                 p(rankA+1:size(A,1)) gives indices of dependent rows
% q         column permutations giving the pivot order
%           Note: q(1:rankA) gives indices of independent columns
%                 q(rankA+1:size(A,2)) gives indices of dependent columns

% Ronan Fleming, August 2012

if 0
    %modification of default options
    options = lusolSet;
    options.PrintLevel=0;
    options.Pivoting  = 'TRP';
    options.FactorTol = 10;
    options.nzinit = 1e7;
    
    % lusolFactor computes the sparse factorization A = L*U
    % for a square or rectangular matrix A.  The vectors p, q
    % are row and column permutations giving the pivot order.
    %    L(p,p) is unit lower triangular with subdiagonals bounded
    %           by options.FactorTol,
    %    U(p,q) is upper triangular or upper trapezoidal,
    %           depending on the shape and rank of A.
    %    A(p,q) = L(p,p)*U(p,q) would be a truly triangular
    %             (or trapezoidal) factorization.
    %    The rank of A tends to be reflected in the rank of U,
    %    especially if options.Pivoting = 'TRP' or 'TCP'.
    [L,U,p,q,options] = lusolFactor(A,options);
else
    %use default options
    options.PrintLevel=0;
    [L,U,p,q,options] = lusolFactor(A,options);
end

rankA=options.Rank;
end

