function out=power(x,y)

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
 if imag
  [out_rval{ii},out_ival{ii}]=mpfr_powc(precision,xrval,xival,yrval,yival);
 else
  out_rval{ii}=mpfr_pow(precision,xrval,yrval);
 end
end % for ii=1:max(ex,
out=class(struct('rval',out_rval,...
                  'ival',out_ival,...
                  'precision',precision),'mp');

% x=magic(3)*(1-.5*i),s1='023e1',s2='-.002e-1',x=mp(x,100)
% y=x+x;
