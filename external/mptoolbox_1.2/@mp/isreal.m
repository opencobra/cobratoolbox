function out=isreal(x)

s=builtin('size',x);
out=true;
sx=prod(s);
for ii=1:sx
 ival=x(ii).ival;
 if any(ival~='0')
  out=false;
  break;
 end
end
