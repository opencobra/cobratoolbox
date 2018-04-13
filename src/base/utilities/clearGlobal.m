function clearGlobal(globalName)
% Safely clear a global variable.
%
% USAGE:
%    clearGlobal(globalName)
%
% INPUTS:
%    globalName:    The name of the global variable to clear.

    clearvars('-global',globalName);
end