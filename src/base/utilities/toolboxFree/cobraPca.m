function [coeff, score, latent, tsquared, explained, mu] = cobraPca(X, varargin)
% Principal component analysis without the Statistics and Machine Learning
% Toolbox
%
% USAGE:
%
%    coeff = cobraPca(X)
%    [coeff, score, latent, tsquared, explained, mu] = cobraPca(X)
%    [...] = cobraPca(X, 'Centered', centered, 'Algorithm', algorithm)
%
% INPUT:
%    X:            `n` x `p` real numeric matrix without NaN; rows are
%                  observations, columns are variables
%
% OPTIONAL INPUTS:
%    'Centered':   name-value pair; true/'on' (default) subtracts the column
%                  means, false/'off' does not
%    'Algorithm':  name-value pair; 'svd' (default) or 'als' (accepted for
%                  complete data and computed by the SVD, see NOTE)
%
% OUTPUTS:
%    coeff:        `p` x `k` principal component coefficients (unit columns,
%                  descending variance)
%    score:        `n` x `k` principal component scores, `X0 = score*coeff'`
%                  for the (centred or not) data `X0`
%    latent:       `k` x 1 component variances, the squared singular values
%                  of `X0` divided by `d`
%    tsquared:     `n` x 1 Hotelling's T-squared statistic of each
%                  observation over all components
%    explained:    `k` x 1 percentage of the total variance explained by
%                  each component
%    mu:           1 x `p` column means (zeros when not centred)
%
% NOTE:
%    Plain-MATLAB replacement for pca (Statistics and Machine Learning
%    Toolbox); supported syntaxes are those listed under USAGE with the
%    default 'Economy' true; any other option ('NumComponents', 'Rows',
%    'Weights', 'VariableWeights', 'Economy', 'Coeff0', 'Score0',
%    'Options', 'Algorithm' 'eig') and NaN in `X` raise an error naming
%    them; semantics: mathworks-semantics.md §12 (feature
%    20261103-120403-toolbox-free-replacements).
%
%    * Degrees of freedom `d = n - 1` when centred and `d = n` otherwise
%      (MathWorks doc); `k = min(d, p)` components are returned (Economy).
%    * Sign convention (MathWorks doc): the element of largest magnitude in
%      each column of `coeff` is positive (the first one on a tie); `score`
%      columns flip with it.
%    * `explained = 100*latent/sum(latent)`.
%    * Outputs are double (single input is converted to double).
%    * `tsquared = sum(score(:,1:q).^2 ./ latent(1:q)', 2)` over the `q`
%      components with `latent > max(d, p)*eps(latent(1))` (components
%      orthogonal to the data are ignored); `q = 0` (all zeros) when
%      `d <= 1`; when `q < min(d, p)` warning `cobraPca:ColRankDefX` is
%      issued. These rules follow a reviewer's recollection of pca's
%      tsquared subfunction and are UNCONFIRMED (they only matter for
%      rank-deficient data or `d <= 1`).
%    * 'Algorithm', 'als': MathWorks runs alternating least squares from
%      random starting values (results depend on the rng state and agree
%      with the SVD within the ALS tolerance, about 1e-6, for complete
%      data). cobraPca returns the SVD solution, i.e. the converged ALS
%      answer, so it can differ from MathWorks' 'als' output by that
%      tolerance; data with NaN (the purpose of ALS) are not supported.
%
% EXAMPLE:
%
%    [coeff, score, ~, ~, explained] = cobraPca(X, 'Centered', false, 'Algorithm', 'als');
%
% .. Authors:
%     - Generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

isCentered = true;
if mod(numel(varargin), 2) ~= 0
    error('cobraPca:invalidOptions', 'cobraPca: options must be name-value pairs.');
end
for k = 1:2:numel(varargin)
    name = varargin{k};
    value = varargin{k + 1};
    if ~(ischar(name) || (isstring(name) && isscalar(name)))
        error('cobraPca:unsupportedOption', 'cobraPca: unsupported option of class ''%s'' (supported: ''Centered'', ''Algorithm'').', class(name));
    end
    switch lower(char(name))
        case 'centered'
            isCentered = parseOnOff(value);
        case 'algorithm'
            valueText = class(value);
            if ischar(value) || (isstring(value) && isscalar(value))
                valueText = char(value);
            end
            if ~ismember(lower(valueText), {'svd', 'als'})
                error('cobraPca:unsupportedAlgorithm', 'cobraPca: unsupported value ''%s'' for option ''Algorithm'' (supported: ''svd'', ''als'').', valueText);
            end
        otherwise
            error('cobraPca:unsupportedOption', 'cobraPca: unsupported option ''%s'' (supported: ''Centered'', ''Algorithm'').', char(name));
    end
end
if ~isnumeric(X) || ~isreal(X) || ~ismatrix(X)
    error('cobraPca:invalidInput', 'cobraPca: X must be a real numeric matrix.');
end
if any(isnan(X(:)))
    error('cobraPca:missingData', 'cobraPca: X contains NaN; missing data (''Rows'' and ALS imputation) is not supported.');
end

X = double(X);
[nObs, nVars] = size(X);
if isCentered
    mu = mean(X, 1);
    dof = nObs - 1;
else
    mu = zeros(1, nVars);
    dof = nObs;
end
centredX = X - mu;
[U, S, V] = svd(centredX, 'econ');
singularValues = diag(S);
nComponents = min(dof, nVars);

coeff = V(:, 1:nComponents);
score = U(:, 1:nComponents) .* singularValues(1:nComponents, 1)';
% sign convention: the largest-magnitude element of each column is positive
[~, largest] = max(abs(coeff), [], 1);
flip = reshape(sign(coeff(sub2ind(size(coeff), largest, 1:nComponents))), 1, nComponents);
flip(flip == 0) = 1;
coeff = coeff .* flip;
score = score .* flip;

latent = singularValues(1:nComponents, 1) .^ 2 / dof;
explained = 100 * latent / sum(latent);

tsquared = zeros(nObs, 1);
if nargout > 3 && dof > 1
    % components orthogonal to the data (numerically zero variance) are ignored
    nUsed = sum(latent > max(dof, nVars) * eps(latent(1)));
    if nUsed < nComponents
        warning('cobraPca:ColRankDefX', 'Columns of X are linearly dependent to within machine precision. Using only the first %d components to compute TSQUARED.', nUsed);
    end
    tsquared = sum(score(:, 1:nUsed) .^ 2 ./ latent(1:nUsed)', 2);
end
end

function isOn = parseOnOff(value)
% logical/numeric scalar or 'on'/'off'
if (islogical(value) || isnumeric(value)) && isscalar(value)
    isOn = logical(value);
elseif (ischar(value) || (isstring(value) && isscalar(value))) && ismember(lower(char(value)), {'on', 'off'})
    isOn = strcmpi(char(value), 'on');
else
    error('cobraPca:invalidCentered', 'cobraPca: the value of ''Centered'' must be true, false, ''on'' or ''off''.');
end
end
