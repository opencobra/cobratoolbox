function out=mp_euler(precision)

if nargin==0
 out=mpEuler(mp(0));
else
 out=mpEuler(mp(precision));
end
