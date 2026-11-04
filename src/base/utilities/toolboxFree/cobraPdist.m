function D = cobraPdist(X, distance, varargin)
% Pairwise distances between the rows of a matrix without the Statistics and
% Machine Learning Toolbox
%
% USAGE:
%
%    D = cobraPdist(X)
%    D = cobraPdist(X, distance)
%
% INPUT:
%    X:          `m` x `n` real numeric or logical matrix; each row is an
%                observation
%
% OPTIONAL INPUT:
%    distance:   'euclidean' (default) or 'jaccard' (case-insensitive)
%
%                * 'euclidean': `sqrt(sum((xs - xt).^2))`
%                * 'jaccard': one minus the Jaccard coefficient, the fraction
%                  of the coordinates where at least one of the two rows is
%                  nonzero in which the two rows differ:
%                  `#[(xs ~= xt) & ((xs ~= 0) | (xt ~= 0))] / #[(xs ~= 0) | (xt ~= 0)]`
%                  (non-binary values count as different when they differ)
%
% OUTPUT:
%    D:          1 x `m*(m-1)/2` row vector of distances in the order
%                (2,1), (3,1), ..., (m,1), (3,2), ..., (m,2), ..., (m,m-1),
%                the order used by `squareform`; single if `X` is single,
%                else double; `zeros(1, 0)` when `m < 2`
%
% NOTE:
%    Plain-MATLAB replacement for pdist (Statistics and Machine Learning
%    Toolbox); supported syntaxes are those listed under USAGE with the
%    distances 'euclidean' and 'jaccard'; any other distance (and any further
%    input such as a Minkowski exponent or 'CacheSize') raises an error naming
%    it; semantics: mathworks-semantics.md §9 (feature
%    20261103-120403-toolbox-free-replacements).
%    A pair in which either row contains NaN gives NaN (MathWorks: "NaN for
%    the built-in distance functions"); under 'jaccard' two all-zero rows give
%    0/0 = NaN, as in MATLAB (SciPy returns 0 there). The distances are
%    computed in double and converted to single for single input (MathWorks
%    computes single input in single, so single results may differ in the
%    last bits).
%
% EXAMPLE:
%
%    D = cobraPdist([0 0; 3 4; 6 8])          % [5 10 5]
%    D = cobraPdist([1 0 2; 1 3 0], 'jaccard') % 2/3
%
% .. Authors:
%     - Generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

if ~exist('distance', 'var') || isempty(distance)
    distance = 'euclidean';
end
if ~(ischar(distance) || (isstring(distance) && isscalar(distance)))
    error('cobraPdist:unsupportedDistance', 'cobraPdist: unsupported distance of class ''%s'' (only ''euclidean'' and ''jaccard'' are supported).', class(distance));
end
distance = lower(char(distance));
if ~isempty(varargin)
    extraName = 'distance parameter';
    if ischar(varargin{1}) || isstring(varargin{1})
        extraName = char(varargin{1});
    end
    error('cobraPdist:unsupportedOption', 'cobraPdist: unsupported option ''%s'' after the distance ''%s'' (distance parameters and options are not supported).', extraName, distance);
end
if ~ismember(distance, {'euclidean', 'jaccard'})
    error('cobraPdist:unsupportedDistance', 'cobraPdist: unsupported distance ''%s'' (only ''euclidean'' and ''jaccard'' are supported).', distance);
end
if ~(isnumeric(X) || islogical(X)) || ~isreal(X) || ~ismatrix(X)
    error('cobraPdist:invalidInput', 'cobraPdist: X must be a real numeric or logical matrix.');
end

isSingle = isa(X, 'single');
X = double(X);
nObservations = size(X, 1);
D = zeros(1, nObservations * (nObservations - 1) / 2);
hasNaN = any(isnan(X), 2);

% pairs (i, j) with i > j, column-major over the lower triangle
last = 0;
for j = 1:nObservations - 1
    others = X(j + 1:nObservations, :);
    if strcmp(distance, 'euclidean')
        d = sqrt(sum((others - X(j, :)) .^ 2, 2));
    else
        isNonzero = others ~= 0 | X(j, :) ~= 0;
        isDifferent = others ~= X(j, :) & isNonzero;
        % 0/0 = NaN for two all-zero rows, as in MATLAB
        d = sum(isDifferent, 2) ./ sum(isNonzero, 2);
    end
    d(hasNaN(j + 1:nObservations) | hasNaN(j)) = NaN;
    D(last + 1:last + nObservations - j) = d';
    last = last + nObservations - j;
end

if isSingle
    D = single(D);
end
end
