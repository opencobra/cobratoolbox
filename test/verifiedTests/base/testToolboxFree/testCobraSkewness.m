% The COBRAToolbox: testCobraSkewness.m
%
% Purpose:
%     - cobraSkewness is the plain-MATLAB replacement for skewness (Statistics and Machine
%       Learning Toolbox). This test checks every syntax used by the call sites in src/
%       (skewness(X) on a matrix, working down the columns), the rules of
%       mathworks-semantics.md section 11 (NaN ignored per column, biased default, flag 0
%       bias correction, dim and 'all', NaN for constant slices), the errors for unsupported
%       arguments, and parity with skewness when the toolbox is installed.
%     - Reference values: (a) the MathWorks documentation examples at
%       https://www.mathworks.com/help/stats/skewness.html (4 decimals shown there, so they
%       are compared with an absolute tolerance of 5e-5); (b) SciPy 1.16.0
%       scipy.stats.skew(bias=True|False, nan_policy='omit') printed by
%       specs/20261103-120403-toolbox-free-replacements/references/tables.py (compared with a
%       relative tolerance of 1e-12: the same closed form, so only rounding differs).
%     - The input data are MATLAB's rng('default'); randn(1,24) printed with %.17g, the numbers
%       used by the documentation examples.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraSkewness.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCobraSkewness'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% skewness(X) of a matrix works down the columns (call site calcSampleStats)

randn24 = [0.53766713954610001, 1.8338850145950865, -2.2588468610036481, 0.86217332036812055, ...
    0.31876523985898081, -1.3076882963052734, -0.43359202230568356, 0.34262446653864992, ...
    3.5783969397257605, 2.7694370298848772, -1.3498869401565212, 3.0349234663318545, ...
    0.72540422494610557, -0.063054873189656191, 0.71474290382609584, -0.20496605829977463, ...
    -0.12414434821631191, 1.4896976077854649, 1.4090344898004792, 1.4171924134296139, ...
    0.6714971336080805, -1.2074869226850378, 0.71723865132883846, 1.6302352891647292];
