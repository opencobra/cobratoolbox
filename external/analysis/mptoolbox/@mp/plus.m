function out=plus(x,y)

precAndSize

if ex==1, [xrval,xival]=getVals(x,1); end
if ey==1, [yrval,yival]=getVals(y,1); end

for ii=1:max(ex,ey)
 imag=false;
 if ex==1
  [yrval,yival]=getVals(y,ii);
 elseif ey==1
  [xrval,xival]=getVals(x,ii);
 else
  [xrval,xival]=getVals(x,ii);
  [yrval,yival]=getVals(y,ii);
 end
 if hasimag(xival) | hasimag(yival), imag=true; end
 out_rval{ii}=mpfr_add(precision,xrval,yrval);
 if imag
  out_ival{ii}=mpfr_add(precision,xival,yival);
 end
end % for ii=1:max(ex,
out=class(struct('rval',out_rval,...
                  'ival',out_ival,...
                  'precision',precision),'mp');

