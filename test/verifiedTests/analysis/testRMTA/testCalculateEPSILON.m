% The COBRAToolbox: testCalculateEPSILON.m
%
% Purpose:
%     - calculateEPSILON gives, for each reaction (row of a matrix of sampled fluxes, one
%       column per sample), the smallest flux change counted as significant by rMTA:
%       epsilon = tinv(0.95, n - 1) * std(row) / sqrt(n), raised to 'minimum' and set to 0
%       for reactions with rxnFBS == 0, or (option 'unique_epsilon') one common value, the
%       epsilon below which 70% of the changed reactions lie. This test checks both modes,
%       the 'minimum' option, case-insensitive option names and the input errors.
%     - Expected values are derived by hand: row standard deviations of small integer
%       samples (sqrt(5/3), sqrt(1/3), 0, sqrt(20/3)) and the Student t quantile
%       tinv(0.95, 3) = 2.3533634348018264 (SciPy stats.t.ppf(0.95, 3); standard t tables
%       give 2.353).
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the severity audit T009a raised the first defect below (a documented
%       input that fails when used), so this file makes no assertion about the function. The
%       checks described above are those of the wave 04 version of this test (git history),
%       to be restored once the defect is fixed.
%
% Function under test:
%     src/analysis/rMTA/calculateEPSILON.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built matrices.
%
% Coverage exemptions:
%     every line - calculateEPSILON is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers, severity audit T009a). Before the quarantine the
%     test reached every executable line.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: 'unique_epsilon' stops with an error when no reaction changes
%       SEVERITY: error
%       TRIGGER: calculateEPSILON([1 2 3 4; 0 0 1 1], [0; 0], 'unique_epsilon', true)
%       OBSERVED: error 'Array indices must be positive integers or logical values.'
%         (calculateEPSILON:51): int64(0 * 0.7) = 0 is used as an index
%       EXPECTED: epsilon = [0; 0] (no reaction is changed); the header documents rxnFBS as an
%         "Array that contains the desired change: Forward, Backward and Unchanged (+1;0;-1)"
%         and 'unique_epsilon' as an option, so an all-zero rxnFBS (no reaction changed) with
%         unique_epsilon true is a documented input that fails when used (severity audit T009a)
%       LINES: 51
%     - DEFECT: The documented codes of rxnFBS do not match the code
%       SEVERITY: cosmetic
%       TRIGGER: reading the help of calculateEPSILON
%       OBSERVED: the help lists "Forward, Backward and Unchanged (+1;0;-1)", i.e. 0 for a
%         backward change, while the code (and rMTA) treat rxnFBS == 0 as unchanged and -1 as
%         backward
%       EXPECTED: Forward, Backward and Unchanged (+1;-1;0)
%       LINES: 15-17
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Converted to the quarantine layout after the severity audit 2026-11-15 (T009a).

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCalculateEPSILON'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
