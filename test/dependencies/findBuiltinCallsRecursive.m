function [builtinNames, callTable] = findBuiltinCallsRecursive(entryFile, includeCalleeBuiltins)
%FINDBUILTINCALLSRECURSIVE  
% Recursively find built-in MATLAB functions used by a script/function and
% optionally by all user-defined callees.
%
%   [builtinNames, callTable] = findBuiltinCallsRecursive('testAll.m')
%
%   Inputs:
%       entryFile             - name or path of entry .m file
%       includeCalleeBuiltins - logical (default=true)
%                               true: include built-ins from callees
%                               false: only built-ins directly in entry file
%
%   Outputs:
%       builtinNames - sorted unique built-in names (cellstr)
%       callTable    - unique table with columns:
%                        BuiltinName
%                        CallerFile
%                        ToolboxName

    if nargin < 2 || isempty(includeCalleeBuiltins)
        includeCalleeBuiltins = true;
    end

    % ---------------------------------------------------------------------
    % Resolve entry file and MATLAB toolbox root
    % ---------------------------------------------------------------------
    resolved = which(entryFile);
    if isempty(resolved)
        error('Cannot find file on path: %s', entryFile);
    end
    entryFile = resolved;

    % Find MATLAB toolbox root using which matlab
    matlabPath = which('matlab');
    if isempty(matlabPath)
        error('MATLAB cannot be located using "which matlab".');
    end

    fs     = filesep;
    marker = [fs 'toolbox' fs];
    idx    = strfind(lower(matlabPath), lower(marker));

    if isempty(idx)
        matlabToolboxRoot = '';
    else
        matlabToolboxRoot = matlabPath(1 : idx + length(marker) - 1); % ends in .../toolbox/
    end

    % ---------------------------------------------------------------------
    % Accumulators
    % ---------------------------------------------------------------------
    visited              = containers.Map('KeyType','char','ValueType','logical');
    builtinSet           = containers.Map('KeyType','char','ValueType','logical');

    builtinCallNames     = {};
    builtinCallerFiles   = {};
    builtinToolboxNames  = {};

    % ---------------------------------------------------------------------
    % Begin recursion
    % ---------------------------------------------------------------------
    processFile(entryFile, 0);

    % ---------------------------------------------------------------------
    % Unique builtin names
    % ---------------------------------------------------------------------
    builtinNames = sort(builtinSet.keys())';

    % ---------------------------------------------------------------------
    % Build unique table
    % ---------------------------------------------------------------------
    callTable = table( ...
        builtinCallNames(:), ...
        builtinCallerFiles(:), ...
        builtinToolboxNames(:), ...
        'VariableNames', {'BuiltinName','CallerFile','ToolboxName'} ...
    );

    % Remove duplicate rows
    callTable = unique(callTable);

    % =====================================================================
    % Nested: Recursively process a file
    % =====================================================================
    function processFile(fpath, depth)

        if isKey(visited, fpath)
            return;
        end
        visited(fpath) = true;

        txt = fileread(fpath);

        % Identify function-call tokens: name(...)
        tokens = regexp(txt, '(?<!\.)\<([A-Za-z]\w*)\s*(?=\()', 'tokens');
        if isempty(tokens)
            return;
        end

        callNames = unique(vertcat(tokens{:}));

        for k = 1:numel(callNames)
            name = callNames{k};

            % Skip MATLAB keywords (e.g. if, while, end)
            if iskeyword(name)
                continue;
            end

            w = which(name);
            if isempty(w)
                continue;
            end

            % ---- A. Built-in function ----
            if contains(w, 'built-in')

                % Add only if depth permitted
                if includeCalleeBuiltins || depth == 0
                    builtinSet(name) = true;

                    % Toolbox name is determined by CALLER file fpath, not w
                    toolboxName = determineToolboxFromCaller(fpath, matlabToolboxRoot, fs);

                    % record the row
                    builtinCallNames{end+1,1}    = name;      %#ok<AGROW>
                    builtinCallerFiles{end+1,1}  = fpath;     %#ok<AGROW>
                    builtinToolboxNames{end+1,1} = toolboxName; %#ok<AGROW>
                end

            % ---- B. User .m file: recurse ----
            elseif endsWith(w, '.m')
                processFile(w, depth + 1);

            % ---- C. Ignore p-files, Java, methods, classes, etc. ----
            else
                % Could extend here if desired
            end
        end
    end
end

% =====================================================================
% Determine toolbox of the CALLER.
% If the caller path starts with <matlabToolboxRoot>, extract the folder
% immediately beneath .../toolbox/.
% Else: return '' (blank).
% =====================================================================
function tbName = determineToolboxFromCaller(callerPath, toolboxRoot, fs)

    tbName = '';

    if isempty(toolboxRoot)
        return;
    end

    callerLower = lower(callerPath);
    rootLower   = lower(toolboxRoot);

    if startsWith(callerLower, rootLower)
        rel = callerPath(length(toolboxRoot)+1 : end);
        parts = strsplit(rel, fs);
        if ~isempty(parts)
            tbName = parts{1};
        end
    end
end
