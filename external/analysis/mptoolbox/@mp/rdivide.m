function out=rdivide(x,y)

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
 if hasimag(xival) | hasimag(yival), imag=true; end
 if imag
  [out_rval{ii},out_ival{ii}]=mpfr_divc(precision,xrval,xival,yrval,yival);
 else
  out_rval{ii}=mpfr_div(precision,xrval,yrval);
 end
end % for ii=1:max(ex,
out=class(struct('rval',out_rval,...
                  'ival',out_ival,...
                  'precision',precision),'mp');
