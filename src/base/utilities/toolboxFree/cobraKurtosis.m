function k = cobraKurtosis(X, flag, dim)
% Sample kurtosis (not excess kurtosis), ignoring NaN values, without the
% Statistics and Machine Learning Toolbox.
%
% USAGE:
%
%    k = cobraKurtosis(X)
%    k = cobraKurtosis(X, flag)
%    k = cobraKurtosis(X, flag, dim)
%
% INPUT:
%    X:         single or double array
%
% OPTIONAL INPUTS:
%    flag:      1 (default) for the biased estimate m4 / m2^2, 0 for the
%               bias-corrected estimate (NaN when fewer than 4 values)
%    dim:       dimension to work along (default: first non-singleton
%               dimension), a vector of dimensions, or 'all'
%
% OUTPUT:
%    k:         kurtosis (3 for a normal distribution); `size(X)` with the
%               working dimension(s) set to 1. NaN for a slice of one value,
%               for X = [] without dim, and for a slice whose values are
%               exactly equal after subtracting the mean (0/0); a slice that is
%               constant only up to rounding gives a finite, meaningless value.
%
% EXAMPLE:
%
%    k = cobraKurtosis([1 2 3 4])   % 1.64
%
% NOTE:
%    Plain-MATLAB replacement for kurtosis (Statistics and Machine Learning
%    Toolbox); supported syntaxes: kurtosis(X), kurtosis(X, flag),
%    kurtosis(X, flag, dim) with dim a scalar, a vector or 'all';
%    semantics: mathworks-semantics.md section 11. The central moments divide
%    by n, the number of non-NaN values of each slice; 3 is not subtracted.
%    flag = 0 gives ((n+1)*k1 - 3*(n-1))*(n-1)/((n-2)*(n-3)) + 3. Integer,
%    logical and other non-floating-point X and repeated dimensions in dim raise
%    an error.
%
% .. Author: generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

if ~exist('flag', 'var') || isempty(flag)
    flag = 1;
end
if ~(isequal(flag, 0) || isequal(flag, 1))
    error('cobraKurtosis:badFlag', 'cobraKurtosis: flag must be 0 or 1.');
end
if ~isfloat(X)
    error('cobraKurtosis:notFloat', 'cobraKurtosis: X must be a single or double array.');
end
if ~exist('dim', 'var') || isempty(dim)
    if isequal(X, [])
        k = NaN('like', X);
        return
    end
    dim = find(size(X) ~= 1, 1);
    if isempty(dim)
        dim = 1;
    end
elseif (ischar(dim) || isstring(dim)) && strcmpi(dim, 'all')
    dim = 1:ndims(X);
elseif ~isnumeric(dim) || any(dim < 1) || any(dim ~= round(dim)) || numel(unique(dim)) < numel(dim)
    error('cobraKurtosis:badDim', 'cobraKurtosis: dim must be distinct positive integers or ''all''.');
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
m4 = sum(centred .^ 4, 1, 'omitnan') ./ n;
k = m4 ./ m2 .^ 2;
if flag == 0
    k = ((n + 1) .* k - 3 * (n - 1)) .* (n - 1) ./ ((n - 2) .* (n - 3)) + 3;
    k(n < 4) = NaN;
end
k = reshape(k, sizeOut);
end
