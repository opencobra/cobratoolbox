function s=norm(a,P)
%norm: Matrix or vector norm of vector/matrix of mp-type

%     For matrices...
%       NORM(X) is the largest singular value of X, max(svd(X)).
%       NORM(X,2) is the same as NORM(X).
%       NORM(X,1) is the 1-norm of X, the largest column sum,
%                       = max(sum(abs(X))).
%       NORM(X,inf) is the infinity norm of X, the largest row sum,
%                       = max(sum(abs(X'))).
%       NORM(X,'fro') is the Frobenius norm, sqrt(sum(diag(X'*X))).
%       NORM(X,P) is available for matrix X only if P is 1, 2, inf or 'fro'.
%  
%     For vectors...
%       NORM(V,P) = sum(abs(V).^P)^(1/P).
%       NORM(V) = norm(V,2).
%       NORM(V,inf) = max(abs(V)).
%       NORM(V,-inf) = min(abs(V)).
%  
%     See also COND, RCOND, CONDEST, NORMEST.

if nargin<2,P=2;end
if isa(P,'mp')
 error(['Second parameter should not be of mp-type'])
end
if min(size(a))==1
 %is a vector
 if isinf(P) | strcmp(lower(P),'inf')
  if P>0
   s=max(abs(a));
  else
   s=min(abs(a));
  end
  return
 end
 A=max(abs(a(:)));a=a/A;
 if P==2
  %naive implementation
  s=A*sqrt(sum(a.*a));
 else
  s=A*(sum(a.^P))^(1/P);
 end
else
 %is a matrix
 if isinf(P) | strcmp(lower(P),'inf')
  s=max(sum(abs(a')));
  return
 end
 if ischar(P)
  if strcmp(lower(P),'fro')
   s=sqrt(sum(diag(a'*a)));
  else
   error(['Second parameter is not recognized as an option: ' P])
  end
  return
 end
 switch P
  case 1
   s=max(sum(abs(a)));
  case 2
   s=max(svd(a));
  otherwise
   error(['NORM(X,P) is available for matrix X only if P is 1, 2, inf or ' setstr(39) 'fro' setstr(39) '.'])
 end
end