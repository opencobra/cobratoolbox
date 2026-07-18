function r = isarm()
% Return true when running on an Apple silicon (ARM) processor
%
% USAGE:
%
%    r = isarm()
%
% OUTPUTS:
%    r:          logical, true on an Apple ARM CPU, false otherwise
%

r = false;
if ismac()
   [~,result] = system('sysctl -n machdep.cpu.brand_string');
   r = contains(result, 'Apple');
end
end