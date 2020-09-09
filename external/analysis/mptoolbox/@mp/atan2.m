function out=atan2(y,x)

if isa(x,'mp')
 precision=x(1).precision;
 if ~isa(y,'mp')
  y=mp(y,precision);
 end
else
 precision=y(1).precision;
 if ~isa(x,'mp')
  x=mp(x,precision);
 end 
end

if any(~isreal(x)) | any(~isreal(y))
 warning('atan2 for mp objects currently ignores imaginary parts')
 x=real(x);
 y=real(y);
end

ex=numel(x); ey=numel(y);
if ex==1
 x=ones(size(y))*x;
elseif ey==1
 y=ones(size(x))*y;  
end


out=atan(y./x);
mpPi=mppi(precision);
for ii=1:numel(x)
 if x(ii)<0
  if y(ii)>0
   out(ii)=out(ii)+mpPi;
  else
   out(ii)=out(ii)-mpPi;
  end
 end
end

out=real(out);