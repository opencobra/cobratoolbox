function tableOut = tabulatePlain(values)
%tabulatePlain Count values using base MATLAB.
%
% tableOut has the same first two columns used by this codebase as MATLAB's
% tabulate output: unique value and count. The third column is percentage.

values = values(:);
nValues = numel(values);

if nValues == 0
    tableOut = cell(0, 3);
    return
end

[uniqueValues, ~] = unique(values, 'stable');
[~, groupIndex] = ismember(values, uniqueValues);
counts = accumarray(groupIndex, 1);
percentages = 100 * counts / nValues;

if iscell(uniqueValues)
    firstColumn = uniqueValues;
else
    firstColumn = num2cell(uniqueValues);
end

tableOut = [firstColumn, num2cell(counts), num2cell(percentages)];
end
