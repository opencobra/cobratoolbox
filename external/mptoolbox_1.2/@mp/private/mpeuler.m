function out=mpeuler(precision)

if nargin==0
 mp_defaults
 precision=default_precision;
end

out_rval=mpfr_euler(precision);

out=class(struct('rval',out_rval,...
                  'ival','0',...
                  'precision',precision),'mp');

