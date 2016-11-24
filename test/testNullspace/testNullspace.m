function testOK=testNullspace()
%tests the computation of the nullspace of a matrix using the LU solver termed
%LUSOL developed by Michael A. Saunders

%Ronan Fleming

%test lusol_mex with stoichiometric matrix from iAF120
if 0
    if ~exist('iAF1260.mat','file')
        warning('testNullspace could not complete because iAF1260.mat could not be found')
    else
        load iAF1260
    end
    A=model.S;
else
    if ~exist('modelLargeA.mat','file')
        warning('testNullspace could not complete because modelLargeA.mat could not be found')
    else
        load modelLargeA
    end
end

if 0
    nullA = nullSpaceOperator(A,1,0);        % gives a structure nullS.* that represents
    % Z in operator form.
    [m,n] = size(A);                      % gives the dimensions of S.
    rankA = nullA.rank;                   % is rank(S).
    v     = rand(n-rankA,1);              % is a random vector with the no. of cols of Z.
    w     = nullSpaceOperatorApply(nullA,v); % is in the nullspace of S.
    Z     = nullspaceLUSOLtest(A,0);        % computes all cols of Z explicitly (as a quick test).
    % Then w2 = Z*v should be the same as w.
else
    [Z,rankS]=getNullSpace(A,0);
end

% Check if A*Z = 0.
AZ    = A*Z;
normAZ= norm(AZ,inf);

tol = 1e-9;
if normAZ<tol
    testOK=1;
else
    fprintf('%s%8.1e%s%8.1e\n','testNullspace failed: norm(S*Z,inf) =', normAZ, ', while tolerance is = ',tol)
    testOK=0;
end


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
nullS = nullSpaceOperator(S,gmscale,printLevel);        % forms a structure nullS.
rankS = nullS.rank;
V     = speye(n-rankS,n-rankS);       % is a sparse I of order n-rankS.
Z     = nullSpaceOperatorApply(nullS,V); % satisfies S*Z = 0.

% Check if S*Z = 0.
SZ    = S*Z;
normSZ= norm(SZ,inf);

if printLevel
    whos S Z SZ
    fprintf('norm(S*Z,inf) = %8.1e\n', normSZ)
end


