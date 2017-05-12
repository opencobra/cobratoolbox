function [U,S,V]= svd(A,dummy)

switch nargin
 case 1
  %[U,S,V]=svdsim(A);
  [U,S,V]=mp_mysvd(A);
 case 2
  %[U,S,V]=svdsim(A);
  [U,S,V]=mp_mysvd(A);
  [m,n]=size(A);
  if m>n
   U=U(:,1:n);S=S(1:n,1:n);
  end
end
switch nargout 
 case {0,1}
  U=diag(S);
 case 3
  %Standard case; do nothing!
 otherwise
  error('too many outputs for SVD')
end