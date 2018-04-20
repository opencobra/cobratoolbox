function restoreEnvironment(environment, restorePath, printLevel)
% Reset all global variables to a value stored in the input struct (all
% variables not present will be deleted.
% USAGE:
%    restoreEnvironment(globals)
%
% INPUTS:
%    environment:      A struct with the following fields:
%                       * .globals: a struct with the fields being global variables and the value the respective values.
%                       * .path: the path to restore (it will override the current path)
%    restorePath:      Also restore the path (default: true)       
%    printLevel:       Set the verbosity of this method:
%                       * 0: No outputs (Default)
%                       * 1: Info what each value is set to
%                                   
    if ~exist('restorePath','var')
        restorePath = true;
    end
    if ~exist('printLevel','var')
        printLevel = 0;
    end

    globalvars = who('global');
    globalsToDelete = setdiff(globalvars,fieldnames(environment.globals));

    for i = 1:numel(globalsToDelete)
        clearGlobal(globalsToDelete{i});
    end

    % for everything else, check, if it changed
    globalNames = fieldnames(environment.globals);
    for i = 1:numel(globalNames)
        % set the global to the old value.
        setGlobal(globalNames{i},environment.globals.(globalNames{i}));
        if printLevel >= 1
            fprintf('%s set to:\n', globalNames{i});
            disp(environment.globals.(globalNames{i}));
        end
    end
    %Restore the path
    if restorePath
        path(environment.path);
        if printLevel >= 1
            fprintf('Path set to:\n%s\n', sprintf(strrep(environment.path,':','\n')));
        end    
    end
end

