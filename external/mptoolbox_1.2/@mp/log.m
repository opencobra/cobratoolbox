function out=log(x)

precision=x(1).precision;
out_rval=cell(size(x));
out_ival=cell(size(x));

for ii=1:numel(x)
 imag=false;
 [xrval,xival]=getVals(x,ii);
 if hasimag(xival), imag=true; end
 if imag
  [out_rval{ii},out_ival{ii}]=mpfr_logc(precision,xrval,xival);
 else
  out_rval{ii}=mpfr_log(precision,xrval);
 end
end % for ii=1:max(ex,
out=class(struct('rval',out_rval,...
                  'ival',out_ival,...
                  'precision',precision),'mp');
