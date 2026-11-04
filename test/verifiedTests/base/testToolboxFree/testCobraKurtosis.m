% The COBRAToolbox: testCobraKurtosis.m
%
% Purpose:
%     - cobraKurtosis is the plain-MATLAB replacement for kurtosis (Statistics and Machine
%       Learning Toolbox). This test checks every syntax used by the call sites in src/
%       (kurtosis(X) on a matrix, working down the columns), the rules of
%       mathworks-semantics.md section 11 (NaN ignored per column, biased default, kurtosis
%       not excess kurtosis, flag 0 bias correction, dim and 'all', NaN for constant slices),
%       the errors for unsupported arguments, and parity with kurtosis when the toolbox is
%       installed.
%     - Reference values: (a) the MathWorks documentation examples at
%       https://www.mathworks.com/help/stats/kurtosis.html (4 decimals shown there, so they
%       are compared with an absolute tolerance of 5e-5); (b) SciPy 1.16.0
%       scipy.stats.kurtosis(fisher=False, bias=True|False, nan_policy='omit') printed by
%       specs/20261103-120403-toolbox-free-replacements/references/tables.py (compared with a
%       relative tolerance of 1e-12: the same closed form, so only rounding differs).
%     - The input data are MATLAB's rng('default'); randn(1,24) printed with %.17g, the numbers
%       used by the documentation examples.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraKurtosis.m
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
fileDir = fileparts(which('testCobraKurtosis'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% kurtosis(X) of a matrix works down the columns (call site calcSampleStats)

randn24 = [0.53766713954610001, 1.8338850145950865, -2.2588468610036481, 0.86217332036812055, ...
    0.31876523985898081, -1.3076882963052734, -0.43359202230568356, 0.34262446653864992, ...
    3.5783969397257605, 2.7694370298848772, -1.3498869401565212, 3.0349234663318545, ...
    0.72540422494610557, -0.063054873189656191, 0.71474290382609584, -0.20496605829977463, ...
    -0.12414434821631191, 1.4896976077854649, 1.4090344898004792, 1.4171924134296139];
X = reshape(randn24, 5, 4);
k = cobraKurtosis(X);
% documentation example "Find Kurtosis of Matrix" (4 decimals shown)
assert(isequal(size(k), [1 4]));
assert(max(abs(k - [2.7067 1.4069 2.3783 1.1759])) <= 5e-5);
% SciPy 1.16.0 kurtosis(fisher=False, bias=True), axis 0
scipyK = [2.7066928726934325 1.4068857366717229 2.3783273270025838 1.1759453818252805];
assert(max(abs(k - scipyK) ./ scipyK) <= 1e-12);
% the call site transposes a reactions x samples matrix and transposes the result back
samples = X';
assert(isequal(cobraKurtosis(samples')', k'));

%% a row vector gives a scalar; flag 0 corrects for bias (documentation "Correct for Bias")

randn24 = [0.53766713954610001, 1.8338850145950865, -2.2588468610036481, 0.86217332036812055, ...
    0.31876523985898081, -1.3076882963052734, -0.43359202230568356, 0.34262446653864992, ...
    3.5783969397257605, 2.7694370298848772];
kBiased = cobraKurtosis(randn24);
kCorrected = cobraKurtosis(randn24, 0);
assert(isscalar(kBiased) && isscalar(kCorrected));
% documentation values 2.3121 and 2.7483
assert(abs(kBiased - 2.3121) <= 5e-5 && abs(kCorrected - 2.7483) <= 5e-5);
% SciPy 1.16.0 kurtosis(fisher=False) with bias=True and bias=False
assert(abs(kBiased - 2.3121420708073832) <= 1e-12 * 2.3121420708073832);
assert(abs(kCorrected - 2.7482511608916238) <= 1e-12 * 2.7482511608916238);
% an empty flag means the default, flag 1
assert(isequal(cobraKurtosis(randn24, []), kBiased));
assert(isequal(cobraKurtosis(randn24(:)), kBiased));
% not excess kurtosis: [1 2 3 4] has m4/m2^2 = 2.5625/1.5625 = 1.64 exactly by hand
assert(abs(cobraKurtosis([1 2 3 4]) - 1.64) <= 1e-14);

%% flag 0 on a matrix and dim 2

randn24 = [0.53766713954610001, 1.8338850145950865, -2.2588468610036481, 0.86217332036812055, ...
    0.31876523985898081, -1.3076882963052734, -0.43359202230568356, 0.34262446653864992, ...
    3.5783969397257605, 2.7694370298848772, -1.3498869401565212, 3.0349234663318545, ...
    0.72540422494610557, -0.063054873189656191, 0.71474290382609584, -0.20496605829977463, ...
    -0.12414434821631191, 1.4896976077854649, 1.4090344898004792, 1.4171924134296139];
X = reshape(randn24, 5, 4);
% SciPy 1.16.0 kurtosis(fisher=False, bias=False), axis 0
scipyCorrected = [5.82677149077373 0.62754294668689203 4.513309308010335 -0.29621847269887747];
kCorrected = cobraKurtosis(X, 0);
assert(max(abs(kCorrected - scipyCorrected) ./ abs(scipyCorrected)) <= 1e-12);
% SciPy 1.16.0 kurtosis(fisher=False, bias=True), axis 1: a 5 x 1 column
scipyRows = [1.4039612034630597; 1.3494360136150287; 2.145977760559675; ...
    2.0220344722083774; 1.8735387881650811];
kRows = cobraKurtosis(X, 1, 2);
assert(isequal(size(kRows), [5 1]));
assert(max(abs(kRows - scipyRows) ./ scipyRows) <= 1e-12);

%% three-dimensional input, dim, vecdim and 'all' (documentation examples 3 and 4)

randn24 = [0.53766713954610001, 1.8338850145950865, -2.2588468610036481, 0.86217332036812055, ...
    0.31876523985898081, -1.3076882963052734, -0.43359202230568356, 0.34262446653864992, ...
    3.5783969397257605, 2.7694370298848772, -1.3498869401565212, 3.0349234663318545, ...
    0.72540422494610557, -0.063054873189656191, 0.71474290382609584, -0.20496605829977463, ...
    -0.12414434821631191, 1.4896976077854649, 1.4090344898004792, 1.4171924134296139, ...
    0.6714971336080805, -1.2074869226850378, 0.71723865132883846, 1.6302352891647292];
X = reshape(randn24, 4, 3, 2);
% default dim: 1 x 3 x 2; documentation and SciPy 1.16.0 kurtosis(axis=0)
k1 = cobraKurtosis(X);
assert(isequal(size(k1), [1 3 2]));
assert(max(abs(k1(:)' - [2.1350 1.7060 2.2789 1.0542 2.3278 2.0996])) <= 5e-5);
scipyK1 = [2.1349800358747317 1.7059911967844734 2.2788930693886411 ...
    1.054200427655025 2.3277960377977793 2.0995837529473325];
assert(max(abs(k1(:)' - scipyK1) ./ scipyK1) <= 1e-12);
% dim 2 (3 values per slice) gives 1.5 and dim 3 (2 values) gives 1 (documentation)
k2 = cobraKurtosis(X, 1, 2);
assert(isequal(size(k2), [4 1 2]) && max(abs(k2(:) - 1.5)) <= 5e-5);
k3 = cobraKurtosis(X, 1, 3);
assert(isequal(size(k3), [4 3]) && max(abs(k3(:) - 1)) <= 1e-12);
% 'all' and vecdim; documentation 2.8029, [1.9345 2.5877] and, over [2 3], a 4 x 1 column
kAll = cobraKurtosis(X, 1, 'all');
assert(isscalar(kAll) && abs(kAll - 2.8029) <= 5e-5);
assert(abs(kAll - 2.8028804330900083) <= 1e-12 * 2.8028804330900083);
kPage = cobraKurtosis(X, 1, [1 2]);
assert(isequal(size(kPage), [1 1 2]));
assert(max(abs(kPage(:)' - [1.9345 2.5877])) <= 5e-5);
scipyPage = [1.934529973311014 2.587697320620149];
assert(max(abs(kPage(:)' - scipyPage) ./ scipyPage) <= 1e-12);
kRow = cobraKurtosis(X, 1, [2 3]);
assert(isequal(size(kRow), [4 1]));
assert(max(abs(kRow - [3.8457; 1.4306; 1.7094; 2.3378])) <= 5e-5);
% 'all' as a string scalar
assert(isequal(cobraKurtosis(X, 1, "all"), kAll));

%% NaN values are ignored per column

D = [1 2; 2 NaN; 4 3; NaN 7; 10 5; 3 11];
% SciPy 1.16.0 kurtosis(fisher=False, axis=0, nan_policy='omit'), bias True and False
scipyBiased = [2.7880000000000003 2.03692626953125];
scipyCorrected = [6.152000000000001 3.147705078125];
assert(max(abs(cobraKurtosis(D) - scipyBiased) ./ scipyBiased) <= 1e-12);
assert(max(abs(cobraKurtosis(D, 0) - scipyCorrected) ./ scipyCorrected) <= 1e-12);
% a column of NaN only gives NaN
assert(isnan(cobraKurtosis([NaN; NaN; NaN; NaN])));

%% NaN results: constant slice, one value, X = [], dim beyond ndims, flag 0 with n < 4

% constant column: 0/0
kConst = cobraKurtosis([1 2; 1 5; 1 9]);
assert(isnan(kConst(1)) && ~isnan(kConst(2)));
% a scalar and the empty matrix
assert(isnan(cobraKurtosis(7)));
assert(isnan(cobraKurtosis([])));
% [] keeps its class; with a dim it is an ordinary empty array (1 x 0 along dim 1)
assert(isa(cobraKurtosis(single([])), 'single') && isnan(cobraKurtosis(single([]))));
assert(isequal(size(cobraKurtosis([], 1, 1)), [1 0]));
% a working dimension of size 1 gives NaN of size(X)
kBeyond = cobraKurtosis([1 2 3; 4 5 9], 1, 3);
assert(isequal(size(kBeyond), [2 3]) && all(isnan(kBeyond(:))));
% flag 0 needs at least 4 values per slice
assert(isnan(cobraKurtosis([1 4 6], 0)));
kFew = cobraKurtosis([1 2; 3 NaN; 4 6; 8 4; 2 1], 0);
assert(~isnan(kFew(1)) && ~isnan(kFew(2)));
kFew = cobraKurtosis([1 2; 3 NaN; 4 NaN; 8 4; 2 1], 0);
assert(~isnan(kFew(1)) && isnan(kFew(2)));
% an empty matrix that is not [] gives NaN per column
kEmpty = cobraKurtosis(zeros(0, 3));
assert(isequal(size(kEmpty), [1 3]) && all(isnan(kEmpty)));

%% unsupported flag and dim values raise an error

assert(verifyCobraFunctionError('cobraKurtosis', 'inputs', {[1 2 10], 2}, ...
    'testMessage', 'cobraKurtosis: flag must be 0 or 1.'));
assert(verifyCobraFunctionError('cobraKurtosis', 'inputs', {[1 2 10], 1, 1.5}, ...
    'testMessage', 'cobraKurtosis: dim must be distinct positive integers or ''all''.'));
assert(verifyCobraFunctionError('cobraKurtosis', 'inputs', {[1 2 10], 1, 'rows'}, ...
    'testMessage', 'cobraKurtosis: dim must be distinct positive integers or ''all''.'));

%% repeated dimensions and non-floating-point X are rejected

assert(verifyCobraFunctionError('cobraKurtosis', 'inputs', {magic(3), 1, [1 1]}, ...
    'testMessage', 'cobraKurtosis: dim must be distinct positive integers or ''all''.'));
assert(verifyCobraFunctionError('cobraKurtosis', 'inputs', {int8([1 2 10])}, ...
    'testMessage', 'cobraKurtosis: X must be a single or double array.'));
assert(verifyCobraFunctionError('cobraKurtosis', 'inputs', {[true false true]}, ...
    'testMessage', 'cobraKurtosis: X must be a single or double array.'));

%% parity with kurtosis when the Statistics and Machine Learning Toolbox is installed

if exist('kurtosis', 'file') && license('test', 'Statistics_Toolbox')
    X = [1 2 NaN; 4 3 3; 2 8 1; 9 1 7; 3 3 2];
    % same closed form, so the results agree to rounding
    assert(max(abs(cobraKurtosis(X) - kurtosis(X))) <= 1e-12);
    assert(max(abs(cobraKurtosis(X, 0) - kurtosis(X, 0))) <= 1e-12);
    assert(max(abs(cobraKurtosis(X, 1, 2) - kurtosis(X, 1, 2))) <= 1e-12);
else
    fprintf('skipped: Statistics and Machine Learning Toolbox not installed\n');
end

% change the directory
cd(currentDir)
