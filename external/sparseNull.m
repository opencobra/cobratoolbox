function N = sparseNull(S, tol)
% sparseNull returns computes the sparse Null basis of a matrix
%
% N = sparseNull(S, tol)
% 
% Computes a basis of the null space for a sparse matrix.  For sparse
% matrixes this is much faster than using null.  It does however have lower
% numerical accuracy.  N is itself sparse and not orthonormal.  So in this
% way it is like using N = null(S, 'r'), except of course much faster.
%
% Jan Schellenberger 10/20/2009 
% based on this:
% http://www.mathworks.com/matlabcentral/fileexchange/11120-null-space-of-a-sparse-matrix
if nargin <2
    tol = 1e-9;
end
[SpLeft, SpRight] = spspaces(S,2, tol);
N = SpRight{1}(:,SpRight{3});
N(abs(N) < tol) = 0;


%%%%%%%%%%%%%% code from website.  I did not write this myself. -Jan
%%%%

function [SpLeft, SpRight] = spspaces(A,opt,tol)
%  PURPOSE: finds left and right null and range space of a sparse matrix A
%
% ---------------------------------------------------
%  USAGE: [SpLeft, SpRight] = spspaces(A,opt,tol)
%
%  INPUT: 
%       A                           a sparse matrix
%       opt                         spaces to calculate
%                                   = 1: left null and range space
%                                   = 2: right null and range space
%                                   = 3: both left and right spaces
%       tol                         uses the tolerance tol when calculating
%                                   null subspaces (optional)
%
%   OUTPUT:
%       SpLeft                      1x4 cell. SpLeft = {} if opt =2.
%           SpLeft{1}               an invertible matrix Q
%           SpLeft{2}               indices, I, of rows of the matrix Q that
%                                   span the left range of the matrix A
%           SpLeft{3}               indices, J, of rows of the matrix Q that
%                                   span the left null space of the matrix A
%                                   Q(J,:)A = 0
%           SpLeft{4}               inverse of the matrix Q
%       SpRight                     1x4 cell. SpRight = {} if opt =1.
%           SpLeft{1}               an invertible matrix Q
%           SpLeft{2}               indices, I, of rows of the matrix Q that
%                                   span the right range of the matrix A
%           SpLeft{3}               indices, J, of rows of the matrix Q that
%                                   span the right null space of the matrix A
%                                   AQ(:,J) = 0
%           SpLeft{4}               inverse of the matrix Q
%
%   COMMENTS:
%       uses luq routine, that finds matrices L, U, Q such that
%
%           A = L | U 0 | Q
%                 | 0 0 |
%       
%       where L, Q, U are invertible matrices, U is upper triangular. This
%       decomposition is calculated using lu decomposition.
%
%       This routine is fast, but can deliver inaccurate null and range
%       spaces if zero and nonzero singular values of the matrix A are not
%       well separated.
%
%   WARNING:
%       right null and rang space may be very inaccurate
%
% Copyright  (c) Pawel Kowal (2006)
% All rights reserved
% LREM_SOLVE toolbox is available free for noncommercial academic use only.
% pkowal3@sgh.waw.pl

if nargin<3
    tol                 = max(max(size(A)) * norm(A,1) * eps,100*eps);
end

switch opt
    case 1
        calc_left       = 1;
        calc_right      = 0;
    case 2
        calc_left       = 0;
        calc_right      = 1;
    case 3
        calc_left       = 1;
        calc_right      = 1;
end

[L,U,Q]                 = luq(A,0,tol);

if calc_left
    if ~isempty(L)
        LL              = L^-1;
    else
        LL              = L;
    end
    S                   = max(abs(U),[],2);
    I                   = find(S>tol);
    if ~isempty(S)
        J               = find(S<=tol);
    else
        J               = (1:size(S,1))';
    end    
    SpLeft              = {LL,I,J,L};
else
    SpLeft              = {};
end
if calc_right
    if ~isempty(Q)
        QQ              = Q^-1;
    else
        QQ              = Q;
    end    
    S                   = max(abs(U),[],1);
    I                   = find(S>tol);
    if ~isempty(S)
        J               = find(S<=tol);
    else
        J               = (1:size(S,2))';
    end
    SpRight             = {QQ,I,J,Q};
else
    SpRight             = {};
end


