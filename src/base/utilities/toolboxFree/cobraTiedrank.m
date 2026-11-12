function [r, tieadj] = cobraTiedrank(x, varargin)
% Ranks data, averaging the ranks of ties, without the Statistics and Machine
% Learning Toolbox
%
% USAGE:
%
%    [r, tieadj] = cobraTiedrank(x)
%
% INPUT:
%    x:        real numeric or logical vector or matrix; a matrix is ranked
%              column by column, a vector (row or column) as one sample
%
% OUTPUTS:
%    r:        ranks, the same size as `x` (double); tied values get the
%              average of the ranks they span; NaN values get NaN and the
%              other values of their column are ranked 1..n (n = number of
%              non-NaN values in the column)
%    tieadj:   tie adjustment `sum(t.^3 - t)/2` over the groups of t tied
%              values; a scalar for vector input, a 1 x ncol row for a matrix
%
% EXAMPLE:
%
%    [r, tieadj] = cobraTiedrank([-2 1 3 1 4])   % r = [1 2.5 4 2.5 5], tieadj = 3
%
% NOTE:
%    Plain-MATLAB replacement for tiedrank (Statistics and Machine Learning
%    Toolbox); supported syntax: [r, tieadj] = cobraTiedrank(x). The optional
%    tieflag and bidir arguments of tiedrank raise an error naming them;
%    semantics: specs/20261111-152503-toolbox-free-remaining/
%    mathworks-semantics.md, G1 section 8. Algorithm: sort each column
%    (NaN last), assign positions 1..n, and replace each run of equal values
%    by the mean of its positions.
%
% .. Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

if ~isempty(varargin)
    optionNames = {'tieflag', 'bidir'};
    error('COBRA:cobraTiedrank:unsupportedOption', ...
        'cobraTiedrank: unsupported option ''%s'' (only the syntax cobraTiedrank(x) is supported).', ...
        optionNames{min(numel(varargin), 2)});
end
if ~(isnumeric(x) || islogical(x)) || ~isreal(x) || ~ismatrix(x)
    error('COBRA:cobraTiedrank:invalidInput', 'cobraTiedrank: x must be a real numeric or logical vector or matrix.');
end

isRowVector = isrow(x);
if isRowVector
    x = x(:);
end
x = double(x);
r = NaN(size(x));
tieadj = zeros(1, size(x, 2));
for column = 1:size(x, 2)
    values = x(:, column);
    isPresent = ~isnan(values);
    [sortedValues, order] = sort(values(isPresent));
    n = numel(sortedValues);
    if n == 0
        continue
    end
    % runs of equal values: the rank of a run is the mean of its positions
    % (compared directly, not by diff, so that repeated Inf values are ties)
    runStart = [true; sortedValues(2:end) ~= sortedValues(1:end - 1)];
    runIndex = cumsum(runStart);
    runLength = accumarray(runIndex, 1);
    runFirst = find(runStart);
    runMean = runFirst + (runLength - 1) / 2;
    ranks = runMean(runIndex);
    presentRanks = zeros(n, 1);
    presentRanks(order) = ranks;
    r(isPresent, column) = presentRanks;
    tieadj(column) = sum(runLength .^ 3 - runLength) / 2;
end
if isRowVector
    r = r.';
end
end
