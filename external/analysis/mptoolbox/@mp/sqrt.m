function out=sqrt(x)

precision=x(1).precision;
out_rval=cell(size(x));
out_ival=cell(size(x));

for ii=1:numel(x)
 imag=false;
 [xrval,xival]=getVals(x,ii);
 if hasimag(xival), imag=true; end
 if imag
  [out_rval{ii},out_ival{ii}]=mpfr_sqrtc(precision,xrval,xival);
 else
  if x(ii)<0
   xrval=xrval(2:end);
  end
  str=mpfr_sqrt(precision,xrval);
  if x(ii)<0
   out_ival{ii}=str;
  else
   out_rval{ii}=str;
  end
 end
end % for ii=1:max(ex,
out=class(struct('rval',out_rval,...
                  'ival',out_ival,...
                  'precision',precision),'mp');

