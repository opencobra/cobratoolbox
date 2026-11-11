function [f, xi, bw] = cobraKsdensity(x, varargin)
% Kernel density estimate (default settings of ksdensity) without the
% Statistics and Machine Learning Toolbox
%
% USAGE:
%
%    [f, xi, bw] = cobraKsdensity(x)
%
% INPUT:
%    x:        real numeric vector of data; NaN values are removed
%
% OUTPUTS:
%    f:        1 x 100 row of density estimates at the points `xi`
%    xi:       1 x 100 row of equally spaced evaluation points from
%              min(x) - 3*bw to max(x) + 3*bw
%    bw:       bandwidth of the normal kernel
%
% EXAMPLE:
%
%    rng('default');
%    x = [randn(30, 1); 5 + randn(30, 1)];
%    [f, xi, bw] = cobraKsdensity(x);   % bw = 1.5141
%
% NOTE:
%    Plain-MATLAB replacement for ksdensity (Statistics and Machine Learning
%    Toolbox) called with one input (normal kernel, unbounded support, 100
%    points, the 'normal-approx' bandwidth); any further argument (points,
%    name-value options) raises an error naming it; semantics:
%    specs/20261111-152503-toolbox-free-remaining/mathworks-semantics.md,
%    G1 section 12. Bandwidth (Silverman's rule with a robust scale, Bowman
%    and Azzalini 1997): sigma = median(|x - median(x)|)/0.6745; if
%    sigma <= 0, sigma = max(x) - min(x); bw = sigma*(4/(3n))^(1/5) when
%    sigma > 0, otherwise bw = 1. Points: linspace(min(x) - 3*bw,
%    max(x) + 3*bw, 100). Density: f(xi) = mean over i of
%    phi((xi - x_i)/bw)/bw with the standard normal density phi, where for
%    more than 300 observations only |xi - x_i| <= 4*bw contribute (the
%    kernel cut-off of R14 for large samples; current release UNCONFIRMED). The
%    bandwidth matches the MathWorks documentation example; the grid rule is
%    the R14 rule (current release UNCONFIRMED, settled by the parity
%    section of the test).
%
% .. Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

if ~isempty(varargin)
    option = varargin{1};
    if ischar(option) || isstring(option)
        optionName = char(option);
    else
        optionName = 'pts';
    end
    error('COBRA:cobraKsdensity:unsupportedOption', ...
        'cobraKsdensity: unsupported option ''%s'' (only the default call cobraKsdensity(x) is supported).', optionName);
end
if ~(isnumeric(x) || islogical(x)) || ~isreal(x) || ~isvector(x)
    error('COBRA:cobraKsdensity:invalidInput', 'cobraKsdensity: x must be a real numeric vector.');
end

x = double(x(:));
x = x(~isnan(x));
n = numel(x);
if n == 0
    error('COBRA:cobraKsdensity:invalidInput', 'cobraKsdensity: x must contain at least one value that is not NaN.');
end
sigma = median(abs(x - median(x))) / 0.6745;
if sigma <= 0
    sigma = max(x) - min(x);
end
if sigma > 0
    bw = sigma * (4 / (3 * n)) ^ (1 / 5);
else
    bw = 1;
end
xi = linspace(min(x) - 3 * bw, max(x) + 3 * bw, 100);

% sum of the kernels; when n*100 > 3e4, only the observations within 4 bandwidths of a point
% contribute (the kernel cut-off of the MathWorks computation for large samples, as in R14);
% blocks of observations bound the memory
f = zeros(1, 100);
isWindowed = n * 100 > 3e4;
blockSize = 10000;
for first = 1:blockSize:n
    block = x(first:min(first + blockSize - 1, n));
    z = (xi - block) / bw;
    kernel = exp(-0.5 * z .^ 2);
    if isWindowed
        kernel(abs(z) > 4) = 0;
    end
    f = f + sum(kernel, 1);
end
f = f / (n * bw * sqrt(2 * pi));
end
