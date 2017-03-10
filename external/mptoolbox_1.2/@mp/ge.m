function outn=ge(x,y)

precAndSize

for ii=1:max(ex,ey)
 imag=false;
 if ex==1
  [xrval,xival]=getVals(x,1);
  [yrval,yival]=getVals(y,ii);
 elseif ey==1
  [xrval,xival]=getVals(x,ii);
  [yrval,yival]=getVals(y,1);
 else
  [xrval,xival]=getVals(x,ii);
  [yrval,yival]=getVals(y,ii);
 end 
  outn(ii)=mpfr_ge(precision,xrval,yrval);
  if outn(ii)~=0, outn(ii)=1; end
end % for ii=1:max(ex,
