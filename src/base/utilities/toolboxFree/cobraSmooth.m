function yy = cobraSmooth(varargin)
% Moving-average or lowess smoothing of a data vector, without the Curve
% Fitting Toolbox.
%
% USAGE:
%
%    yy = cobraSmooth(y)
%    yy = cobraSmooth(y, span)
%    yy = cobraSmooth(x, y)
%    yy = cobraSmooth(x, y, span)
%    yy = cobraSmooth(..., method)
%
% INPUT:
%    y:         numeric vector of data
%
% OPTIONAL INPUTS:
%    x:         numeric vector of the same length as `y` (default: 1:numel(y));
%               the data are sorted by `x` before smoothing
%    span:      number of points (default 5; [] means the default), or a
%               fraction of numel(y) in (0, 1), rounded up. A scalar second
%               input is always the span: cobraSmooth(4, 3) smooths y = 4.
%    method:    'moving' or 'lowess'. Without a method, 'moving' is used when
%               `x` is uniformly spaced and `y` has no NaN, otherwise 'lowess'.
%
% OUTPUT:
%    yy:        column vector of the class of `y`, in the original order of `y`
%
% EXAMPLE:
%
%    yy = cobraSmooth([2 7 1 8 2 8])   % [2; 3.3333; 4; 5.2; 6; 8]
%
% NOTE:
%    Plain-MATLAB replacement for smooth (Curve Fitting Toolbox); supported
%    syntaxes: smooth(y), smooth(y, span), smooth(x, y), smooth(x, y, span),
%    each optionally followed by 'moving' or 'lowess'; semantics:
%    mathworks-semantics.md section 15 and the MathWorks pages
%    https://www.mathworks.com/help/curvefit/smooth.html and
%    https://www.mathworks.com/help/curvefit/smoothing-data.html.
%
%    Choice of method: `x` is uniform when every second difference of `x`, in
%    the order given (not sorted), is at most eps * max(abs(x(1)), abs(x(end)))
%    (recall of MathWorks source; UNCONFIRMED). Unsorted x is therefore not
%    uniform.
%
%    'moving': the span is limited to numel(y) and an even span is reduced by
%    1. Point i is the mean of the span points centred on it; near the ends the
%    window shrinks so that it stays centred and odd (yy(1) = y(1),
%    yy(2) = mean(y(1:3)), ...). Points with equal x form one group: the group
%    is widened on both sides by ceil((span - groupSize)/2) points (fewer at the
%    ends), then further to include every point tied with the window's end
%    points, and every point of the group gets the mean of that window (recall
%    of MathWorks source; UNCONFIRMED). MathWorks' 'moving' computes around NaN
%    in y (a ratio of moving sums); cobraSmooth raises an error instead.
%
%    'lowess': a straight line is fitted by weighted least squares to the span
%    points nearest to x(i), with tricube weights (1 - (|x - x(i)| / d)^3)^3,
%    where d is the distance to the most distant point in the window; yy(i) is
%    the line at x(i). The window does not shrink and is one-sided at the ends.
%    - Uniform x and no NaN in y (recall of MathWorks source; UNCONFIRMED): the
%      span is limited to numel(y) and made odd with 2*floor(span/2) + 1; an
%      interior point uses the span points centred on it and d = (span-1)/2
%      spacings; for the j-th point from either end the window is the span-1
%      points at that end and d = span - j spacings (the distance to the
%      span-th point, which may lie beyond the data).
%    - Otherwise (UNCONFIRMED choices): points with NaN in y are left out of the
%      windows but get a smoothed value; every point as near as the span-th
%      nearest is included; the span is used as given.
%    - Span 1 returns y unchanged. If every weight is below eps the weights are
%      set to 1; if the line is not determined (one point with nonzero weight,
%      or equal x), yy(i) is the weighted mean (UNCONFIRMED).
%
%    The rounding up of a fractional span is UNCONFIRMED. NaN in `x`, and the
%    methods 'loess', 'sgolay', 'rlowess' and 'rloess', raise an error.
%
% .. Author: generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

% split off the method name
args = varargin;
isText = cellfun(@(a) ischar(a) || isstring(a), args);
method = '';
if any(isText)
    methodPosition = find(isText, 1);
    method = lower(char(args{methodPosition}));
    if ~any(strcmp(method, {'moving', 'lowess'}))
        error('cobraSmooth:unsupportedMethod', ...
            'cobraSmooth: the method ''%s'' is not supported; only ''moving'' and ''lowess'' are.', method);
    end
    if methodPosition < numel(args)
        error('cobraSmooth:tooManyInputs', 'cobraSmooth: no input may follow the method ''%s''.', method);
    end
    args = args(1:methodPosition - 1);
end

% numeric inputs: y | y, span | x, y | x, y, span
x = [];
span = [];
switch numel(args)
    case 1
        y = args{1};
    case 2
        if isscalar(args{2}) || isempty(args{2})
            y = args{1};
            span = args{2};
        else
            x = args{1};
            y = args{2};
        end
    case 3
        x = args{1};
        y = args{2};
        span = args{3};
    otherwise
        error('cobraSmooth:badInputs', 'cobraSmooth: expected 1 to 3 numeric inputs.');
end
if isempty(span)
    span = 5;
end
y = y(:);
nPoints = numel(y);
if nPoints == 0
    yy = zeros(0, 1, 'like', y);
    return
