function c=mldivide(A,b)
%mldivide: Solves the system A\b, at least one of them of class mp, producing another element of class mp

precisionA=0;precisionb=0;
xmp=isa(A,'mp');
if xmp
 precisionA=A(1).precision;
 ymp=isa(b,'mp');
else
 ymp=true;
end
if ymp
 precisionb=b(1).precision;
end
precision=max(precisionA,precisionb);

if ~isa(A,'mp')
 A=mp(A,precision);
end
if ~isa(b,'mp')
 b=mp(b,precision);
end
%check for dimensions
if any(size(A)~=size(b))
 if size(A,1)==1
  %scalar case; it is a simple division Ax=b==>x=b/A (change the order of parameters!)
  c = rdivide(b,A);
 else
  %either over or undeterminated system of equations.
  %use the QR factorization to solve the problem
  [Q,R]=qr(A,0); %economy size; output matrix R is square
  c=R\(Q'*b);
 end
else
 %square matrix; standard system of equations, to be solved by gaussian elimination
 %A=A(1:min(size(A)),1:min(size(A)));
 [c,LU,b,shortP]=mp_gausscpp(A,b);
 %build the permutation matrix as a full one
 P=eye(size(LU));P=P(shortP,:);
end