function [L,U,Q] = luq(A,do_pivot,tol)
%  PURPOSE: calculates the following decomposition
%             
%       A = L |Ubar  0 | Q
%             |0     0 |
%
%       where Ubar is a square invertible matrix
%       and matrices L, Q are invertible.
%
% ---------------------------------------------------
%  USAGE: [L,U,Q] = luq(A,do_pivot,tol)
%  INPUT: 
%         A             a sparse matrix
%         do_pivot      = 1 with column pivoting
%                       = 0 without column pivoting
%         tol           uses the tolerance tol in separating zero and
%                       nonzero values
%
%   OUTPUT:
%         L,U,Q          matrices
%
%   COMMENTS:
%         based on lu decomposition
%
% Copyright  (c) Pawel Kowal (2006)
% All rights reserved
% LREM_SOLVE toolbox is available free for noncommercial academic use only.
% pkowal3@sgh.waw.pl

[n,m]                   = size(A);

if ~issparse(A)
    A                   = sparse(A);
end

%--------------------------------------------------------------------------
%       SPECIAL CASES
%--------------------------------------------------------------------------
if size(A,1)==0
    L                   = speye(n);
    U                   = A;
    Q                   = speye(m);
    return;
end
if size(A,2)==0
    L                   = speye(n);
    U                   = A;    
    Q                   = speye(m);
    return;
end        

%--------------------------------------------------------------------------
%       LU DECOMPOSITION
%--------------------------------------------------------------------------
if do_pivot
    [L,U,P,Q]           = lu(A);   
    Q                   = Q';
else
    [L,U,P]             = lu(A);   
    Q                   = speye(m);
end
p                       = size(A,1)-size(L,2);
LL                      = [sparse(n-p,p);speye(p)];
L                       = [P'*L P(n-p+1:n,:)'];
U                       = [U;sparse(p,m)];

%--------------------------------------------------------------------------
%       FINDS ROWS WITH ZERO AND NONZERO ELEMENTS ON THE DIAGONAL
%--------------------------------------------------------------------------
if size(U,1)==1 || size(U,2)==1
    S                   = U(1,1);
else
    S                   = diag(U);
end
I                       = find(abs(S)>tol);
Jl                      = (1:n)';
Jl(I)                   = [];
Jq                      = (1:m)';
Jq(I)                   = [];

Ubar1                   = U(I,I);
Ubar2                   = U(Jl,Jq);
Qbar1                   = Q(I,:);
Lbar1                   = L(:,I);

%--------------------------------------------------------------------------
%       ELININATES NONZEZO ELEMENTS BELOW AND ON THE RIGHT OF THE
%       INVERTIBLE BLOCK OF THE MATRIX U
%
%       UPDATES MATRICES L, Q
%--------------------------------------------------------------------------
if ~isempty(I)
    Utmp                = U(I,Jq);
    X                   = Ubar1'\U(Jl,I)';
    Ubar2               = Ubar2-X'*Utmp;
    Lbar1               = Lbar1+L(:,Jl)*X';

    X                   = Ubar1\Utmp;
    Qbar1               = Qbar1+X*Q(Jq,:);    
    Utmp                = [];
    X                   = [];
end

%--------------------------------------------------------------------------
%       FINDS ROWS AND COLUMNS WITH ONLY ZERO ELEMENTS
%--------------------------------------------------------------------------
I2                      = find(max(abs(Ubar2),[],2)>tol);
I5                      = find(max(abs(Ubar2),[],1)>tol);

I3                      = Jl(I2);
I4                      = Jq(I5);
Jq(I5)                  = [];
Jl(I2)                  = [];
U                       = [];

%--------------------------------------------------------------------------
%       FINDS A PART OF THE MATRIX U WHICH IS NOT IN THE REQIRED FORM
%--------------------------------------------------------------------------
A                       = Ubar2(I2,I5);

%--------------------------------------------------------------------------
%       PERFORMS LUQ DECOMPOSITION OF THE MATRIX A
%--------------------------------------------------------------------------
[L1,U1,Q1]              = luq(A,do_pivot,tol);

%--------------------------------------------------------------------------
%       UPDATES MATRICES L, U, Q
%--------------------------------------------------------------------------
Lbar2                   = L(:,I3)*L1;
Qbar2                   = Q1*Q(I4,:);
L                       = [Lbar1 Lbar2 L(:,Jl)];
Q                       = [Qbar1; Qbar2; Q(Jq,:)];

n1                      = length(I);
n2                      = length(I3);
m2                      = length(I4);
U                       = [Ubar1 sparse(n1,m-n1);sparse(n2,n1) U1 sparse(n2,m-n1-m2);sparse(n-n1-n2,m)];