end
if isempty(x)
    x = (1:nPoints)';
end
x = x(:);
if numel(x) ~= nPoints
    error('cobraSmooth:lengthMismatch', 'cobraSmooth: x and y must have the same length.');
end
if ~isscalar(span) || ~(span > 0)
    error('cobraSmooth:badSpan', 'cobraSmooth: span must be a positive scalar.');
end
if any(isnan(x))
    error('cobraSmooth:nanX', 'cobraSmooth: NaN in x is not supported.');
end

% uniform x (judged in the order given) and no NaN in y
isUniform = ~any(isnan(y)) && ~any(abs(diff(x, 2)) > eps * max(abs(x([1 end]))));
if isempty(method)
    if isUniform
        method = 'moving';
    else
        method = 'lowess';
    end
end

% sort by x
[x, order] = sort(x);
y = y(order);

% span in points
if span < 1
    span = ceil(span * nPoints);
end
span = floor(span);

if strcmp(method, 'moving')
    if any(isnan(y))
        error('cobraSmooth:nanData', 'cobraSmooth: NaN in the data is not supported with ''moving''.');
    end
    smoothed = movingAverage(x, y, span);
else
    if isUniform
        span = min(span, nPoints);
        span = 2 * floor(span / 2) + 1;
    end
    if span == 1
        smoothed = y;
    elseif isUniform
        smoothed = uniformLowess(y, span);
    else
        smoothed = lowessSmooth(x, y, span);
    end
end

% back to the original order
yy = zeros(nPoints, 1, 'like', y);
yy(order) = smoothed;
end

function smoothed = movingAverage(x, y, span)
% centred moving average over an odd window that shrinks at the ends; points
% with equal x share the mean of a window widened to whole groups of ties
nPoints = numel(y);
span = min(span, nPoints);
width = span - 1 + mod(span, 2);
smoothed = zeros(nPoints, 1, 'like', y);
first = 1;
while first <= nPoints
    last = first;
    while last < nPoints && x(last + 1) == x(first)
        last = last + 1;
    end
    halfWidth = ceil(max(0, (width - (last - first + 1)) / 2));
    halfWidth = min([halfWidth, first - 1, nPoints - last]);
    left = first - halfWidth;
    while left > 1 && x(left - 1) == x(left)
        left = left - 1;
    end
    right = last + halfWidth;
    while right < nPoints && x(right + 1) == x(right)
        right = right + 1;
    end
    smoothed(first:last) = sum(y(left:right)) / (right - left + 1);
    first = last + 1;
end
end

function smoothed = uniformLowess(y, span)
% lowess on uniformly spaced data, in index units, with a fixed odd span
nPoints = numel(y);
halfWidth = (span - 1) / 2;
smoothed = zeros(nPoints, 1, 'like', y);
for i = 1:nPoints
    if i > halfWidth && i + halfWidth <= nPoints
        window = i - halfWidth:i + halfWidth;
        maxDistance = halfWidth;
    elseif i <= halfWidth
        window = 1:span - 1;
        maxDistance = span - i;
    else
        window = nPoints - span + 2:nPoints;
        maxDistance = i - (nPoints - span + 1);
    end
    offsets = (window - i)';
    weights = (1 - (abs(offsets) / maxDistance) .^ 3) .^ 3;
    smoothed(i) = localLine(offsets, y(window), weights);
end
end

function smoothed = lowessSmooth(x, y, span)
% lowess on sorted x: the span nearest non-NaN points (and ties), found with a
% window that slides along the sorted data, O(numel(y) * span)
isData = ~isnan(y);
xData = x(isData);
yData = y(isData);
nData = numel(xData);
nPoints = numel(y);
smoothed = NaN(nPoints, 1, 'like', y);
if nData == 0
    return
end
nNearest = min(span, nData);
low = 1;
for i = 1:nPoints
    % move the block of nNearest points right while the next point is as near or nearer
    % (moving on ties keeps a valid block and cannot get stuck on repeated x)
    while low + nNearest <= nData && abs(xData(low + nNearest) - x(i)) <= abs(x(i) - xData(low))
        low = low + 1;
    end
    left = low;
    right = low + nNearest - 1;
    reach = max(abs(x(i) - xData(left)), abs(xData(right) - x(i)));
    % add the points as near as the farthest one in the block
    while left > 1 && abs(x(i) - xData(left - 1)) <= reach
        left = left - 1;
    end
    while right < nData && abs(xData(right + 1) - x(i)) <= reach
        right = right + 1;
    end
    offsets = xData(left:right) - x(i);
    scaled = abs(offsets);
    if reach > 0
        scaled = scaled / reach;
    end
    weights = (1 - scaled .^ 3) .^ 3;
    smoothed(i) = localLine(offsets, yData(left:right), weights);
end
end

function value = localLine(offsets, yWindow, weights)
% weighted least-squares line through the window, evaluated at offset 0
if all(weights < eps)
    weights(:) = 1;
end
meanX = sum(weights .* offsets) / sum(weights);
meanY = sum(weights .* yWindow) / sum(weights);
if numel(unique(offsets(weights > 0))) < 2
    % the line is not determined (fewer than two distinct x with nonzero weight)
    value = meanY;
else
    centred = offsets - meanX;
    slope = sum(weights .* centred .* (yWindow - meanY)) / sum(weights .* centred .^ 2);
    value = meanY - slope * meanX;
end
end
