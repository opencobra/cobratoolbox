% The COBRAToolbox: testCobraCmdscale.m
%
% Purpose:
%     - cobraCmdscale is the plain-MATLAB replacement for cmdscale (Statistics and Machine
%       Learning Toolbox). This test checks the MathWorks documentation example (US cities:
%       eigenvalues and the first row of Y), a Euclidean configuration given as a pdist vector
%       (as in plotMappingInfo and mgSimResCollect) against NumPy, distance reconstruction,
%       similarity input, the no-positive-eigenvalue case, the errors for unsupported options
%       and invalid input, and (only where the toolbox is installed) parity with cmdscale up to
%       the sign of each column.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraCmdscale.m
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
fileDir = fileparts(which('testCobraCmdscale'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% MathWorks documentation example: distances between ten US cities (miles)

cities = [0 587 1212 701 1936 604 748 2139 2182 543
    587 0 920 940 1745 1188 713 1858 1737 597
    1212 920 0 879 831 1726 1631 949 1021 1494
    701 940 879 0 1374 968 1420 1645 1891 1220
    1936 1745 831 1374 0 2339 2451 347 959 2300
    604 1188 1726 968 2339 0 1092 2594 2734 923
    748 713 1631 1420 2451 1092 0 2571 2408 205
    2139 1858 949 1645 347 2594 2571 0 678 2442
    2182 1737 1021 1891 959 2734 2408 678 0 2329
    543 597 1494 1220 2300 923 205 2442 2329 0];
[Y, e] = cobraCmdscale(cities);
% documentation: e/1e6 = 9.5821 1.6868 0.0082 0.0014 0.0005 0.0000 0.0000 -0.0009 -0.0055
% -0.0355; Y is 10 x 6 with first row (x 1e3) -0.7188 0.1430 0.0351 -0.0012 -0.0074 0.0015.
% references/g1_stats.py (section cmdscale), NumPy eigh: the values below. Eigenvalues of a
% matrix with entries up to 1e7: 1e-9 relative on the six large ones; Y up to column sign
refE = [9.582144299216866 1.686820183464848 0.00815729843793028 0.0014328698965214483 0.0005086686860521361 2.514348577526226e-05] * 1e6;
assert(max(abs(e(1:6)' - refE) ./ refE) < 1e-9);
assert(isequal(size(Y), [10 6]) && isequal(size(e), [10 1]) && issorted(e, 'descend'));
refAbsY1 = [0.7187593806508998 0.14299426901268722 0.035102499014945845 0.0012249626418040576 0.007409477620688042 0.0015046461049934255] * 1e3;
assert(max(abs(abs(Y(1, :)) - refAbsY1) ./ refAbsY1) < 1e-8);
assert(isequal(round(e' / 1e6, 4), [9.5821 1.6868 0.0082 0.0014 0.0005 0.0000 0.0000 -0.0009 -0.0055 -0.0355]));

%% Euclidean configuration as a pdist vector: two dimensions reproduce the distances

points = [0 0; 3 0; 0 4; 1 1; 2 5];
distanceVector = cobraPdist(points, 'euclidean');
[Y, e] = cobraCmdscale(distanceVector);
% NumPy: e = 22.065507158694725, 6.734492841305284 and three values at rounding level; |Y|
refAbsY = [1.9172821044705775 1.3281676595508842; 2.113383277487348 1.6654162009650437; ...
    2.0741630428839932 1.0666994288618592; 0.9847878753041914 0.26493931503998536; 2.941290214378123 0.9943902024876841];
assert(abs(e(1) - 22.065507158694725) < 1e-12 && abs(e(2) - 6.734492841305284) < 1e-12);
assert(max(abs(e(3:5))) < 1e-12 && isequal(size(Y), [5 2]));
assert(max(abs(abs(Y) - refAbsY), [], 'all') < 1e-12);
% the configuration reproduces every distance
assert(max(abs(cobraPdist(Y, 'euclidean') - distanceVector)) < 1e-12);
% the full matrix and the vector give the same result (full matrix built without squareform,
% which is itself a Statistics and Machine Learning Toolbox function)
distanceMatrix = sqrt((points(:, 1) - points(:, 1)') .^ 2 + (points(:, 2) - points(:, 2)') .^ 2);
assert(max(abs(cobraCmdscale(distanceMatrix) - Y), [], 'all') < 1e-12);

%% similarity input (ones on the diagonal) is converted with sqrt(1 - S)

S = [1 0.5 0.2; 0.5 1 0.3; 0.2 0.3 1];
[YS, eS] = cobraCmdscale(S);
[YD, eD] = cobraCmdscale(sqrt(1 - S));
assert(isequal(YS, YD) && isequal(eS, eD));

%% no positive eigenvalue (all points equal): Y = zeros(n, 1)

[Y, e] = cobraCmdscale(zeros(4));
assert(isequal(Y, zeros(4, 1)) && all(e == 0));
% one point: an empty pdist vector
[Y, e] = cobraCmdscale(zeros(1, 0));
assert(isequal(Y, 0) && isequal(e, 0));

%% errors: the p argument and invalid D

assert(verifyCobraFunctionError('cobraCmdscale', 'inputs', {cities, 2}, ...
    'testMessage', 'cobraCmdscale: unsupported option ''p'' (only the syntax cobraCmdscale(D) is supported).'));
assert(verifyCobraFunctionError('cobraCmdscale', 'inputs', {{1}}, ...
    'testMessage', 'cobraCmdscale: D must be a real numeric matrix or pdist vector.'));
assert(verifyCobraFunctionError('cobraCmdscale', 'inputs', {[1 NaN 2]}, ...
    'testMessage', 'cobraCmdscale: D must not contain NaN.'));
assert(verifyCobraFunctionError('cobraCmdscale', 'inputs', {[1 2]}, ...
    'testMessage', 'cobraCmdscale: the length of a distance vector must be n*(n-1)/2.'));
assert(verifyCobraFunctionError('cobraCmdscale', 'inputs', {ones(2, 3)}, ...
    'testMessage', 'cobraCmdscale: D must be a square matrix or a pdist vector.'));
assert(verifyCobraFunctionError('cobraCmdscale', 'inputs', {[0 1; 2 0]}, ...
    'testMessage', 'cobraCmdscale: D must be symmetric.'));
assert(verifyCobraFunctionError('cobraCmdscale', 'inputs', {[2 1; 1 2]}, ...
    'testMessage', 'cobraCmdscale: D must have a zero diagonal (or ones for a similarity matrix).'));
assert(verifyCobraFunctionError('cobraCmdscale', 'inputs', {[0 -1; -1 0]}, ...
    'testMessage', 'cobraCmdscale: D must be non-negative.'));

%% parity with cmdscale (only where the Statistics and Machine Learning Toolbox is installed)

if exist('cmdscale', 'file') == 2 && license('test', 'Statistics_Toolbox')
    [Y, e] = cobraCmdscale(cities);
    [YToolbox, eToolbox] = cmdscale(cities);
    assert(max(abs(e - eToolbox)) <= 1e-9 * max(abs(eToolbox)));
    assert(isequal(size(Y), size(YToolbox)));
    % the same eig call gives the same signs on the same platform; compare up to column sign
    assert(max(abs(abs(Y) - abs(YToolbox)), [], 'all') <= 1e-8 * max(abs(YToolbox(:))));
    fprintf('parity with cmdscale: passed\n');
else
    fprintf('skipped: Statistics and Machine Learning Toolbox not installed\n');
end

% change the directory
cd(currentDir)
