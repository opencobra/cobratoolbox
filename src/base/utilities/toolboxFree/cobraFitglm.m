function mdl = cobraFitglm(tbl, formula, varargin)
% Fits a generalized linear model (normal or binomial) to table data, without
% the Statistics and Machine Learning Toolbox
%
% USAGE:
%
%    mdl = cobraFitglm(tbl, formula)
%    mdl = cobraFitglm(tbl, formula, 'Distribution', distribution, 'LikelihoodPenalty', penalty)
%
% INPUTS:
%    tbl:          table with the response and the predictors
%    formula:      model formula in Wilkinson notation, for example 'y ~ x + g' (see
%                  cobraParseModelFormula; random-effects terms are not supported)
%
% OPTIONAL INPUTS (name-value pairs, names case-insensitive):
%    'Distribution':       'normal' (default; identity link) or 'binomial' (logit link;
%                          response 0/1 or logical)
%    'LikelihoodPenalty':  'none' (default) or 'jeffreys-prior' (Firth's penalized
%                          likelihood)
%
% OUTPUT:
%    mdl:          cobraGeneralizedLinearModel object with the properties of a MathWorks
%                  GeneralizedLinearModel used by the toolbox (Coefficients, CoefficientNames,
%                  CoefficientCovariance, NumObservations, DFE, Rsquared, Deviance,
%                  LogLikelihood, Dispersion, ...) and the methods coefCI, predict and disp
%
% EXAMPLE:
%
%    load patients
%    tbl = table(Age, Weight, Gender, Smoker);
%    mdl = cobraFitglm(tbl, 'Smoker ~ Age*Weight*Gender - Age:Weight:Gender', 'Distribution', 'binomial');
%
% NOTE:
%    Plain-MATLAB replacement for fitglm (Statistics and Machine Learning Toolbox) for table
%    input with the options listed above; any other option raises an error naming it;
%    semantics: specs/20261111-152503-toolbox-free-remaining/mathworks-semantics.md, G3
%    section 2. Rows with a missing value in a formula variable are excluded. Estimation:
%    iteratively reweighted least squares (McCullagh and Nelder 1989) through the QR
%    decomposition, starting from mu = (y + 0.5)/2 (binomial) or mu = y (normal), stopping
%    when every |change of b| <= 1e-6*max(sqrt(eps), |b|), at most 100 iterations (warning
%    COBRA:cobraFitglm:IterationLimit). Firth's penalty (Firth 1993; Heinze and Schemper
%    2002): Newton iterations on the modified score X'*(y - mu + h.*(0.5 - mu)) with step
%    halving on the penalized log-likelihood (at most 1000 iterations: the iteration converges
%    linearly when an observation has a leverage near 1); for the normal distribution the penalty does
%    not depend on the coefficients, so the estimates are those of least squares
%    (UNCONFIRMED against MathWorks, as are Firth's standard-error conventions: here the
%    inverse Fisher information at the estimate). Without the penalty, fitted binomial
%    probabilities within eps of 0 or 1 raise the warning COBRA:cobraFitglm:PerfectSeparation.
%    A rank-deficient design (pivoted QR) raises COBRA:cobraFitglm:RankDeficient; the
%    dependent coefficients are 0 with SE 0 and NaN statistics, and DFE = N - rank.
%    Coefficient statistics: SE = sqrt(diag(dispersion*inv(X'WX))), tStat = Estimate/SE,
%    pValue from t(DFE) when the dispersion is estimated (normal: SSE/DFE) and from the
%    standard normal distribution otherwise (binomial, dispersion 1).
%
% .. Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

distribution = 'normal';
penalty = 'none';
if mod(numel(varargin), 2) ~= 0
    error('COBRA:cobraFitglm:unsupportedOption', 'cobraFitglm: unsupported option ''%s'' (options are name-value pairs).', describeValue(varargin{end}));
end
for k = 1:2:numel(varargin)
    switch lower(describeValue(varargin{k}))
        case 'distribution'
            distribution = lower(describeValue(varargin{k + 1}));
            if ~any(strcmp(distribution, {'normal', 'binomial'}))
                error('COBRA:cobraFitglm:unsupportedOption', ...
                    'cobraFitglm: unsupported option ''Distribution'' value ''%s'' (use ''normal'' or ''binomial'').', distribution);
            end
        case 'likelihoodpenalty'
            penalty = lower(describeValue(varargin{k + 1}));
            if ~any(strcmp(penalty, {'none', 'jeffreys-prior'}))
                error('COBRA:cobraFitglm:unsupportedOption', ...
                    'cobraFitglm: unsupported option ''LikelihoodPenalty'' value ''%s'' (use ''none'' or ''jeffreys-prior'').', penalty);
            end
        otherwise
            error('COBRA:cobraFitglm:unsupportedOption', 'cobraFitglm: unsupported option ''%s''.', describeValue(varargin{k}));
    end
end
if ~istable(tbl)
    error('COBRA:cobraFitglm:unsupportedOption', 'cobraFitglm: unsupported option ''matrix input'' (tbl must be a table).');
end
parsed = cobraParseModelFormula(formula, tbl.Properties.VariableNames);
if ~isempty(parsed.randomGroups)
    error('COBRA:cobraFitglm:unsupportedOption', ...
        'cobraFitglm: unsupported option ''random-effects term (1|%s)'' (mixed models need fitglme).', parsed.randomGroups{1});
end
design = cobraBuildModelDesign(tbl, parsed);
isUsed = ~design.isMissing;
X = design.X(isUsed, :);
y = design.y(isUsed);
isBinomial = strcmp(distribution, 'binomial');
if isBinomial && any(y ~= 0 & y ~= 1)
    error('COBRA:cobraFitglm:invalidInput', 'cobraFitglm: a binomial response must be 0 or 1 (or logical).');
end
nObservations = numel(y);
nCoefficients = size(X, 2);
if nObservations == 0
    error('COBRA:cobraFitglm:invalidInput', 'cobraFitglm: no observations without missing values.');
end

% independent columns (pivoted QR of the design; for the binomial model the weights do
% not change the column space)
[~, R, permutation] = qr(X, 0);
tolerance = max(size(X)) * eps(abs(R(1, 1)));
rankX = sum(abs(diag(R)) > tolerance);
kept = sort(permutation(1:rankX));
if rankX < nCoefficients
    warning('COBRA:cobraFitglm:RankDeficient', 'Regression design matrix is rank deficient to within machine precision.');
end
Xk = X(:, kept);

isFirth = strcmp(penalty, 'jeffreys-prior');
if ~isBinomial
    [Q, Rk] = qr(Xk, 0);
    bk = Rk \ (Q' * y);
    mu = Xk * bk;
    weights = ones(nObservations, 1);
elseif isFirth
    [bk, mu, weights] = firthLogistic(Xk, y);
else
    [bk, mu, weights] = irlsLogistic(Xk, y);
end

dfe = nObservations - rankX;
residual = y - mu;
sse = residual' * residual;
if isBinomial
    dispersion = 1;
    isDispersionEstimated = false;
    loglik = sum(y .* log(mu) + (1 - y) .* log(1 - mu));
    deviance = -2 * loglik;
    mu0 = mean(y);
    loglik0 = sum(y .* log(mu0) + (1 - y) .* log(1 - mu0));
    deviance0 = -2 * loglik0;
else
    dispersion = sse / dfe;
    isDispersionEstimated = true;
    deviance = sse;
    loglik = -nObservations / 2 * log(2 * pi * dispersion) - sse / (2 * dispersion);
    deviance0 = sum((y - mean(y)) .^ 2);
    loglik0 = -nObservations / 2 * log(2 * pi * dispersion) - deviance0 / (2 * dispersion);
end

% coefficient statistics (dependent coefficients: 0 with SE 0)
[~, Rw] = qr(sqrt(weights) .* Xk, 0);
RwInverse = Rw \ eye(rankX);
covarianceKept = dispersion * (RwInverse * RwInverse');
estimate = zeros(nCoefficients, 1);
estimate(kept) = bk;
covariance = zeros(nCoefficients);
covariance(kept, kept) = covarianceKept;
se = sqrt(diag(covariance));
tStat = estimate ./ se;
tStat(se == 0) = NaN;
if isDispersionEstimated
    pValue = 2 * cobraTcdf(-abs(tStat), dfe);
else
    pValue = 2 * cobraNormcdf(-abs(tStat));
end

sst = sum((y - mean(y)) .^ 2);
rsquared = struct('Ordinary', 1 - sse / sst, 'Adjusted', 1 - (sse / sst) * (nObservations - 1) / dfe, ...
    'LLR', 1 - loglik / loglik0, 'Deviance', 1 - deviance / deviance0, ...
    'AdjGeneralized', (1 - exp(2 * (loglik0 - loglik) / nObservations)) / (1 - exp(2 * loglik0 / nObservations)));

fittedResponse = NaN(height(tbl), 1);
fittedResponse(isUsed) = mu;
linearPredictor = NaN(height(tbl), 1);
linearPredictor(isUsed) = design.X(isUsed, :) * estimate;
termText = strjoin(cellfun(@(term) strjoin(term, ':'), parsed.terms, 'UniformOutput', false), ' + ');
if isempty(termText)
    formulaText = sprintf('%s ~ 1', parsed.response);
else
    formulaText = sprintf('%s ~ 1 + %s', parsed.response, termText);
end
coefficients = table(estimate, se, tStat, pValue, 'VariableNames', {'Estimate', 'SE', 'tStat', 'pValue'}, ...
    'RowNames', design.coefficientNames);
observationInfo = table(ones(height(tbl), 1), false(height(tbl), 1), design.isMissing, isUsed, ...
    'VariableNames', {'Weights', 'Excluded', 'Missing', 'Subset'});
distributionInfo = struct('Name', distribution);
if isBinomial
    distributionInfo.Name = 'Binomial';
else
    distributionInfo.Name = 'Normal';
end
values = struct('Coefficients', coefficients, 'CoefficientNames', {design.coefficientNames}, ...
    'CoefficientCovariance', covariance, 'NumCoefficients', nCoefficients, 'NumEstimatedCoefficients', rankX, ...
    'NumObservations', nObservations, 'DFE', dfe, 'Rsquared', rsquared, 'Deviance', deviance, ...
    'LogLikelihood', loglik, 'Dispersion', dispersion, 'DispersionEstimated', isDispersionEstimated, ...
    'Distribution', distributionInfo, 'Formula', formulaText, 'Variables', tbl, ...
    'ObservationInfo', observationInfo, ...
    'Fitted', table(fittedResponse, linearPredictor, fittedResponse, 'VariableNames', {'Response', 'LinearPredictor', 'Probability'}), ...
    'LikelihoodPenalty', penalty, 'ResponseName', parsed.response, 'PredictorNames', {parsed.predictors}, ...
    'VariableInfo', design.variableInfo, 'Terms', {parsed.terms}, 'SSE', sse, 'SST', sst, ...
    'Deviance0', deviance0);
mdl = cobraGeneralizedLinearModel(values);
end

function [b, mu, weights] = irlsLogistic(X, y)
% Iteratively reweighted least squares for the logit link
mu = (y + 0.5) / 2;
eta = log(mu ./ (1 - mu));
b = zeros(size(X, 2), 1);
lowest = eps;
highest = 1 - eps;
isConverged = false;
for iteration = 1:100
    weights = mu .* (1 - mu);
    z = eta + (y - mu) ./ weights;
    sw = sqrt(weights);
    [Q, R] = qr(sw .* X, 0);
    bOld = b;
    b = R \ (Q' * (sw .* z));
    eta = X * b;
    mu = 1 ./ (1 + exp(-eta));
    mu = min(max(mu, lowest), highest);
    if all(abs(b - bOld) <= 1e-6 * max(sqrt(eps), abs(bOld)))
        isConverged = true;
        break
    end
end
weights = mu .* (1 - mu);
if ~isConverged
    warning('COBRA:cobraFitglm:IterationLimit', 'Iteration limit reached.');
end
if any(mu <= lowest | mu >= highest)
    warning('COBRA:cobraFitglm:PerfectSeparation', ...
        ['The estimated coefficients perfectly separate failures from successes; the estimates are not finite. ' ...
        'Consider ''LikelihoodPenalty'', ''jeffreys-prior''.']);
end
end

function [b, mu, weights] = firthLogistic(X, y)
% Firth's penalized logistic regression: Newton steps on the modified score with step halving
b = zeros(size(X, 2), 1);
[penalizedLoglik, mu, weights, hat] = penalized(X, y, b);
isConverged = false;
% Fisher scoring on the modified score converges linearly when an observation has a leverage near 1,
% so the Firth iterations are limited at 1000 rather than the 100 of IRLS
for iteration = 1:1000
    score = X' * (y - mu + hat .* (0.5 - mu));
    [~, R] = qr(sqrt(weights) .* X, 0);
    step = R \ (R' \ score);
    stepFraction = 1;
    for halving = 1:30
        trial = b + stepFraction * step;
        [trialLoglik, trialMu, trialWeights, trialHat] = penalized(X, y, trial);
        if trialLoglik >= penalizedLoglik - 1e-12 * abs(penalizedLoglik)
            break
        end
        stepFraction = stepFraction / 2;
    end
    bOld = b;
    b = trial;
    penalizedLoglik = trialLoglik;
    mu = trialMu;
    weights = trialWeights;
    hat = trialHat;
    if all(abs(b - bOld) <= 1e-6 * max(sqrt(eps), abs(bOld)))
        isConverged = true;
        break
    end
end
if ~isConverged
    warning('COBRA:cobraFitglm:IterationLimit', 'Iteration limit reached.');
end
end

function [value, mu, weights, hat] = penalized(X, y, b)
% Penalized log-likelihood l(b) + log(det(X'WX))/2, fitted probabilities, weights and leverages
eta = X * b;
mu = 1 ./ (1 + exp(-eta));
mu = min(max(mu, eps), 1 - eps);
weights = mu .* (1 - mu);
[Q, R] = qr(sqrt(weights) .* X, 0);
hat = sum(Q .^ 2, 2);
value = sum(y .* log(mu) + (1 - y) .* log(1 - mu)) + sum(log(abs(diag(R))));
end

function text = describeValue(value)
% Text naming an option or value in an error message
if ischar(value) || isstring(value)
    text = char(value);
else
    text = class(value);
end
end
