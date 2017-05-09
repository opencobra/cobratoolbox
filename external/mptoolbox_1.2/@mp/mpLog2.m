function out=mpLog2(precision)

if precision==0
 mp_defaults
 out=mplog2(default_precision);
else
 out=mplog2(double(precision));
end
