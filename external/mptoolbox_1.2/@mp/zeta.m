function out=zeta(x)

precision=x(1).precision;
out_rval=cell(size(x));
out_ival=cell(size(x));

for ii=1:numel(x)
 imag=false;
 [xrval,xival]=getVals(x,ii);
 if hasimag(xival), imag=true; end
 if imag
  error('argument of zeta function for mp objects must be real');
 else
  out_rval{ii}=mpfr_zeta(precision,xrval);
 end
end % for ii=1:max(ex,
out=class(struct('rval',out_rval,...
                  'ival',out_ival,...
                  'precision',precision),'mp');

