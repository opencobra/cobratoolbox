% The COBRAToolbox: testScore_KS.m
%
% Purpose:
%     - score_KS scores how well a set of mass distribution vectors (one row per MDV entry,
%       one column per sample) separates the samples labelled 0 from those labelled 1 in hilo:
%       for each row it takes the two-sample Kolmogorov-Smirnov p value p (cobraKstest2),
%       floors log(p) at -708 (about log(realmin)), weights it by 1 - exp(-std(row)/lambda)
%       and returns -sum. The test checks, by hand calculation from the p values of
%       cobraKstest2 (tested separately):
%         * the score of a separating row plus a row with identical groups (p = 1, score 0),
%           with the default lambda (0.02: weight 1 for a row with standard deviation 1.87);
%         * the weight 1 - exp(-1) when lambda equals the standard deviation of the row;
%         * a constant row (standard deviation 0, weight 0, p = 1) adds exactly 0;
%         * the floor -708 when the p value underflows to 0 (two separated groups of 1000).
%
% Function under test:
%     src/dataIntegration/fluxomics/score_KS.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built matrices.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testScore_KS'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the function loops with parfor, which starts a parallel pool when the Parallel Computing
% Toolbox is installed and its AutoCreate preference is on; turn AutoCreate off for this
% session only (temporary value) so that the loop runs in the client, and restore it at the end
hasParallelSettings = ~isempty(ver('parallel'));
if hasParallelSettings
    matlabSettings = settings;
    autoCreateSetting = matlabSettings.parallel.client.pool.AutoCreate;
    hadTemporaryAutoCreate = hasTemporaryValue(autoCreateSetting);
    if hadTemporaryAutoCreate
        savedAutoCreate = autoCreateSetting.TemporaryValue;
    end
    autoCreateSetting.TemporaryValue = false;
end

% the score is a short sum of logarithms of p values; rounding is below 1e-14, so 1e-12
% separates rounding from a real change
tol = 1e-12;

%% default lambda: a separating row scores -log(p), a row with identical groups scores 0

% row 1: group 0 = [1 2 3], group 1 = [4 5 6] (completely separated);
% row 2: both groups are [1 2 3] (KS statistic 0, p = 1, log(p) = 0)
mdv = [1 2 3 4 5 6; 1 2 3 1 2 3];
hilo = [0 0 0 1 1 1];
[~, pSeparated] = cobraKstest2([1 2 3], [4 5 6]);
[~, pIdentical] = cobraKstest2([1 2 3], [1 2 3]);
assert(abs(pIdentical - 1) < tol && pSeparated > 0 && pSeparated < 1);
% std(1:6) = sqrt(3.5) = 1.87 and std([1 2 3 1 2 3]) = 0.89, so with lambda = 0.02 both
% weights 1 - exp(-std / 0.02) equal 1 in double precision
expectedScore = -(log(pSeparated) + log(pIdentical));
assert(abs(score_KS(mdv, hilo) - expectedScore) < tol);
assert(abs(score_KS(mdv, hilo, 0.02) - expectedScore) < tol);
% the labels may be logical
assert(abs(score_KS(mdv, logical(hilo)) - expectedScore) < tol);

%% lambda equal to the standard deviation of the row gives the weight 1 - exp(-1)

rowStd = std([1 2 3 4 5 6]);
assert(abs(score_KS([1 2 3 4 5 6], hilo, rowStd) + log(pSeparated) * (1 - exp(-1))) < tol);

%% a constant row (standard deviation 0, identical groups) adds exactly 0, not NaN

assert(abs(score_KS([7 7 7 7 7 7; 1 2 3 4 5 6], hilo) - (-log(pSeparated))) < tol);

%% a p value that underflows to 0 is floored at log(p) = -708

% two separated groups of 1000 samples: the p value is below realmin and returns 0
[~, pUnderflow] = cobraKstest2(1:1000, 1001:2000);
assert(pUnderflow == 0);
% the floor is exact; the weight is 1 (std of 1:2000 = 577)
assert(score_KS(1:2000, [zeros(1, 1000), ones(1, 1000)]) == 708);

% restore the parallel pool preference
if hasParallelSettings
    if hadTemporaryAutoCreate
        autoCreateSetting.TemporaryValue = savedAutoCreate;
    else
        clearTemporaryValue(autoCreateSetting);
    end
end

% change the directory
cd(currentDir)
