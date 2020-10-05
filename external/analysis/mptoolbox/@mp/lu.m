function varargout=lu(A)
%lu: finds [L,U,P]=lu(A) for a mp-type matrix A

%solve a mock system of equations with gauss elimination with partial pivoting, and
%extract the intermediate matrix after forward substitution
dummy=A(:,1);%mock column
[LU,b,shortP]=mp_gausscppSolve1(A,dummy);
switch nargout
 case {1,0}
  varargout(1)={LU};
 case 2
  L=tril(LU,-1)+eye(size(LU));U=triu(LU);
  varargout(1)={L};
  varargout(2)={U};
 case 3
  L=tril(LU,-1)+eye(size(LU));U=triu(LU);
  varargout(1)={L};
  varargout(2)={U};
  %build the permutation matrix as a full , double one
  P=eye(size(LU));P=P(shortP,:);
  varargout(3)={P};
 otherwise
  error('four outputs are unimplemented in lu.m for class mp')
end        