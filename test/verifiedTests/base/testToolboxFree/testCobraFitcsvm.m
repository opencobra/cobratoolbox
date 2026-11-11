% The COBRAToolbox: testCobraFitcsvm.m
%
% Purpose:
%     - cobraFitcsvm is the plain-MATLAB replacement for fitcsvm(X, Y) with its defaults
%       (Statistics and Machine Learning Toolbox), as used by optimalScores (modelBorgifier),
%       which reads only Beta. Beta is unique (strictly convex primal problem), so it is compared
%       with scikit-learn SVC(kernel='linear', C=1) (libsvm, the same SMO family); the bias and
%       the dual coefficients need not be unique and are checked through the optimality (KKT)
%       conditions. The test covers overlapping clouds, a score-like integer matrix with a zero
%       column and conflicting duplicate rows, the default and a tight tolerance, label types
%       and class order, seeded random problems (all branches of the two-variable update), the
%       iteration limit, and the errors for unsupported options and inputs.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraFitcsvm.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCobraFitcsvm'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

relativeError = @(value, reference) abs(value - reference) ./ abs(reference);
% KKT conditions of the dual with C = 1: margin >= 1 - tol where alpha = 0, <= 1 + tol where
% alpha = C, and = 1 within tol for free support vectors; sum(alpha .* y) = 0
checkKkt = @(X, y, mdl, alphaFull, tol) all(y .* (X * mdl.Beta + mdl.Bias) >= 1 - tol | alphaFull > 0) && ...
    all(y .* (X * mdl.Beta + mdl.Bias) <= 1 + tol | alphaFull < 1) && abs(sum(alphaFull .* y)) < 1e-10;

%% overlapping clouds against scikit-learn (deterministic data)

