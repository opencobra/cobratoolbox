function [Y, e] = cobraCmdscale(D, varargin)
% Classical multidimensional scaling without the Statistics and Machine
% Learning Toolbox
%
% USAGE:
%
%    [Y, e] = cobraCmdscale(D)
%
% INPUT:
%    D:        n x n distance matrix (symmetric, non-negative, zero
%              diagonal), n x n similarity matrix (ones on the diagonal, all
%              values <= 1; converted to distances sqrt(1 - D)), or a row
%              vector of length n*(n-1)/2 as returned by pdist / cobraPdist
%
% OUTPUTS:
%    Y:        n x p configuration, p = number of positive eigenvalues of
%              the doubly centred matrix (Y = zeros(n, 1) when there is none)
%    e:        n x 1 eigenvalues of the doubly centred matrix, in
%              descending order (negative values included)
%
% EXAMPLE:
%
%    D = cobraPdist([0 0; 3 0; 0 4], 'euclidean');
%    [Y, e] = cobraCmdscale(D);   % Y reproduces the distances in D
%
% NOTE:
%    Plain-MATLAB replacement for cmdscale (Statistics and Machine Learning
%    Toolbox); supported syntax: [Y, e] = cobraCmdscale(D); the argument p
%    of cmdscale raises an error naming it; semantics:
%    specs/20261111-152503-toolbox-free-remaining/mathworks-semantics.md,
%    G1 section 13. Algorithm (Torgerson 1952; Gower 1966), as in R14:
%    B = -P*(D.^2)*P/2 with P = I - ones(n)/n, symmetrised; eig(B) sorted in
%    descending order; eigenvalues greater than max(|e|)*eps^(3/4) are kept
%    and Y = V*diag(sqrt(e)). Eigenvectors carry the sign returned by eig,
%    as in MathWorks; another eigen-solver may flip the sign of a column,
%    which leaves the distances unchanged. Computation is in double. NaN in
%    D raises an error.
%
% .. Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

if ~isempty(varargin)
    error('COBRA:cobraCmdscale:unsupportedOption', ...
        'cobraCmdscale: unsupported option ''p'' (only the syntax cobraCmdscale(D) is supported).');
end
if ~(isnumeric(D) || islogical(D)) || ~isreal(D)
    error('COBRA:cobraCmdscale:invalidInput', 'cobraCmdscale: D must be a real numeric matrix or pdist vector.');
end
D = double(D);
if any(isnan(D(:)))
    error('COBRA:cobraCmdscale:invalidInput', 'cobraCmdscale: D must not contain NaN.');
end

if isvector(D) && ~isscalar(D) || isempty(D)
    % pdist row vector (upper triangle, column by column of the lower triangle)
    m = numel(D);
    n = (1 + sqrt(1 + 8 * m)) / 2;
    if n ~= round(n)
        error('COBRA:cobraCmdscale:invalidInput', 'cobraCmdscale: the length of a distance vector must be n*(n-1)/2.');
    end
    full = zeros(n);
    full(tril(true(n), -1)) = D;
    D = full + full';
else
    n = size(D, 1);
    if size(D, 2) ~= n
        error('COBRA:cobraCmdscale:invalidInput', 'cobraCmdscale: D must be a square matrix or a pdist vector.');
    end
    tolerance = 10 * eps(max(abs(D(:))));
    if any(abs(D - D') > tolerance, 'all')
        error('COBRA:cobraCmdscale:invalidInput', 'cobraCmdscale: D must be symmetric.');
    end
    if all(diag(D) == 1) && all(D(:) <= 1)
        % similarity matrix
        D = sqrt(1 - D);
    elseif any(diag(D) ~= 0)
        error('COBRA:cobraCmdscale:invalidInput', 'cobraCmdscale: D must have a zero diagonal (or ones for a similarity matrix).');
    end
end
if any(D(:) < 0)
    error('COBRA:cobraCmdscale:invalidInput', 'cobraCmdscale: D must be non-negative.');
end

centering = eye(n) - ones(n) / n;
B = -centering * (D .^ 2) * centering / 2;
B = (B + B') / 2;
[V, E] = eig(B);
% ascending sort reversed (as R14): tied eigenvalues keep the reversed order of eig
[e, order] = sort(diag(E));
e = flipud(e);
order = flipud(order);
V = V(:, order);
isKept = e > max(abs(e)) * eps ^ (3 / 4);
if any(isKept)
    Y = V(:, isKept) * diag(sqrt(e(isKept)));
else
    Y = zeros(n, 1);
end
end
