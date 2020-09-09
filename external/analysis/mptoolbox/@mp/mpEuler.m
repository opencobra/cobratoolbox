function out=mpEuler(precision)

if precision==0
 mp_defaults
 out=mpeuler(default_precision);
else
 out=mpeuler(double(precision));
end
