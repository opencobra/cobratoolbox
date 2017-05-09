function out=isnan(x)

precision=x(1).precision;
out=zeros(size(x));

for ii=1:numel(x)
 imag=false;
 [xrval,xival]=getVals(x,ii);
 if hasimag(xival), imag=true; end
 if imag
  temp=mpfr_isnan(precision,xrval);
  if temp~=0, out(ii)=1; end
  temp=mpfr_isnan(precision,xival);
  if temp~=0, out(ii)=1; end 
 else
  out(ii)=mpfr_isnan(precision,xrval);
  if out(ii)~=0, out(ii)=1; end
 end
end % for ii=1:max(ex,


