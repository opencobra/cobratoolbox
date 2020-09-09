function [U,S,V]=mp_mysvd(A,dummy)
%function [U,S,V]=mysvd(A,dummy)
%svd: singular value decomposition
%Outputs should verify that U*S*V'==A 
%The case with two arguments is considered as an "economy size" request

% Based upon FORTRAN 77 routine at NUMERICAL RECIPES, monkey-modified to run in Matlab
% also taking into consideration the C implementation (due to the GOTO hell!)
% Given a matrix A(1:m,1:n),with physical dimensions mp by np this routine computes its
% singular value decomposition,A = U * W * V' .The matrix U replaces A on output.The
% diagonal matrix of singular values W is output as a vector w(1:n). The matrix V (not the
% transpose V') is output as v(1:n,1:n).
% NOTICE that direct comparison with the matlab svd is possible only for the singular values, 
%        but for the left and right matrix you should be prepared to consider some possible
%        sign differences. The verification should be instead that norm(U*S*V'-A) is small, and
%        that norm(S-Smatlab) is also small
%
%source in FORTRAN 77 at http://cc.oulu.fi/~tf/tiedostot/pub/nrf/svdcmp.f
%source in C at http://www.cs.utah.edu/~tch/classes/cs4550/code/Numerical-Recipes/sources-used/svdcmp.c

[m,n]=size(A);
a_zero=A(1)*0;%a zero of the same data type as input matrix A
a_one=1+a_zero;%a one of the same data type as input matrix A
g=a_zero; 
scale=a_zero;
anorm=a_zero;
for i=1:n %do 25 i=1,n
 L=i+1;
 rv1(i)=scale*g;
 g=a_zero;
 s=a_zero;
 scale=a_zero;
 if(i<=m)
  for k=i:m %do 11 k=i,m
   scale=scale+abs(A(k,i));
  end %enddo 11
  if (scale~=0)
   for k=i:m%do 12 k=i,m
    A(k,i)=A(k,i)/scale;
    s=s+A(k,i)*A(k,i);
   end %enddo 12
   f=A(i,i);
   g=-signtransf(sqrt(s),f);
   h=f*g-s;
   A(i,i)=f-g;
   if i~=n
    for j=L:n %do 15 j=l,n
     s=a_zero;
     for k=i:m %do 13 k=i,m
      s=s+A(k,i)*A(k,j);
     end %enddo 13
     f=s/h;
     for k=i:m %do 14 k=i,m
      A(k,j)=A(k,j)+f*A(k,i);
     end %enddo 14   
    end %enddo 15
   end
   for  k=i:m %do 16 k=i,m
    A(k,i)=scale*A(k,i);
   end %enddo 16
  end
 end
 w(i)=scale *g;
 g=a_zero;
 s=a_zero;
 scale=a_zero;
 if((i<=m) & (i~=n))
  for k=L:n %do 17 k=l,n
   scale=scale+abs(A(i,k));
  end %enddo 17
  if(scale~=a_zero)
   for k=L:n %do 18 k=l,n
    A(i,k)=A(i,k)/scale;
    s=s+A(i,k)*A(i,k);
   end %enddo 18
   f=A(i,L);
   g=-signtransf(sqrt(s),f);
   h=f*g-s;
   A(i,L)=f-g;
   for k=L:n %do 19 k=l,n
    rv1(k)=A(i,k)/h;
   end %enddo 19
   for j=L:m %do 23 j=l,m
    s=a_zero;
    for k=L:n %do 21 k=l,n
     s=s+A(j,k)*A(i,k);
    end %enddo 21
    for k=L:n %do 22 k=l,n
     A(j,k)=A(j,k)+s*rv1(k);
    end %enddo 22
   end %enddo 23
   for k=L:n %do 24 k=l,n
    A(i,k)=scale*A(i,k);
   end %enddo 24
  end
 end
 anorm=max(anorm,(abs(w(i))+abs(rv1(i))));
end %enddo 25
v=repmat(a_zero,n,n);%Preallocate space
for i=n:-1:1 %do 32 i=n,1,-1 Accumulation of right-hand transformations.
 if(i<n)
  if(g~=a_zero)
   for j=L:n %do 26 j=l,n Double division to avoid possible underflow.
    v(j,i)=(A(i,j)/A(i,L))/g;
   end %enddo 26
   for j=L:n %do 29 j=l,n
    s=a_zero;
    for k=L:n %do 27 k=l,n
     s=s+A(i,k)*v(k,j);
    end %enddo 27
    for k=L:n %do 28 k=l,n
     v(k,j)=v(k,j)+s*v(k,i);
    end %enddo 28
   end %enddo 29
  end
  for j=L:n %do 31 j=l,n
   v(i,j)=a_zero;
   v(j,i)=a_zero;
  end %enddo 31
 end
 v(i,i)=1+a_zero;
 g=rv1(i);
 L=i;
end %enddo 32
for i=min(m,n):-1:1 %do 39 i=min(m,n),1,-1 Accumulation of left-hand transformations.
 L=i+1;
 g=w(i);
 for j=L:n %do 33 j=l,n
  A(i,j)=a_zero;
 end %enddo 33
 if(g~=a_zero)
  g=a_one/g;
  for j=L:n %do 36 j=l,n
   s=a_zero;
   for k=L:m %do 34 k=l,m
    s=s+A(k,i)*A(k,j);
   end %enddo 34
   f=(s/A(i,i))*g;
   for k=i:m %do 35 k=i,m
    A(k,j)=A(k,j)+f*A(k,i);
   end %enddo 35
  end %enddo 36
  for j=i:m %do 37 j=i,m
   A(j,i)=A(j,i)*g;
  end %enddo 37
 else
  for j=i:m %do 38 j= i,m
   A(j,i)=a_zero;
  end %enddo 38
 end
 A(i,i)=A(i,i)+a_one;
end %enddo 39
for k=n:-1:1 %do 49 k=n,1,-1 
             %Diagonalization of the bidiagonal form:Loop over
             %singular values,and over allowed iterations.
 for its=1:30 %do 48 its=1,30
  flag=1;%default action
  for L=k:-1:1 %do 41 l=k,1,-1 Test for splitting.
   nm=L-1; %Note that rv1(1) is always zero.
   if((abs(rv1(L))+anorm)==anorm)                 
    flag=0; %goto 2
    break
   elseif((abs(w(nm))+anorm)==anorm) 
    break
   end
  end %enddo 41
  if flag==1
   %1        label 1
   c=a_zero; % Cancellation of rv1(l),if l > 1
   s=a_one;
   for i=L:k %do 43 i=l,k
    f=s*rv1(i);
    rv1(i)=c*rv1(i);
    if((abs(f)+anorm)==anorm) 
     break
    end
    g=w(i);
    h=pythag(f,g);
    w(i)=h;
    h=a_one/h;
    c= (g*h);
    s=-(f*h);
    for j=1:m %do 42 j=1,m
     y=A(j,nm);
     z=A(j,i);
     A(j,nm)=(y*c)+(z*s);
     A(j,i)=-(y*s)+(z*c);
    end %enddo 42
   end %enddo 43
  end %del goto 1
      %2                  
  z=w(k);
  if(L==k)%then Convergence.
   if(z<=a_zero)% Singular value is made nonnegative.
    w(k)=-z;
    for j=1:n %do 44 j=1,n
     v(j,k)=-v(j,k);
    end %enddo 44
   end
   break
  end
  if(its==30) 
   error('no convergence in 30 iterations of svdcmp')
  end
  x=w(L);% Shift from bottom 2-by-2 minor.
  nm=k-1;
  y=w(nm);
  g=rv1(nm);
  h=rv1(k);
  f=((y-z)*(y+z)+(g-h)*(g+h))/(2.0*h*y);
  g=pythag(f,a_one);
  f=((x-z)*(x+z)+h*((y/(f+signtransf(g,f)))-h))/x;
  c=a_one; %Next QR transformation:
  s=a_one;
  for j=L:nm %do 47 j=l,nm
   i=j+1;
   g=rv1(i);
   y=w(i);
   h=s*g;
   g=c*g;
   z=pythag(f,h);
   rv1(j)=z;
   c=f/z;
   s=h/z;
   f= (x*c)+(g*s);
   g=-(x*s)+(g*c);
   h=y*s;
   y=y*c;
   for jj=1:n %do 45 jj=1,n
    x=v(jj,j);
    z=v(jj,i);
    v(jj,j)= (x*c)+(z*s);
    v(jj,i)=-(x*s)+(z*c);
   end %enddo 45
   z=pythag(f,h);
   w(j)=z;% Rotation can be arbitrary if z =0
   if(z~=a_zero)
    z=a_one/z;
    c=f*z;
    s=h*z;
   end
   f= (c*g)+(s*y);
   x=-(s*g)+(c*y);
   for jj=1:m %do 46 jj=1,m
    y=A(jj,j);
    z=A(jj,i);
    A(jj,j)= (y*c)+(z*s);
    A(jj,i)=-(y*s)+(z*c);
   end %enddo 46
  end %enddo 47
  rv1(L)=a_zero;
  rv1(k)=f;
  w(k)=x;
 end %enddo 48
     %3 continue
end %enddo 49
[dummy,I]=sort(-w(1:n));%Sort in decreasing order
S=diag(w(I));
if nargin<2
 %fill in with zeros in order to satisfy dimension requirements
 if n<size(A,1),S(size(A,1),n)=a_zero;end
 if n<size(A,2),S(n,size(A,2))=a_zero;end
 %Create a square U matrix
 dummy=A(:,I);
 [U,dummy]=qr(dummy);
 %correct some signs
 q=find(diag(dummy)<0);U(:,q)=-U(:,q);
else
 %go on with the economy size version
 U=A(:,I);
end
V=v(1:n,I);
if nargout<=1,U=w(I);U=U(:);end
return

function py=pythag(a,b)
%REAL a,b,pythag
%Computes (a^2 + b^2 )^1/2 without destructive under flow or over flow.
absa=abs(a);
absb=abs(b);
if(absa>absb)
 py=absa*sqrt(1.+(absb/absa)^2);
else
 if(absb==0)
  py=absb;
 else
  py=absb*sqrt(1.+(absa/absb)^2);
 end
end

function c=signtransf(A1,A2)
%C = SIGNTRANSF(A1,A2) performs sign transfer: if A2 is negative the result is -abs(A1),
%if A2 is zero or positive the result is abs(A1).
%It is the fortran equivalent of SIGN(A1,A2) 
% (see http://www.math.hawaii.edu/lab/197/fortran/fort4.htm#sign)
c=abs(A1);
q=find(A2<0);c(q)=-abs(A1(q));