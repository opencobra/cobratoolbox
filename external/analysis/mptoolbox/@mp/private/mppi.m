function out=mppi(precision)

if nargin==0
 mp_defaults
 precision=default_precision;
end

out_rval=mpfr_pi(precision);

out=class(struct('rval',out_rval,...
                  'ival','0',...
                  'precision',precision),'mp');
