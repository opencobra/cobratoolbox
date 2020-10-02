function out=mpPi(precision)

if precision==0
 mp_defaults
 out=mppi(default_precision);
else
 out=mppi(double(precision));
end