X = reshape(randn24(1:20), 5, 4);
y = cobraSkewness(X);
% documentation example "Find Skewness of Matrix" (4 decimals shown)
assert(isequal(size(y), [1 4]));
assert(max(abs(y - [-0.9362 0.2333 0.4363 -0.4075])) <= 5e-5);
% SciPy 1.16.0 skew(bias=True), axis 0
scipyY = [-0.93619933132166056 0.23330364995903299 0.43626578192597515 -0.40753742893591];
assert(max(abs(y - scipyY) ./ abs(scipyY)) <= 1e-12);
% the call site transposes a reactions x samples matrix and transposes the result back
samples = X';
assert(isequal(cobraSkewness(samples')', y'));

%% a row vector gives a scalar; flag 0 corrects for bias (documentation "Correct for Bias")

randn24 = [0.53766713954610001, 1.8338850145950865, -2.2588468610036481, 0.86217332036812055, ...
    0.31876523985898081, -1.3076882963052734, -0.43359202230568356, 0.34262446653864992, ...
    3.5783969397257605, 2.7694370298848772];
yBiased = cobraSkewness(randn24);
yCorrected = cobraSkewness(randn24, 0);
assert(isscalar(yBiased) && isscalar(yCorrected));
% documentation values 0.1061 and 0.1258
assert(abs(yBiased - 0.1061) <= 5e-5 && abs(yCorrected - 0.1258) <= 5e-5);
% SciPy 1.16.0 skew(bias=True) and skew(bias=False)
assert(abs(yBiased - 0.10609663782772447) <= 1e-12 * 0.10609663782772447);
assert(abs(yCorrected - 0.12581513535809569) <= 1e-12 * 0.12581513535809569);
% an empty flag means the default, flag 1
assert(isequal(cobraSkewness(randn24, []), yBiased));
assert(isequal(cobraSkewness(randn24(:)), yBiased));

%% flag 0 on a matrix and dim 2

randn24 = [0.53766713954610001, 1.8338850145950865, -2.2588468610036481, 0.86217332036812055, ...
    0.31876523985898081, -1.3076882963052734, -0.43359202230568356, 0.34262446653864992, ...
    3.5783969397257605, 2.7694370298848772, -1.3498869401565212, 3.0349234663318545, ...
    0.72540422494610557, -0.063054873189656191, 0.71474290382609584, -0.20496605829977463, ...
    -0.12414434821631191, 1.4896976077854649, 1.4090344898004792, 1.4171924134296139];
X = reshape(randn24, 5, 4);
% SciPy 1.16.0 skew(bias=False), axis 0
scipyCorrected = [-1.3956035635500541 0.34778854713814256 0.65034662976238633 -0.60752092965078963];
yCorrected = cobraSkewness(X, 0);
assert(max(abs(yCorrected - scipyCorrected) ./ abs(scipyCorrected)) <= 1e-12);
% SciPy 1.16.0 skew(bias=True), axis 1: a 5 x 1 column
scipyRows = [0.30964668215328928; 0.23640311812158715; -0.85589455741237463; ...
    0.63038048532252955; 0.60945431815271245];
yRows = cobraSkewness(X, 1, 2);
assert(isequal(size(yRows), [5 1]));
assert(max(abs(yRows - scipyRows) ./ abs(scipyRows)) <= 1e-12);

%% three-dimensional input, dim, vecdim and 'all' (documentation examples 3 and 4)

randn24 = [0.53766713954610001, 1.8338850145950865, -2.2588468610036481, 0.86217332036812055, ...
    0.31876523985898081, -1.3076882963052734, -0.43359202230568356, 0.34262446653864992, ...
    3.5783969397257605, 2.7694370298848772, -1.3498869401565212, 3.0349234663318545, ...
    0.72540422494610557, -0.063054873189656191, 0.71474290382609584, -0.20496605829977463, ...
    -0.12414434821631191, 1.4896976077854649, 1.4090344898004792, 1.4171924134296139, ...
    0.6714971336080805, -1.2074869226850378, 0.71723865132883846, 1.6302352891647292];
X = reshape(randn24, 4, 3, 2);
% default dim: 1 x 3 x 2; documentation and SciPy 1.16.0 skew(axis=0)
y1 = cobraSkewness(X);
assert(isequal(size(y1), [1 3 2]));
assert(max(abs(y1(:)' - [-0.8084 -0.5578 -1.0772 -0.0403 -1.1472 -0.6632])) <= 5e-5);
scipyY1 = [-0.80839447306266055 -0.55779290269299941 -1.0772306377031402 ...
    -0.040335198304463478 -1.1471867673696452 -0.66319905615687325];
assert(max(abs(y1(:)' - scipyY1) ./ abs(scipyY1)) <= 1e-12);
% dim 2: 4 x 1 x 2; documentation and SciPy 1.16.0 skew(axis=1)
y2 = cobraSkewness(X, 1, 2);
assert(isequal(size(y2), [4 1 2]));
assert(max(abs(y2(:)' - [0.6956 -0.5575 0.0049 0.6033 -0.6969 0.1828 0.7071 -0.6714])) <= 5e-5);
scipyY2 = [0.69564207518333143 -0.5575465301112561 0.0049217298943604977 0.6033034710333921 ...
    -0.69690443549876568 0.18283992632559365 0.70707583316928091 -0.67143734652767273];
assert(max(abs(y2(:)' - scipyY2) ./ abs(scipyY2)) <= 1e-12);
% dim 3 has two values per slice: the skewness is zero up to rounding (the documentation
% shows numbers of order 1e-16)
y3 = cobraSkewness(X, 1, 3);
assert(isequal(size(y3), [4 3]) && max(abs(y3(:))) <= 1e-14);
% 'all' and vecdim [1 2]; documentation 0.0916 and [0.1070 -0.6263]
yAll = cobraSkewness(X, 1, 'all');
assert(isscalar(yAll) && abs(yAll - 0.0916) <= 5e-5);
assert(abs(yAll - 0.091579317153181419) <= 1e-12 * 0.091579317153181419);
yPage = cobraSkewness(X, 1, [1 2]);
assert(isequal(size(yPage), [1 1 2]));
assert(max(abs(yPage(:)' - [0.1070 -0.6263])) <= 5e-5);
scipyPage = [0.10699594196721494 -0.62632266366022593];
assert(max(abs(yPage(:)' - scipyPage) ./ abs(scipyPage)) <= 1e-12);
% vecdim [1 3]: documentation [-1.0755 -0.3108 -0.2209]
yCol = cobraSkewness(X, 1, [1 3]);
assert(isequal(size(yCol), [1 3]));
assert(max(abs(yCol - [-1.0755 -0.3108 -0.2209])) <= 5e-5);
% 'all' as a string scalar
assert(isequal(cobraSkewness(X, 1, "all"), yAll));

%% NaN values are ignored per column

D = [1 2; 2 NaN; 4 3; NaN 7; 10 5; 3 11];
% SciPy 1.16.0 skew(axis=0, nan_policy='omit'), bias True and False
scipyBiased = [1.1384199576606167 0.58447265625000022];
scipyCorrected = [1.6970562748477143 0.87128039357657849];
assert(max(abs(cobraSkewness(D) - scipyBiased) ./ scipyBiased) <= 1e-12);
assert(max(abs(cobraSkewness(D, 0) - scipyCorrected) ./ scipyCorrected) <= 1e-12);
% a column of NaN only gives NaN
assert(isnan(cobraSkewness([NaN; NaN; NaN])));

%% NaN results: constant slice, one value, X = [], dim beyond ndims, flag 0 with n < 3

% constant column: 0/0
yConst = cobraSkewness([1 2; 1 5; 1 9]);
assert(isnan(yConst(1)) && ~isnan(yConst(2)));
% a scalar and the empty matrix
assert(isnan(cobraSkewness(7)));
assert(isnan(cobraSkewness([])));
% [] keeps its class; with a dim it is an ordinary empty array (1 x 0 along dim 1)
assert(isa(cobraSkewness(single([])), 'single') && isnan(cobraSkewness(single([]))));
assert(isequal(size(cobraSkewness([], 1, 1)), [1 0]));
% a working dimension of size 1 gives NaN of size(X)
yBeyond = cobraSkewness([1 2 3; 4 5 9], 1, 3);
assert(isequal(size(yBeyond), [2 3]) && all(isnan(yBeyond(:))));
% flag 0 needs at least 3 values per slice
assert(isnan(cobraSkewness([1 4], 0)));
yFew = cobraSkewness([1 2; 3 NaN; 4 NaN; 8 4], 0);
assert(~isnan(yFew(1)) && isnan(yFew(2)));
% an empty matrix that is not [] gives NaN per column
yEmpty = cobraSkewness(zeros(0, 3));
assert(isequal(size(yEmpty), [1 3]) && all(isnan(yEmpty)));

%% unsupported flag and dim values raise an error

assert(verifyCobraFunctionError('cobraSkewness', 'inputs', {[1 2 10], 2}, ...
    'testMessage', 'cobraSkewness: flag must be 0 or 1.'));
assert(verifyCobraFunctionError('cobraSkewness', 'inputs', {[1 2 10], 1, 0}, ...
    'testMessage', 'cobraSkewness: dim must be distinct positive integers or ''all''.'));
assert(verifyCobraFunctionError('cobraSkewness', 'inputs', {[1 2 10], 1, 'rows'}, ...
    'testMessage', 'cobraSkewness: dim must be distinct positive integers or ''all''.'));

%% repeated dimensions and non-floating-point X are rejected

assert(verifyCobraFunctionError('cobraSkewness', 'inputs', {magic(3), 1, [1 1]}, ...
    'testMessage', 'cobraSkewness: dim must be distinct positive integers or ''all''.'));
assert(verifyCobraFunctionError('cobraSkewness', 'inputs', {int8([1 2 10])}, ...
    'testMessage', 'cobraSkewness: X must be a single or double array.'));
assert(verifyCobraFunctionError('cobraSkewness', 'inputs', {[true false true]}, ...
    'testMessage', 'cobraSkewness: X must be a single or double array.'));

%% parity with skewness when the Statistics and Machine Learning Toolbox is installed

if exist('skewness', 'file') && license('test', 'Statistics_Toolbox')
    X = [1 2 NaN; 4 3 3; 2 8 1; 9 1 7; 3 3 2];
    % same closed form, so the results agree to rounding
    assert(max(abs(cobraSkewness(X) - skewness(X))) <= 1e-12);
    assert(max(abs(cobraSkewness(X, 0) - skewness(X, 0)), [], 'omitnan') <= 1e-12);
    assert(max(abs(cobraSkewness(X, 1, 2) - skewness(X, 1, 2))) <= 1e-12);
else
    fprintf('skipped: Statistics and Machine Learning Toolbox not installed\n');
end

% change the directory
cd(currentDir)
