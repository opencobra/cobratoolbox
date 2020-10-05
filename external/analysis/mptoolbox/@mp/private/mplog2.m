function out=mplog2(precision)

if nargin==0
 mp_defaults
 precision=default_precision;
end

out_rval=mpfr_const_log2(precision);

out=class(struct('rval',out_rval,...
                  'ival','0',...
                  'precision',precision),'mp');
