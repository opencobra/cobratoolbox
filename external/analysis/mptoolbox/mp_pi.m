function out=mp_pi(precision)

if nargin==0
 out=mpPi(mp(0));
else
 out=mpPi(mp(precision));
end
