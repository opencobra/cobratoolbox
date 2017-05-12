function out=mp_log2(precision)

if nargin==0
 out=mpLog2(mp(0));
else
 out=mpLog2(mp(precision));
end
