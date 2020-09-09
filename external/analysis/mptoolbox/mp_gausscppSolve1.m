function [A,b,P]=gausscppSolve1(A,b)
%function [A,b,P]=gausscppSolve1(A,b)
%forward gaussian elimination with partial pivoting

[m n]=size(A);
if (m~=n), error('matrix must be square!'); end
%initialize pivoting vector
P = (1:m)';
for i=1:(n-1) %sweep through rows
   %maximum of i-th column below diagonal
   [mx imx]= max(abs(A(i:m,i))); 
   %row f and column c where |afc| is maximum for the submatrix A(i:m,i)
   f = imx + i - 1;
   c = i;
   %exchange i-th and f-th row for all the system
   dummy = A(i,:);
   A(i,:) = A(f,:);
   A(f,:) = dummy;
   dummy = b(i,:);
   b(i,:) = b(f,:);
   b(f,:) = dummy;
   dummy = P(i);
   P(i) = P(f);
   P(f) = dummy;
   ip1=i+1;
   for j=ip1:m %sweep the remaining rows
     mij=A(j,i)/A(i,i);
     %A(j,:)=A(j,:) - mij* A(i,:);
     A(j,ip1:n)=A(j,ip1:n) - mij* A(i,ip1:n);
     b(j,:)=b(j,:) - mij*b(i,:);
     %keep the pivot for further LU uses
     A(j,i)=mij;
   end
end
