function [Q,R]=mp_myqr(A,flag)   
%QR	Computes QR decomposition of A. 
% 	It uses the Gram-Schmidt algorithm. 
%	The inner product is given by <x,y>=x^ty. 
% 	The command is [Q,R]=myqr(A,flag). 
%   If flag=0, the "economy size" answer is provided

%   based upon GRAM.M, Copyright 1993 Terry Lawson
%	Terry Lawson, Math Department, Tulane University, 11/93

%   Modified by CLV, 20061112
%       Nows deals correctly with rank deficient matrix A
%   Modified by CLV, 20041229
%       "flag" is added as a parameter, to specify the "economy size" decomposition or not

if (nargin < 2), flag = 1;end %request full size decomposition
[m,n]=size(A);
zero=A(1)*0; %a zero of the same data type as matrix A
switch class(A)
    case 'double'
        EPS=eps;
    otherwise
        EPS=eps(zero+1);
end
tol = max([m,n])*EPS*norm(A,'inf'); 
v=A;w=A;
%R=zeros(zero,m,n);
R=zero*zeros(m,n);
k=1;
w(:,1)=v(:,1);
R(1,1)=sqrt(w(:,1)'*w(:,1));
Q(:,1)=w(:,1)/R(1,1);nn(1)=R(1,1);
for j= 2:n  
    wtemp = v(:,j);
    for i= 1:k
        t(i,j)=v(:,j)'*w(:,i)/(w(:,i)'*w(:,i));
        wtemp = wtemp-t(i,j)*w(:,i);
        R(i,j)=t(i,j)*nn(i);
    end                  
    if sqrt(wtemp'*wtemp) > tol
        k=k+1;
        w(:,k)=wtemp;
        nn(k)=sqrt(wtemp'*wtemp);
        R(k,j)=nn(k);
        Q(:,k)=w(:,k)/nn(k);
    else
        k=k+1;
        [Q,nn,w,k]=fill_with_something(Q,nn,w,m,n,k,tol,zero);
        nn(k)=0;
    end
end
%exit if flag is explicitly set to zero
if flag==0;
    R=R(1:k,:);
    return
end

%if m>n, we should invent something for the rest of the columns
k=n+1;
while k<=m
    [Q,nn,w,k]=fill_with_something(Q,nn,w,m,n,k,tol,zero);
    k=k+1;
%     dummy=rand(m,1)+zero;
%     for i=1:(k-1)
%         rik=Q(:,i)'*dummy;
%         dummy=dummy-rik*Q(:,i);
%     end
%     qk=dummy;
%     rkk=sqrt(qk'*qk);
%     if rkk<tol
%         %you are really unlucky! the random vector is collinear with all the previous
%         %ones. But, do not worry! We can save your life doing nothing!
%     else
%         Q(:,k)=qk/rkk;
%         k=k+1;
%     end
end
R(m,n)=0;
return



function [Q,nn,w,k]=fill_with_something(Q,nn,w,m,n,k,tol,zero);
rkk=0;
while rkk<tol
    dummy=rand(m,1)+zero;
    for i=1:(k-1)
        rik=Q(:,i)'*dummy;
        dummy=dummy-rik*Q(:,i);
    end
    qk=dummy;
    rkk=sqrt(qk'*qk);
end
Q(:,k)=qk/rkk;
nn(k)=rkk;
w(:,k)=qk;
%k=k+1;
