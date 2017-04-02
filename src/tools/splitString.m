function fields = splitString(string, delimiter)
% Splits a string Perl style
%
% USAGE:
%
%     fields = splitString(string, delimiter)
%
% INPUTS:
%    string:      Either a single string or a cell array of strings
%    delimiter:   Splitting delimiter
%
% OUTPUT:
%    fields:      Either a single cell array of fields or a cell array of cell
%                 arrays of fields
%
% Default delimiter is '\s' (whitespace)
% Delimiters are perl regular expression style, e.g. '|' has to be expressed
% as '\|'
% Results are returned in the cell array fields
%
% .. Authors:  Markus Herrgard 07/14/04

if nargin < 2
    delimiter = '\s';
end

% Check if this is a list of strings or just a single string
if iscell(string)
    stringList = string;
    for i = 1:length(stringList)
        fields{i} = splitOneString(stringList{i}, delimiter);
    end
else
    fields = splitOneString(string, delimiter);
end

fields = columnVector(fields);


function fields = splitOneString(string, delimiter)
% Internal function that splits one string

[startIndex, endIndex] = regexp(string, delimiter);

if ~isempty(startIndex)
    cnt = 0;
    for i = 1:length(startIndex) + 1
        if i == 1
            if endIndex(i) > 1
                cnt = cnt + 1;
                fields{cnt} = string(1:endIndex(i) - 1);
            end
        elseif i == length(startIndex) + 1
            if startIndex(i - 1) < length(string)
                cnt = cnt + 1;
                fields{cnt} = string(startIndex(i - 1) + 1:end);
            end
        else
            cnt = cnt + 1;
            fields{cnt} = string(startIndex(i - 1) + 1:endIndex(i) - 1);
        end
    end
else
    fields{1} = string;
end

fieldsOut = {};
cnt = 0;
for i = 1:length(fields)
    if ~isempty(fields{i})
        cnt = cnt + 1;
        fieldsOut{cnt} = fields{i};
    end
end
fields = fieldsOut;
