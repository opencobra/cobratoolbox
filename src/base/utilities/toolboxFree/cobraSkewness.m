function y = cobraSkewness(X, flag, dim)
% Sample skewness, ignoring NaN values, without the Statistics and Machine
% Learning Toolbox.
%
% USAGE:
%
%    y = cobraSkewness(X)
%    y = cobraSkewness(X, flag)
%    y = cobraSkewness(X, flag, dim)
%
% INPUT:
%    X:         single or double array
%
% OPTIONAL INPUTS:
%    flag:      1 (default) for the biased estimate m3 / m2^1.5, 0 for the
%               bias-corrected estimate (NaN when fewer than 3 values)
%    dim:       dimension to work along (default: first non-singleton
%               dimension), a vector of dimensions, or 'all'
%
% OUTPUT:
%    y:         skewness; `size(X)` with the working dimension(s) set to 1.
%               NaN for a slice of one value, for X = [] without dim, and
%               for a slice whose values are exactly equal after subtracting
%               the mean (0/0); a slice that is constant only up to rounding
%               gives a finite, meaningless value (for example +-1).
%
% EXAMPLE:
%
%    y = cobraSkewness([1 2 10])   % 0.6746
%
% NOTE:
%    Plain-MATLAB replacement for skewness (Statistics and Machine Learning
%    Toolbox); supported syntaxes: skewness(X), skewness(X, flag),
%    skewness(X, flag, dim) with dim a scalar, a vector or 'all';
%    semantics: mathworks-semantics.md section 11. The central moments divide
%    by n, the number of non-NaN values of each slice. flag = 0 multiplies by
%    sqrt(n*(n-1))/(n-2). Integer, logical and other non-floating-point X and
%    repeated dimensions in dim raise an error.
%
% .. Author: generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

if ~exist('flag', 'var') || isempty(flag)
    flag = 1;
end
if ~(isequal(flag, 0) || isequal(flag, 1))
    error('cobraSkewness:badFlag', 'cobraSkewness: flag must be 0 or 1.');
end
if ~isfloat(X)
    error('cobraSkewness:notFloat', 'cobraSkewness: X must be a single or double array.');
end
if ~exist('dim', 'var') || isempty(dim)
    if isequal(X, [])
        y = NaN('like', X);
        return
    end
    dim = find(size(X) ~= 1, 1);
    if isempty(dim)
        dim = 1;
    end
elseif (ischar(dim) || isstring(dim)) && strcmpi(dim, 'all')
    dim = 1:ndims(X);
elseif ~isnumeric(dim) || any(dim < 1) || any(dim ~= round(dim)) || numel(unique(dim)) < numel(dim)
    error('cobraSkewness:badDim', 'cobraSkewness: dim must be distinct positive integers or ''all''.');
end

% move the working dimensions to the front and make one column per slice
nDims = max([ndims(X), dim(:)']);
sizeX = size(X, 1:nDims);
otherDims = setdiff(1:nDims, dim);
sizeOut = sizeX;
sizeOut(dim) = 1;
slices = reshape(permute(X, [dim(:)', otherDims]), prod(sizeX(dim)), prod(sizeX(otherDims)));

n = sum(~isnan(slices), 1);
centred = slices - sum(slices, 1, 'omitnan') ./ n;
m2 = sum(centred .^ 2, 1, 'omitnan') ./ n;
m3 = sum(centred .^ 3, 1, 'omitnan') ./ n;
y = m3 ./ m2 .^ 1.5;
if flag == 0
    y = y .* sqrt(n .* (n - 1)) ./ (n - 2);
    y(n < 3) = NaN;
end
y = reshape(y, sizeOut);
end
