function defaultRow = getDefaultTableRow(tableRow)
% get a default table row
% USAGE:
%   defaultRow = getDefaultTableRow(tablerow)
%
% INPUT:
%    tableRow:        The row for which to define a default row
%  
% OUTPUT:
%    defaultRow:      A row with default values for different data types
%

defaultRow = tableRow(1,:);
% get the default values in a cell array to convert to a table row
for i = 1:size(tableRow,2)
    defaultRow{1,i} = getDefaultValue(tableRow{1,i});
end
end
