function [b, bint, r, rint, stats] = cobraRegress(y, X, alpha, varargin)
% Multiple linear regression by least squares without the Statistics and
% Machine Learning Toolbox
%
% USAGE:
%
%    b = cobraRegress(y, X)
%    [b, bint, r, rint, stats] = cobraRegress(y, X)
%    [b, bint, r, rint, stats] = cobraRegress(y, X, alpha)
%
% INPUTS:
%    y:        `n` x 1 real numeric response vector
%    X:        `n` x `p` real numeric design matrix; include a column of ones
%              for a model with a constant term
%
% OPTIONAL INPUT:
%    alpha:    significance level of the intervals, in (0, 1) (default 0.05)
%
% OUTPUTS:
%    b:        `p` x 1 coefficient estimates
%    bint:     `p` x 2 lower and upper `100*(1-alpha)`% confidence bounds of
%              `b`
%    r:        `n` x 1 residuals (NaN at the rows omitted for NaN)
%    rint:     `n` x 2 intervals of the residuals (NaN at the omitted rows);
%              an interval not containing 0 marks a possible outlier
%    stats:    1 x 4 vector `[R2 F pF s2]`: coefficient of determination,
%              F statistic of the regression, its p-value, and the error
%              variance estimate
%
% NOTE:
%    Plain-MATLAB replacement for regress (Statistics and Machine Learning
%    Toolbox); supported syntaxes are those listed under USAGE; a further
%    input raises an error naming it; semantics: mathworks-semantics.md §13
%    (feature 20261103-120403-toolbox-free-replacements).
%
%    * Rows with NaN in `y` or `X` are omitted from the fit; `r` and `rint`
%      keep the input length with NaN at those rows. With no complete row
%      the rank is 0: `b` and `bint` are zeros, `r` and `rint` NaN, `stats`
%      NaN, with the rank-deficiency warning.
%    * QR with column pivoting, `[Q, R, perm] = qr(X, 0)`; the rank is the
%      number of `|R(i,i)| > max(n, p)*eps(|R(1,1)|)`. If `X` is rank
%      deficient, warning `cobraRegress:RankDefDesignMat` ("X is rank
%      deficient to within machine precision.") is issued, the columns
%      beyond the rank (in pivot order) are dropped and their `b` and `bint`
%      are 0 (a basic solution).
%    * Residual degrees of freedom `nu = max(0, n - rank)`; `s2 = |r|^2/nu`
%      (NaN when `nu = 0`, where the `t` factor is set to 0, so the `bint` of
%      the estimated coefficients is NaN); `bint = b -/+ tinv(1-alpha/2, nu)*se`.
%    * `rint = r -/+ t*ser`, with leverage `h` and `ser = Inf` where
%      `1-h <= sqrt(eps)`:
%
%      * `nu > 1`: leave-one-out studentized intervals (Belsley, Kuh &
%        Welsch 1980, eq. 2.26), `ser = sqrt(1-h)*s_(i)`,
%        `s_(i)^2 = nu*s2/(nu-1) - r.^2./((nu-1)*(1-h))` (floored at 0),
%        `t = tinv(1-alpha/2, nu-1)` (MathWorks regress 1993-2014; R14 used
%        `nu` degrees of freedom);
%      * `nu = 1`: `ser = sqrt(1-h)*sqrt(s2)` with `t = tinv(1-alpha/2, 1)`
%        (the branch exists in MathWorks regress; its `t` is UNCONFIRMED);
%      * `nu = 0`: NaN.
%    * `R2 = 1 - SSE/TSS` (centred, so it can be negative without a
%      constant); `F = (RSS/(rank-1))/s2` with `RSS = |yhat - mean(y)|^2`
%      (NaN when the rank is 1); `pF` is the upper tail of the F
%      distribution with `(rank-1, nu)` degrees of freedom, computed
%      directly (MathWorks R14 used `1 - fcdf`, current UNCONFIRMED; they
%      differ only below about 1e-16).
%    * When stats are requested, `X` has no column of ones and no implied
%      constant (`sum(abs(1 - X(:,perm)*b0)) > n*sqrt(eps)` for the least-
%      squares fit `b0` of a constant), warning `cobraRegress:NoConst`
%      ("R-square and the F statistic are not well-defined unless X has a
%      column of ones.") is issued, as regress does.
%
% EXAMPLE:
%
%    [b, ~, ~, ~, stats] = cobraRegress(y, [x ones(size(x))]);
%
% .. Authors:
%     - Generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

if ~isempty(varargin)
    extraName = class(varargin{1});
    if ischar(varargin{1}) || isstring(varargin{1})
        extraName = char(varargin{1});
    end
    error('cobraRegress:unsupportedOption', 'cobraRegress: unsupported option ''%s'' (only y, X and alpha are supported).', extraName);
end
if ~exist('alpha', 'var') || isempty(alpha)
    alpha = 0.05;
end
if ~isnumeric(X) || ~isreal(X) || ~ismatrix(X) || ~isnumeric(y) || ~isreal(y) || ~isvector(y) || numel(y) ~= size(X, 1)
    error('cobraRegress:invalidInput', 'cobraRegress: y must be a real numeric vector with one element per row of the real numeric matrix X.');
end
if ~isnumeric(alpha) || ~isscalar(alpha) || ~(alpha > 0 && alpha < 1)
    error('cobraRegress:invalidAlpha', 'cobraRegress: alpha must be a scalar in (0, 1).');
end

y = double(y(:));
X = double(X);
isMissing = isnan(y) | any(isnan(X), 2);
yUsed = y(~isMissing);
XUsed = X(~isMissing, :);
[nObs, nVars] = size(XUsed);

% QR with column pivoting and numerical rank (0 when no row is complete)
[Q, R, perm] = qr(XUsed, 0);
nDiagonal = min(size(R));
diagonalR = abs(R(sub2ind(size(R), 1:nDiagonal, 1:nDiagonal)));
rankX = 0;
if nDiagonal > 0
    rankX = sum(diagonalR > max(nObs, nVars) * eps(diagonalR(1)));
end
if rankX < nVars
    warning('cobraRegress:RankDefDesignMat', 'X is rank deficient to within machine precision.');
    R = R(1:rankX, 1:rankX);
    Q = Q(:, 1:rankX);
    perm = perm(1:rankX);
end

b = zeros(nVars, 1);
b(perm) = R \ (Q' * yUsed);
yHat = XUsed * b;
rUsed = yUsed - yHat;
nu = max(0, nObs - rankX);
if nu ~= 0
    rmse = norm(rUsed) / sqrt(nu);
    tval = cobraTinv(1 - alpha / 2, nu);
else
    rmse = NaN;
    tval = 0;
end
s2 = rmse ^ 2;

% coefficient intervals; dropped columns keep b = 0 and se = 0
inverseR = R \ eye(rankX);
se = zeros(nVars, 1);
se(perm) = rmse * sqrt(sum(inverseR .^ 2, 2));
bint = [b - tval * se, b + tval * se];

% residual intervals (leave-one-out studentized for nu > 1), NaN at omitted rows
leverage = sum(Q .^ 2, 2);
isRegular = (1 - leverage) > sqrt(eps);
leverage(~isRegular) = 1;
if nu > 1
    sigmaLeaveOneOut = zeros(nObs, 1);
    sigmaLeaveOneOut(isRegular) = sqrt(max(0, nu * s2 / (nu - 1) ...
        - rUsed(isRegular) .^ 2 ./ ((nu - 1) * (1 - leverage(isRegular)))));
    residualSe = sqrt(1 - leverage) .* sigmaLeaveOneOut;
    residualSe(~isRegular) = Inf;
    tvalResidual = cobraTinv(1 - alpha / 2, nu - 1);
elseif nu == 1
    residualSe = sqrt(1 - leverage) * rmse;
    residualSe(~isRegular) = Inf;
    tvalResidual = tval;
else
    % nu = 0: rmse is NaN, so the intervals are NaN
    residualSe = rmse * ones(nObs, 1);
    tvalResidual = tval;
end
r = NaN(numel(y), 1);
r(~isMissing) = rUsed;
rint = NaN(numel(y), 2);
rint(~isMissing, :) = [rUsed - tvalResidual * residualSe, rUsed + tvalResidual * residualSe];

if nargout > 4
    % a constant term: a column of ones, or a constant implied by the columns
    if ~any(all(XUsed == 1, 1))
        constantFit = R \ (Q' * ones(nObs, 1));
        if sum(abs(1 - XUsed(:, perm) * constantFit)) > nObs * sqrt(eps)
            warning('cobraRegress:NoConst', 'R-square and the F statistic are not well-defined unless X has a column of ones.');
        end
    end
    sse = norm(rUsed) ^ 2;
    tss = norm(yUsed - mean(yUsed)) ^ 2;
    rss = norm(yHat - mean(yUsed)) ^ 2;
    r2 = 1 - sse / tss;
    if rankX > 1
        F = (rss / (rankX - 1)) / s2;
        pF = cobraFcdf(F, rankX - 1, nu, 'upper');
    else
        F = NaN;
        pF = NaN;
    end
    stats = [r2 F pF s2];
end
end
