function out=mpower(x,y)

precisionx=0;   precisiony=0;
if isa(x,'mp')
 precisionx=x(1).precision;
end
if isa(y,'mp')
 precisiony=y(1).precision;
end
precision=max(precisionx,precisiony);
ex=numel(x);
ey=numel(y);

if ex==1 & ey==1
 out=x.^y;
elseif ey==1
 if y==fix(y)
  out=mp(eye(size(x)),precision);
  for ii=1:y
   out=out*x;
  end
 else
  error('mpower for fractional exponents is not written for mp objects')
 end
else
 error('mpower for matrix exponents hasn''t been written for mp objects')
end