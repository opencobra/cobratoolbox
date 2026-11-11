function [h, p, ks2stat] = cobraKstest2(x1, x2, varargin)
% Two-sample Kolmogorov-Smirnov test without the Statistics and Machine
% Learning Toolbox
%
% USAGE:
%
%    [h, p, ks2stat] = cobraKstest2(x1, x2)
%    [h, p, ks2stat] = cobraKstest2(x1, x2, alpha, tail)
%    [h, p, ks2stat] = cobraKstest2(x1, x2, 'Alpha', alpha, 'Tail', tail)
%
% INPUTS:
%    x1, x2:   real numeric vectors (row or column); NaN values are removed
%
% OPTIONAL INPUTS:
%    alpha:    significance level for `h` (default 0.05); positional or the
%              'Alpha' name-value pair
%    tail:     'unequal' (default, two-sided), 'larger' (statistic
%              max(F1 - F2)) or 'smaller' (max(F2 - F1)), or 0, 1, -1;
%              positional or the 'Tail' name-value pair
%
% OUTPUTS:
%    h:        logical, true when p <= alpha
%    p:        asymptotic p-value
%    ks2stat:  the test statistic
%
% EXAMPLE:
%
%    [h, p, k] = cobraKstest2(0:49, 14:63, 'Tail', 'smaller')   % p = 0.0158, k = 0.28
%
% NOTE:
%    Plain-MATLAB replacement for kstest2 (Statistics and Machine Learning
%    Toolbox); supported syntaxes are those listed under USAGE (the
%    positional form is the one of compareTwoSamplesStat); any other option
%    raises an error naming it; semantics:
%    specs/20261111-152503-toolbox-free-remaining/mathworks-semantics.md,
%    G1 section 5. F1 and F2 are the empirical distribution functions
%    evaluated at the pooled sample values. With n = n1*n2/(n1 + n2) and
%    lambda = max((sqrt(n) + 0.12 + 0.11/sqrt(n))*D, 0), the p-value is
%    exp(-2*lambda^2) for one-sided tests and
%    2*sum_{j=1}^{101} (-1)^(j-1)*exp(-2*lambda^2*j^2), clipped to [0, 1],
%    for the two-sided test (Stephens' modified asymptotic formula, which
%    reproduces the MathWorks documentation example; R14 used the same).
%    An empty sample after NaN removal raises an error.
%
% .. Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

alpha = 0.05;
tail = 'unequal';
if ~isempty(varargin) && ~(ischar(varargin{1}) || isstring(varargin{1}))
    % positional form: (x1, x2, alpha, tail)
    if numel(varargin) > 2
        error('COBRA:cobraKstest2:unsupportedOption', ...
            'cobraKstest2: unsupported option ''%s'' (positional form is cobraKstest2(x1, x2, alpha, tail)).', describeValue(varargin{3}));
    end
    if ~isempty(varargin{1})
        alpha = varargin{1};
    end
    if numel(varargin) == 2 && ~isempty(varargin{2})
        tail = varargin{2};
    end
else
    if mod(numel(varargin), 2) ~= 0
        error('COBRA:cobraKstest2:unsupportedOption', ...
            'cobraKstest2: unsupported option ''%s'' (options are name-value pairs ''Alpha'' and ''Tail'').', describeValue(varargin{end}));
    end
    for k = 1:2:numel(varargin)
        switch lower(char(varargin{k}))
            case 'alpha'
                alpha = varargin{k + 1};
            case 'tail'
                tail = varargin{k + 1};
            otherwise
                error('COBRA:cobraKstest2:unsupportedOption', ...
                    'cobraKstest2: unsupported option ''%s'' (options are name-value pairs ''Alpha'' and ''Tail'').', char(varargin{k}));
        end
    end
end
tail = normalizeTail(tail);

x1 = double(x1(:));
x2 = double(x2(:));
x1 = x1(~isnan(x1));
x2 = x2(~isnan(x2));
n1 = numel(x1);
n2 = numel(x2);
if n1 == 0 || n2 == 0
    error('COBRA:cobraKstest2:emptySample', 'cobraKstest2: each sample needs at least one value that is not NaN.');
end

% empirical distribution functions at the pooled values: with edges [v; Inf], bin j counts
% the values in [v_j, v_j+1), so the cumulative count is the number of values <= v_j
pooledValues = unique([x1; x2]);
edges = [pooledValues; Inf];
F1 = cumsum(histcounts(x1, edges))' / n1;
F2 = cumsum(histcounts(x2, edges))' / n2;
switch tail
    case 'unequal'
        ks2stat = max(abs(F1 - F2));
    case 'larger'
        ks2stat = max(F1 - F2);
    case 'smaller'
        ks2stat = max(F2 - F1);
end

n = n1 * n2 / (n1 + n2);
lambda = max((sqrt(n) + 0.12 + 0.11 / sqrt(n)) * ks2stat, 0);
if strcmp(tail, 'unequal')
    j = (1:101)';
    p = 2 * sum((-1) .^ (j - 1) .* exp(-2 * lambda ^ 2 * j .^ 2));
    p = min(max(p, 0), 1);
else
    p = exp(-2 * lambda ^ 2);
end
h = p <= alpha;
end

function tail = normalizeTail(tail)
% Maps the tail argument to 'unequal', 'larger' or 'smaller'
if isnumeric(tail) && isscalar(tail) && any(tail == [0 1 -1])
    names = {'smaller', 'unequal', 'larger'};
    tail = names{tail + 2};
elseif (ischar(tail) || isstring(tail)) && any(strcmpi(char(tail), {'unequal', 'larger', 'smaller'}))
    tail = lower(char(tail));
else
    error('COBRA:cobraKstest2:unsupportedOption', ...
        'cobraKstest2: unsupported option ''Tail'' value ''%s'' (use ''unequal'', ''larger'' or ''smaller'').', describeValue(tail));
end
end

function text = describeValue(value)
% Text naming an option or value in an error message
if ischar(value) || isstring(value)
    text = char(value);
elseif isnumeric(value) && isscalar(value)
    text = num2str(value);
else
    text = class(value);
end
end