% references/g3_regression.py (section svm), scikit-learn 1.9.1 SVC(kernel='linear', C=1,
% tol=1e-10): Beta = [0.9315935741077133 0.9536305204110976 0.10100274561831069],
% Bias = -0.9545848477979141, 27 support vectors
i = (1:60)';
X = [sin(1.3 * i) + (i <= 30) * 1.2, cos(0.7 * i) + (i <= 30) * 0.8, sin(0.4 * i) * 0.5];
labels = double(i <= 30);
mdl = cobraFitcsvm(X, labels, 'DeltaGradientTolerance', 1e-10);
% both solvers stop at a gradient gap of 1e-10; Beta agrees to 1e-6 of its norm (the small third
% component is 3e-6 relative)
assert(max(abs(mdl.Beta' - [0.9315935741077133 0.9536305204110976 0.10100274561831069])) < 1e-6 * norm(mdl.Beta));
assert(relativeError(mdl.Bias, -0.9545848477979141) < 1e-6 && sum(mdl.IsSupportVector) == 27 && mdl.ConvergenceInfo.Converged);
assert(isequal(mdl.ClassNames, [0; 1]) && strcmp(mdl.KernelParameters.Function, 'linear') && mdl.BoxConstraint == 1);
y = 2 * labels - 1;
alphaFull = zeros(60, 1);
alphaFull(mdl.IsSupportVector) = mdl.Alpha;
assert(checkKkt(X, y, mdl, alphaFull, 1e-8));
assert(max(abs(mdl.Beta - X' * (alphaFull .* y))) < 1e-12 && isequal(mdl.SupportVectorLabels, y(mdl.IsSupportVector)));
% the default tolerance (1e-3, as fitcsvm) stays within 1e-3 of the norm of the optimum
mdlDefault = cobraFitcsvm(X, labels);
assert(max(abs(mdlDefault.Beta - mdl.Beta)) < 1e-3 * norm(mdl.Beta));

%% score-like integer matrix (optimalScores): zero column, conflicting duplicate rows

% scikit-learn 1.9.1: Beta = [~0 0 0.6666666666655416], Bias = -1.6666666666591319
S = [mod(3 * i, 5), zeros(60, 1), mod(7 * i, 4) + (i <= 30) * 2];
S(60, :) = S(1, :);
mdl = cobraFitcsvm(int8(S), labels, 'DeltaGradientTolerance', 1e-10);
assert(abs(mdl.Beta(1)) < 1e-9 && mdl.Beta(2) == 0 && abs(mdl.Beta(3) - 2 / 3) < 1e-9 && abs(mdl.Bias + 5 / 3) < 1e-9);

%% label types: logical, cell (sorted class names, second positive), missing labels removed

mdlLogical = cobraFitcsvm(X, logical(labels), 'DeltaGradientTolerance', 1e-10);
assert(max(abs(mdlLogical.Beta - cobraFitcsvm(X, labels, 'DeltaGradientTolerance', 1e-10).Beta)) < 1e-12);
textLabels = repmat({'miss'}, 60, 1);
textLabels(i <= 30) = {'hit'};
mdlText = cobraFitcsvm(X, textLabels, 'DeltaGradientTolerance', 1e-10);
% sorted classes {'hit', 'miss'}: 'miss' is positive, so Beta changes sign
assert(isequal(mdlText.ClassNames, {'hit'; 'miss'}) && max(abs(mdlText.Beta + mdlLogical.Beta)) < 1e-8);
labelsWithMissing = labels;
labelsWithMissing(5) = NaN;
assert(sum(cobraFitcsvm(X, labelsWithMissing).IsSupportVector) <= 59);

%% seeded random problems: optimality conditions (all branches of the two-variable update)

rng(20261111);
for problem = 1:12
    nObservations = 20 + 10 * mod(problem, 4);
    nFeatures = 1 + mod(problem, 3);
    separation = 0.2 * mod(problem, 5);
    labelsRandom = double(rand(nObservations, 1) < 0.4 + 0.05 * mod(problem, 3));
    XRandom = randn(nObservations, nFeatures) * (1 + mod(problem, 2) * 4) + separation * labelsRandom;
    mdlRandom = cobraFitcsvm(XRandom, labelsRandom, 'DeltaGradientTolerance', 1e-10);
    yRandom = 2 * labelsRandom - 1;
    alphaRandom = zeros(nObservations, 1);
    alphaRandom(mdlRandom.IsSupportVector) = mdlRandom.Alpha;
    assert(mdlRandom.ConvergenceInfo.Converged && checkKkt(XRandom, yRandom, mdlRandom, alphaRandom, 1e-7), sprintf('problem %d', problem));
end
% separable data without free support vectors at the solution is handled by the midpoint bias
mdlSeparable = cobraFitcsvm([0; 1; 3; 4], [0; 0; 1; 1]);
assert(sign([0; 4] * mdlSeparable.Beta + mdlSeparable.Bias)' * [-1; 1] == 2);

%% iteration limit

mdlLimited = cobraFitcsvm(X, labels, 'IterationLimit', 2);
assert(~mdlLimited.ConvergenceInfo.Converged && mdlLimited.ConvergenceInfo.Iterations == 2);

%% errors: unsupported options and inputs

assert(verifyCobraFunctionError('cobraFitcsvm', 'inputs', {X, labels, 'KernelFunction', 'rbf'}, ...
    'testMessage', 'cobraFitcsvm: unsupported option ''KernelFunction''.'));
assert(verifyCobraFunctionError('cobraFitcsvm', 'inputs', {X, labels, 'Standardize'}, ...
    'testMessage', 'cobraFitcsvm: unsupported option ''Standardize'' (options are name-value pairs).'));
assert(verifyCobraFunctionError('cobraFitcsvm', 'inputs', {X, labels, 3, 1}, ...
    'testMessage', 'cobraFitcsvm: unsupported option ''double''.'));
assert(verifyCobraFunctionError('cobraFitcsvm', 'inputs', {{1}, labels}, ...
    'testMessage', 'cobraFitcsvm: X must be a numeric matrix.'));
assert(verifyCobraFunctionError('cobraFitcsvm', 'inputs', {X, labels(1:10)}, ...
    'testMessage', 'cobraFitcsvm: Y must have one label per row of X.'));
assert(verifyCobraFunctionError('cobraFitcsvm', 'inputs', {X, ones(60, 1)}, ...
    'testMessage', 'cobraFitcsvm: Y must have exactly two classes (one-class and multiclass learning are not supported).'));

%% parity with fitcsvm (only where the Statistics and Machine Learning Toolbox is installed)

if exist('fitcsvm', 'file') == 2 && license('test', 'Statistics_Toolbox')
    mdlToolbox = fitcsvm(X, labels);
    % both stop at the default gradient-gap tolerance 1e-3 around the same unique Beta
    assert(max(abs(cobraFitcsvm(X, labels).Beta - mdlToolbox.Beta)) < 5e-3 * norm(mdlToolbox.Beta));
    fprintf('parity with fitcsvm: passed\n');
else
    fprintf('skipped: Statistics and Machine Learning Toolbox not installed\n');
end

% change the directory
cd(currentDir)
