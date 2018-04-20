function setGlobal(globalName,globalValue)
% Safely set a global Variable to a specific value.
%
% USAGE:
%    setGlobal(globalName,globalValue)
%
% INPUTS:
%    globalName:    A string representing the name of the global variable
%    globalValue:   The value to set the global variable to

    eval([ globalName '_val = globalValue;']);
    eval(['global ' globalName]);
    eval([globalName ' = ' globalName '_val;']);
end