function builtinNames = findBuiltinCalls(scriptName)
%FINDBUILTINCALLS  List built-in functions called by a script or function.
%
%   builtinNames = findBuiltinCalls('myScript.m')
%
%   Returns a cell array of built-in function names that appear to be
%   called in the specified .m file, based on static analysis of the code.

    % Read the script/function as text
    txt = fileread(scriptName);

    % ---------------------------------------------------------------------
    % 1. Find identifiers that are used in "name(...)" positions
    %    - (?<!\.) : not preceded by a dot (so we ignore obj.method(...))
    %    - \<([A-Za-z]\w*) : a word starting with a letter, capture the name
    %    - \s*(?=\() : optional whitespace followed by "(" (lookahead)
    % ---------------------------------------------------------------------
    tokens = regexp(txt, '(?<!\.)\<([A-Za-z]\w*)\s*(?=\()', 'tokens');

    if isempty(tokens)
        builtinNames = {};
        return;
    end

    % Flatten cell-of-cells and make names unique
    callNames = unique(vertcat(tokens{:}));

    % ---------------------------------------------------------------------
    % 2. For each candidate name, ask MATLAB where it’s defined.
    %    If "which" says "built-in", we treat it as a built-in function.
    % ---------------------------------------------------------------------
    builtinList = {};

    for k = 1:numel(callNames)
        name = callNames{k};
        w = which(name);
        if isempty(w)
            continue;  % not found on path; ignore
        end

        % Typical built-in description starts with "built-in"
        % e.g. "built-in (C:\Program Files\MATLAB\R2024b\toolbox\matlab\elfun\sin)"
        if contains(w, 'built-in')
            builtinList{end+1,1} = name; %#ok<AGROW>
        end
    end

    builtinNames = unique(builtinList)';
end
