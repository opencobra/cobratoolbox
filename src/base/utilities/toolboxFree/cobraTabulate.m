function tbl = cobraTabulate(x)
% Frequency table of the values in a vector, without the Statistics and
% Machine Learning Toolbox.
%
% USAGE:
%
%    tbl = cobraTabulate(x)
%    cobraTabulate(x)
%
% INPUT:
%    x:     vector: numeric, logical, categorical, char array (one value per
%           row), cell array of character vectors, or string array
%
% OUTPUT:
%    tbl:   three columns Value, Count, Percent (percent on a 0-100 scale of
%           the non-missing values). A numeric matrix (double) when `x` is
%           numeric, otherwise a cell array whose Value column holds character
%           vectors. With no output argument the table is printed instead.
%
% EXAMPLE:
%
%    tbl = cobraTabulate([3 1 3])    % [1 1 33.33; 2 0 0; 3 2 66.67]
%
% NOTE:
%    Plain-MATLAB replacement for tabulate (Statistics and Machine Learning
%    Toolbox); supported syntaxes: tbl = cobraTabulate(x) and cobraTabulate(x)
%    (prints); semantics: mathworks-semantics.md section 6. NaN and other missing
%    values are left out. When every non-missing numeric value is a positive
%    integer, the rows are 1..max(x), including values with zero count;
%    otherwise only the values that occur, in ascending order. Non-numeric
%    input follows cobraGrp2idx order (first appearance for text, categories
%    order for categorical, sorted for logical, whose values print as '0', '1').
%    Printing: positive-integer tables use '  %5d    %5d    %6.2f%%'; all other
%    tables print the value as its cobraGrp2idx group name (num2str of the
%    value column for numbers) with '%Ns', N = max(5, min(50, longest name)).
%    Sparse input is converted with full(); Inf and -Inf raise an error
%    (with the 1..max(x) rule, MathWorks' behaviour for Inf is undefined).
%
% .. Author: generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

isPositiveIntegers = false;
if isnumeric(x)
    if ~isempty(x) && ~isvector(x)
        error('cobraTabulate:notVector', 'cobraTabulate: the input must be a vector.');
    end
    values = full(double(x(:)));
    values = values(~isnan(values));
    if any(isinf(values))
        error('cobraTabulate:infValue', 'cobraTabulate: Inf and -Inf values are not supported.');
    end
    isPositiveIntegers = ~isempty(values) && all(values == round(values)) && all(values >= 1);
    if isPositiveIntegers
        % positive integers: every integer from 1 to max(x), zero counts included
        counts = accumarray(values, 1, [max(values) 1]);
        values = (1:max(values))';
    else
        [values, ~, groupOfValue] = unique(values);
        counts = accumarray(groupOfValue, 1, [numel(values) 1]);
    end
    tbl = [values, counts, 100 * counts / sum(counts)];
else
    [g, gN] = cobraGrp2idx(x);
    counts = accumarray(g(~isnan(g)), 1, [numel(gN) 1]);
    tbl = [gN, num2cell(counts), num2cell(100 * counts / sum(counts))];
end

if nargout == 0
    % print the table in the MathWorks layout
    if isPositiveIntegers
        rows = num2cell(tbl);
        headerFormat = '  %5s    %5s   %6s\n';
        rowFormat = '  %5d    %5d    %6.2f%%\n';
    else
        if isnumeric(tbl)
            % other numeric values print as their cobraGrp2idx group names
            [~, valueNames] = cobraGrp2idx(tbl(:, 1));
            rows = [valueNames, num2cell(tbl(:, 2:3))];
        else
            rows = tbl;
        end
        % the value column is as wide as the longest name, at least 5 and at most 50
        valueWidth = max(5, min(50, max([0; cellfun('length', rows(:, 1))])));
        headerFormat = sprintf('  %%%ds    %%5s   %%6s\\n', valueWidth);
        rowFormat = sprintf('  %%%ds    %%5d    %%6.2f%%%%\\n', valueWidth);
    end
    fprintf(headerFormat, 'Value', 'Count', 'Percent'); %#ok<CTPCT> three %s fields in both formats
    for i = 1:size(rows, 1)
        fprintf(rowFormat, rows{i, :});
    end
    clear tbl
end
end
