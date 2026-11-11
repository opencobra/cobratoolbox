function mdl = cobraFitcsvm(X, Y, varargin)
% Trains a linear support vector machine for two classes by sequential minimal
% optimization, without the Statistics and Machine Learning Toolbox
%
% USAGE:
%
%    mdl = cobraFitcsvm(X, Y)
%    mdl = cobraFitcsvm(X, Y, 'DeltaGradientTolerance', tolerance, 'IterationLimit', limit)
%
% INPUTS:
%    X:      n x p numeric predictor matrix (one observation per row)
%    Y:      n x 1 class labels with exactly two distinct values (numeric, logical, cell
%            array of character vectors, string or categorical)
%
% OPTIONAL INPUTS (name-value pairs, MathWorks names):
%    'DeltaGradientTolerance':  stopping tolerance on the gap between the maximal violating
%                               pair of gradients (default 1e-3, as fitcsvm)
%    'IterationLimit':          maximum number of iterations (default 1e6)
%
% OUTPUT:
%    mdl:    structure with fields `Beta` (p x 1 linear coefficients), `Bias`, `Alpha` (dual
%            coefficients of the support vectors), `IsSupportVector` (n x 1 logical),
%            `SupportVectors`, `SupportVectorLabels` (+1/-1), `ClassNames` (sorted; the second
%            is the positive class), `BoxConstraint` (1), `KernelParameters` (Function
%            'linear', Scale 1) and `ConvergenceInfo` (Converged, Iterations, Gap)
%
% EXAMPLE:
%
%    mdl = cobraFitcsvm([0 0; 0 1; 2 2; 2 3], [0; 0; 1; 1]);
%    score = [0 0; 2 2] * mdl.Beta + mdl.Bias   % negative, then positive
%
% NOTE:
%    Plain-MATLAB replacement for fitcsvm(X, Y) (Statistics and Machine Learning Toolbox) with
%    its defaults (linear kernel, KernelScale 1, BoxConstraint 1, no standardization, the
%    'SMO' solver); other options raise an error naming them; semantics:
%    specs/20261111-152503-toolbox-free-remaining/mathworks-semantics.md, G3 section 7.
%    Dual problem: min 1/2*a'*Q*a - sum(a) with Q(i,j) = y(i)*y(j)*x(i)'*x(j),
%    y'*a = 0, 0 <= a <= 1 (y = +1 for the second class). Sequential minimal optimization
%    with second-order working-set selection (Fan, Chen and Lin 2005, the algorithm of libsvm
%    and of the fitcsvm default solver), kernel columns computed on demand; stops when the
%    maximal violating pair's gradient gap is below DeltaGradientTolerance. Beta = sum of
%    a(i)*y(i)*x(i) is unique (strictly convex primal); the bias is the mean of
%    y(i) - x(i)'*Beta over the free support vectors (libsvm rule; the MathWorks rule is
%    UNCONFIRMED and the bias need not be unique). Rows with a missing label or a NaN predictor
%    value are removed.
%
% .. Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

tolerance = 1e-3;
iterationLimit = 1e6;
if mod(numel(varargin), 2) ~= 0
    error('COBRA:cobraFitcsvm:unsupportedOption', 'cobraFitcsvm: unsupported option ''%s'' (options are name-value pairs).', describeValue(varargin{end}));
end
for k = 1:2:numel(varargin)
    switch lower(describeValue(varargin{k}))
        case 'deltagradienttolerance'
            tolerance = varargin{k + 1};
        case 'iterationlimit'
            iterationLimit = varargin{k + 1};
        otherwise
            error('COBRA:cobraFitcsvm:unsupportedOption', 'cobraFitcsvm: unsupported option ''%s''.', describeValue(varargin{k}));
    end
end
if ~(isnumeric(X) || islogical(X)) || ~ismatrix(X)
    error('COBRA:cobraFitcsvm:invalidInput', 'cobraFitcsvm: X must be a numeric matrix.');
end
X = double(X);
[classIndex, classNames, classLevels] = cobraGrp2idx(Y);
if numel(classIndex) ~= size(X, 1)
    error('COBRA:cobraFitcsvm:invalidInput', 'cobraFitcsvm: Y must have one label per row of X.');
end
isKept = ~isnan(classIndex) & ~any(isnan(X), 2); % missing labels and predictor values
X = X(isKept, :);
classIndex = classIndex(isKept);
% classes in sorted order (fitcsvm ClassNames); the second is the positive class
if isnumeric(Y) || islogical(Y)
    [classNamesOut, order] = sort(classLevels(:));
else
    [~, order] = sort(classNames);
    classNamesOut = classNames(order);
