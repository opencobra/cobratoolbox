function restoreEnvironment(environment)
% Reset all global variables to a value stored in the input struct (all
% variables not present will be deleted.
% USAGE:
%    resetGlobals(globals)
%
% INPUT:
%    globals:   A struct with 1 field per global variable.

    globalvars = who('global');
    globalsToDelete = setdiff(globalvars,fieldnames(environment.globals));

    for i = 1:numel(globalsToDelete)
        clearGlobal(globalsToDelete{i});
    end

    % Note: we cannot clean functions as this would remove profiling information

    % for everything else, check, if it changed
    globalNames = fieldnames(environment.globals);
    for i = 1:numel(globalNames)
        % set the global to the old value.
        setGlobal(globalNames{i},environment.globals.(globalNames{i}));
    end
end


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
