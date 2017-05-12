function out=mpAddDecimal(str)

if strncmp(str,'-',1)
 out=['-.',str(2:end)];
else
 out=['.',str];
end
