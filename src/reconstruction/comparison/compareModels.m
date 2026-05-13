function [isSameModel,diffTable,why] = compareModels(modelA,modelB)
% compares modelA with modelB, looking for differences between the
% structures. Assumes any pair of NaN are identical.
%
% INPUT
% modelA:       structure
% modelB:       structure
%
% OUTPUT
% isSameModel:  true if identical models, false otherwise
%
% diffTable:    table listing differences between fields in the input
%               structures, including dimensions when they differ
%
% why:          structure listing differences between models
%
% Note: This function depends on structeq.m and celleq.m

funh2string = false;
ignorenan = true;

[isSameModel, why] = structeq(modelA, modelB, funh2string, ignorenan);

% Use sensible variable names even when compareModels is called on
% expressions rather than named variables.
nameA = inputname(1);
nameB = inputname(2);
if isempty(nameA)
    nameA = 'modelA';
end
if isempty(nameB)
    nameB = 'modelB';
end

if isSameModel
    % Return an empty table with consistent column names.
    diffTable = table( ...
        string.empty(0,1), ...
        cell(0,1), ...
        cell(0,1), ...
        string.empty(0,1), ...
        string.empty(0,1), ...
        string.empty(0,1), ...
        'VariableNames', {'field', nameA, nameB, [nameA '_size'], [nameB '_size'], 'reason'});
    why = [];
    return
end

% Convert difference structure to table.
diffTable = struct2table(why, 'AsArray', true);

% Keep only the columns we want, and rename them.
diffTable = diffTable(:, {'Where','A','B','ASize','BSize','Reason'});
diffTable.Properties.VariableNames = {'field', nameA, nameB, [nameA '_size'], [nameB '_size'], 'reason'};

% Clean up field names for display.
diffTable.field = string(diffTable.field);
for j = 1:height(diffTable)
    str = diffTable.field(j);

    % If there is a dot path, strip the leading parent reference.
    dotPos = strfind(str, '.');
    if ~isempty(dotPos)
        str = eraseBetween(str, 1, dotPos(1));
    end

    diffTable.field(j) = str;
end

% Format the value columns as readable text.
diffTable.(nameA) = formatTableColumn(diffTable.(nameA));
diffTable.(nameB) = formatTableColumn(diffTable.(nameB));

% Ensure size and reason columns are strings for easy display/export.
diffTable.([nameA '_size']) = string(diffTable.([nameA '_size']));
diffTable.([nameB '_size']) = string(diffTable.([nameB '_size']));
diffTable.reason = string(diffTable.reason);

% Convert field to cellstr if you prefer unquoted display in MATLAB tables.
diffTable.field = cellstr(diffTable.field);
end

function s = valueSize2str(x)
% Return size of a MATLAB value as a compact string like "5x7" or "1x1".

    s = sizeVec2str(size(x));
end

function s = sizeVec2str(sz)
% Convert a size vector into a compact string like "5x7x3".

    if isempty(sz)
        s = "";
        return
    end

    s = join(string(sz), "x");
    s = s(1);
end

function out = formatTableColumn(in)
% Convert a table column of arbitrary MATLAB values into a cell array of
% character vectors for readable display.

    if ~iscell(in)
        in = num2cell(in);
    end

    out = cell(size(in));
    for k = 1:numel(in)
        try
            out{k} = char(any2str(in{k}));
        catch
            out{k} = evalc('disp(in{k})');
            out{k} = strtrim(out{k});
        end
    end
end