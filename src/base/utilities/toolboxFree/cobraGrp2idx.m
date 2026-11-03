function [g, gN, gL] = cobraGrp2idx(s)
% Creates an index vector from a grouping variable, without the Statistics
% and Machine Learning Toolbox.
%
% USAGE:
%
%    [g, gN, gL] = cobraGrp2idx(s)
%
% INPUT:
%    s:     grouping variable: numeric, logical or categorical vector, char
%           array (one group per row), cell array of character vectors, or
%           string array
%
% OUTPUTS:
%    g:     column vector (double) of group indices 1..K, with NaN where `s`
%           is missing (NaN, '', "", <missing>, <undefined>)
%    gN:    K x 1 cell array of character vectors, the group names, so that
%           `gN(g)` reproduces `s`
%    gL:    K x 1 group levels of the same type as `s` (char input gives a
%           char matrix, string input gives a cell array of character vectors)
%
% EXAMPLE:
%
%    [g, gN] = cobraGrp2idx({'b'; 'a'; 'b'})   % g = [1; 2; 1], gN = {'b'; 'a'}
%
% NOTE:
%    Plain-MATLAB replacement for grp2idx (Statistics and Machine Learning
%    Toolbox); supported syntaxes: [g, gN, gL] = cobraGrp2idx(s) for the input
%    types listed above (datetime, duration and other types raise an error);
%    semantics: mathworks-semantics.md section 7. Group order: sorted for
%    numeric and logical input, the order of categories(s) for categorical input
%    (every category is a group, used or not), first appearance for char, cell
%    and string input. Numeric group names are strtrim(cellstr(num2str(gL)))
%    of the whole column of levels (the R14 rule; num2str then uses one format
%    for all levels, so non-integers share the number of decimals), giving '0'
%    and '1' for logical input. The text 'NaN' is an ordinary group name, not
%    a missing value.
%
% .. Author: generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

if iscategorical(s)
    s = s(:);
    gN = categories(s);
    gN = gN(:);
    g = double(s);
    gL = categorical(gN, gN, 'Ordinal', isordinal(s));
    return
end

if ischar(s)
    % one group per row; trailing blanks are not part of the name
    textValues = cellstr(s);
    isMissing = cellfun('isempty', textValues);
elseif isstring(s)
    checkVector(s);
    s = s(:);
    isMissing = ismissing(s) | s == "";
    textValues = repmat({''}, numel(s), 1);
    textValues(~isMissing) = cellstr(s(~isMissing));
elseif iscellstr(s)
    checkVector(s);
    textValues = s(:);
    isMissing = cellfun('isempty', textValues);
elseif isnumeric(s) || islogical(s)
    checkVector(s);
    s = s(:);
    isMissing = isnan(s);
    [gL, ~, groupOfValue] = unique(s(~isMissing));
    g = NaN(numel(s), 1);
    g(~isMissing) = groupOfValue;
    % names: num2str of the whole column of levels, blanks trimmed
    gN = cell(0, 1);
    if ~isempty(gL)
        gN = strtrim(cellstr(num2str(gL)));
    end
    return
else
    error('cobraGrp2idx:unsupportedType', ...
        'cobraGrp2idx: grouping variables of class %s are not supported.', class(s));
end

% text input: groups in order of first appearance
[gN, ~, groupOfValue] = unique(textValues(~isMissing), 'stable');
gN = gN(:);
g = NaN(numel(textValues), 1);
g(~isMissing) = groupOfValue;
if ischar(s)
    gL = char(gN);
else
    gL = gN;
end
end

function checkVector(s)
% grouping variables other than char arrays must be vectors
if ~isempty(s) && ~isvector(s)
    error('cobraGrp2idx:notVector', 'cobraGrp2idx: the grouping variable must be a vector.');
end
end
