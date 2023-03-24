function r = isarm()
r = false;
if ismac()
   [~,result] = system('sysctl -n machdep.cpu.brand_string');
   r = contains(result, 'Apple');
end
end