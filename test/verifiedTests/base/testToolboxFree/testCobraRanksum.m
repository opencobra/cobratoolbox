% The COBRAToolbox: testCobraRanksum.m
%
% Purpose:
%     - cobraRanksum is the plain-MATLAB replacement for ranksum (Statistics and Machine
%       Learning Toolbox). This test checks the MathWorks documentation example (mileage,
%       exact with a tie, p = 0.0043), the exact method with ties and unequal sizes, the exact
%       method without ties, the approximate method with ties and zeros (as in
%       performStatisticalAnalysis), the default method rule, NaN removal, the all-tied case,
%       the stats fields of both methods, 'alpha', the errors for unsupported options, and
%       (only where the toolbox is installed) parity with ranksum, including which sample's
%       rank sum is reported when the first sample is larger (UNCONFIRMED in the semantics note).
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraRanksum.m
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
fileDir = fileparts(which('testCobraRanksum'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

relativeError = @(value, reference) abs(value - reference) ./ abs(reference);

%% MathWorks documentation example: mileage, exact method (default), p = 0.0043, ranksum = 21.5

mileageX = [33.3 33.4 32.9 32.6 32.5 33.0];
mileageY = [34.5 34.8 33.8 33.4 33.7 33.9];
[p, h, stats] = cobraRanksum(mileageX, mileageY);
% references/g1_stats.py (section ranksum), SciPy 1.16.3 permutation_test over mid-ranks with
% full enumeration: p = 4/924 = 0.004329004329004329. Counts are exact integers, so the ratio is
% exact up to one rounding
assert(abs(p - 4 / 924) < 1e-15 && h == true && islogical(h));
assert(isequal(fieldnames(stats), {'ranksum'}) && stats.ranksum == 21.5);

%% exact method with ties and unequal sizes (first sample larger)

% SciPy 1.16.3 permutation_test (full enumeration): p = 0.4 (rank sum of x 37). The reported
% rank sum is the smaller sample's (y: ranks 3 + 5 + 10 + 11 = 29), as in MathWorks' R14
% source; the current release is UNCONFIRMED (see the parity section)
[p, ~, stats] = cobraRanksum([1 2 2 5 7 7 8], [2 3 9 10]);
assert(abs(p - 0.4) < 1e-14 && stats.ranksum == 29);
% swapping the samples reports the same (smaller) sample
[pSwapped, ~, statsSwapped] = cobraRanksum([2 3 9 10], [1 2 2 5 7 7 8]);
assert(pSwapped == p && statsSwapped.ranksum == 29);

%% exact method without ties, explicit and by the default rule

% SciPy 1.16.3 mannwhitneyu(method='exact'): p = 0.09073426573426574 (rank sum of x 60; the reported
% rank sum is that of the smaller sample y: 16*17/2 - 60 = 76)
xNoTies = [0.8 1.9 2.4 3.1 4.6 5.2 6.7 7.3 8.8];
yNoTies = [2.2 4.1 5.9 9.4 10.6 11.1 12.5];
[p, ~, stats] = cobraRanksum(xNoTies, yNoTies, 'method', 'exact');
assert(relativeError(p, 0.09073426573426574) < 1e-13 && stats.ranksum == 76);
% default rule: min(9, 7) < 10 and 16 < 20, so exact
assert(cobraRanksum(xNoTies, yNoTies) == p);

%% approximate method with ties and zeros (performStatisticalAnalysis, retrieveModelStats)

% references/g1_stats.py (section ranksum): hand formula with tie and continuity correction,
% rank sum of xa 465.5 with z = -1.004507906357184, p = 0.315133862251911; SciPy mannwhitneyu
% (asymptotic, continuity) p = 0.3151338622519111. xa is the larger sample (25 vs 14), so the
% reported rank sum is that of ya, 40*39/2 - 465.5 = 314.5, with z = +1.004507906357184 (same
% sigma; UNCONFIRMED orientation, see the parity section). Normal cdf through erfc: 1e-12 relative
xa = [0.0 0.0 0.0 0.0 0.0 0.0 0.9 1.2 0.5 1.2 1.6 3.1 2.0 0.8 1.0 -0.0 0.2 0.5 0.2 1.8 0.1 2.2 2.1 1.1 1.9]';
ya = [0.0 0.0 0.0 2.3 1.7 0.5 1.1 2.6 2.6 0.4 2.0 1.7 0.6 1.7]';
[p, h, stats] = cobraRanksum(xa, ya, 'method', 'approximate');
assert(isequal(fieldnames(stats), {'zval'; 'ranksum'}));
assert(stats.ranksum == 314.5 && relativeError(stats.zval, 1.004507906357184) < 1e-12);
assert(relativeError(p, 0.315133862251911) < 1e-12 && h == false);
% default rule: min(25, 14) >= 10, so approximate; NaN values are removed first
[pDefault, ~, statsDefault] = cobraRanksum([xa; NaN], [NaN; ya]);
assert(pDefault == p && statsDefault.zval == stats.zval);
% row vectors (compareTwoSamplesStat) give the same result; the smaller sample first gives the
% same rank sum and z
assert(cobraRanksum(xa', ya', 'method', 'approximate') == p);
[pSwapped, ~, statsSwapped] = cobraRanksum(ya, xa, 'method', 'approximate');
assert(pSwapped == p && statsSwapped.ranksum == 314.5 && statsSwapped.zval == stats.zval);

%% all values tied: sigma = 0, so z and p are NaN (performStatisticalAnalysis sets p = 1)

[p, h, stats] = cobraRanksum(zeros(12, 1), zeros(15, 1), 'method', 'approximate');
assert(isnan(p) && isnan(stats.zval) && h == false);

%% 'alpha' and option names are case-insensitive

[~, h] = cobraRanksum(mileageX, mileageY, 'Alpha', 0.001, 'METHOD', 'Exact');
assert(h == false);

%% errors: 'tail', odd argument count, bad method value, non-vector input

assert(verifyCobraFunctionError('cobraRanksum', 'inputs', {mileageX, mileageY, 'tail', 'left'}, ...
    'testMessage', 'cobraRanksum: unsupported option ''tail'' (options are name-value pairs ''method'' and ''alpha'').'));
assert(verifyCobraFunctionError('cobraRanksum', 'inputs', {mileageX, mileageY, 0.05}, ...
    'testMessage', 'cobraRanksum: unsupported option ''double'' (options are name-value pairs ''method'' and ''alpha'').'));
assert(verifyCobraFunctionError('cobraRanksum', 'inputs', {mileageX, mileageY, 'method', 'oops'}, ...
    'testMessage', 'cobraRanksum: unsupported option ''method'' value ''oops'' (use ''exact'' or ''approximate'').'));
assert(verifyCobraFunctionError('cobraRanksum', 'inputs', {1:1000, 1:1000, 'method', 'exact'}, ...
    'testMessage', 'cobraRanksum: the exact method is too large for these samples; use ''method'', ''approximate''.'));
assert(verifyCobraFunctionError('cobraRanksum', 'inputs', {magic(3), mileageY}, ...
    'testMessage', 'cobraRanksum: x and y must be numeric vectors.'));

%% parity with ranksum (only where the Statistics and Machine Learning Toolbox is installed)

if exist('ranksum', 'file') == 2 && license('test', 'Statistics_Toolbox')
    % the first sample is the larger one: settles whose rank sum MathWorks reports
    [p, ~, stats] = cobraRanksum(xa, ya, 'method', 'approximate');
    [pToolbox, ~, statsToolbox] = ranksum(xa, ya, 'method', 'approximate');
    assert(abs(p - pToolbox) <= 1e-12 * pToolbox);
    assert(stats.ranksum == statsToolbox.ranksum && abs(stats.zval - statsToolbox.zval) <= 1e-12 * abs(statsToolbox.zval));
    [p, ~, stats] = cobraRanksum([1 2 2 5 7 7 8], [2 3 9 10]);
    [pToolbox, ~, statsToolbox] = ranksum([1 2 2 5 7 7 8], [2 3 9 10]);
    assert(abs(p - pToolbox) <= 1e-12 && stats.ranksum == statsToolbox.ranksum);
    fprintf('parity with ranksum: passed\n');
else
    fprintf('skipped: Statistics and Machine Learning Toolbox not installed\n');
end

% change the directory
cd(currentDir)