end
if numel(order) ~= 2
    error('COBRA:cobraFitcsvm:invalidInput', 'cobraFitcsvm: Y must have exactly two classes (one-class and multiclass learning are not supported).');
end
y = -ones(numel(classIndex), 1);
y(classIndex == order(2)) = 1;

n = size(X, 1);
C = 1;
alpha = zeros(n, 1);
gradient = -ones(n, 1);
kernelDiagonal = sum(X .^ 2, 2);
tau = 1e-12;
iteration = 0;
isConverged = false;
gap = Inf;
while iteration < iterationLimit
    % maximal violating pair with second-order selection of j (Fan, Chen and Lin 2005)
    isUp = (y == 1 & alpha < C) | (y == -1 & alpha > 0);
    isLow = (y == 1 & alpha > 0) | (y == -1 & alpha < C);
    violation = -y .* gradient;
    upCandidates = find(isUp);
    [mValue, position] = max(violation(isUp));
    i = upCandidates(position);
    MValue = min(violation(isLow));
    gap = mValue - MValue;
    if gap < tolerance
        isConverged = true;
        break
    end
    iteration = iteration + 1;
    kernelI = X * X(i, :)';
    candidates = find(isLow & violation < mValue);
    b = mValue - violation(candidates);
    a = kernelDiagonal(i) + kernelDiagonal(candidates) - 2 * kernelI(candidates);
    a(a <= 0) = tau;
    [~, best] = min(-(b .^ 2) ./ a);
    j = candidates(best);
    kernelJ = X * X(j, :)';
    % two-variable update with the box clipping of libsvm
    alphaI = alpha(i);
    alphaJ = alpha(j);
    if y(i) ~= y(j)
        quadratic = max(kernelDiagonal(i) + kernelDiagonal(j) - 2 * kernelI(j), tau);
        delta = (-gradient(i) - gradient(j)) / quadratic;
        difference = alpha(i) - alpha(j);
        alpha(i) = alpha(i) + delta;
        alpha(j) = alpha(j) + delta;
        if difference > 0 && alpha(j) < 0
            alpha(j) = 0;
            alpha(i) = difference;
        elseif difference <= 0 && alpha(i) < 0
            alpha(i) = 0;
            alpha(j) = -difference;
        end
        if difference > 0 && alpha(i) > C
            alpha(i) = C;
            alpha(j) = C - difference;
        elseif difference <= 0 && alpha(j) > C
            alpha(j) = C;
            alpha(i) = C + difference;
        end
    else
        quadratic = max(kernelDiagonal(i) + kernelDiagonal(j) - 2 * kernelI(j), tau);
        delta = (gradient(i) - gradient(j)) / quadratic;
        total = alpha(i) + alpha(j);
        alpha(i) = alpha(i) - delta;
        alpha(j) = alpha(j) + delta;
        if total > C && alpha(i) > C
            alpha(i) = C;
            alpha(j) = total - C;
        elseif total <= C && alpha(j) < 0
            alpha(j) = 0;
            alpha(i) = total;
        end
        if total > C && alpha(j) > C
            alpha(j) = C;
            alpha(i) = total - C;
        elseif total <= C && alpha(i) < 0
            alpha(i) = 0;
            alpha(j) = total;
        end
    end
    % gradient update: G = Q*alpha - 1, Q(:, i) = y .* y(i) .* kernelI
    gradient = gradient + y .* (y(i) * (alpha(i) - alphaI) * kernelI + y(j) * (alpha(j) - alphaJ) * kernelJ);
end

beta = X' * (alpha .* y);
isFree = alpha > 0 & alpha < C;
if any(isFree)
    bias = mean(y(isFree) - X(isFree, :) * beta);
else
    % no free support vector: the midpoint of the feasible interval of the bias (libsvm)
    violation = -y .* gradient;
    isUp = (y == 1 & alpha < C) | (y == -1 & alpha > 0);
    isLow = (y == 1 & alpha > 0) | (y == -1 & alpha < C);
    bias = (max(violation(isUp)) + min(violation(isLow))) / 2;
end
isSupportVector = alpha > 0;
mdl = struct('Beta', beta, 'Bias', bias, 'Alpha', alpha(isSupportVector), 'IsSupportVector', isSupportVector, ...
    'SupportVectors', X(isSupportVector, :), 'SupportVectorLabels', y(isSupportVector), ...
    'ClassNames', {classNamesOut}, 'BoxConstraint', C, ...
    'KernelParameters', struct('Function', 'linear', 'Scale', 1), ...
    'ConvergenceInfo', struct('Converged', isConverged, 'Iterations', iteration, 'Gap', gap));
end

function text = describeValue(value)
% Text naming an option or value in an error message
if ischar(value) || isstring(value)
    text = char(value);
else
    text = class(value);
end
end
