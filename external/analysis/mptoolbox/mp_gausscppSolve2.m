function x = gausscppSolve2(U,y)
%function x = gausscppSolve2(U,y)
%Solves the upper triangular system U*x=y by backward substitution

[bas,n]=size(U);
x=repmat(U(1)*0,n,size(y,2));%trick to inherit the class from the U input
x(n,:)=y(n,:)/U(n,n);
for k=n-1:-1:1
  x(k,:)=(y(k,:) - U(k,(k+1):n)*x((k+1):n,:))/U(k,k);
end