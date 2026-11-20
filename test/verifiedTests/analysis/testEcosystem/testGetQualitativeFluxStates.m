% The COBRAToolbox: testGetQualitativeFluxStates.m
%
% Purpose:
%     - getQualitativeFluxStates translates flux ranges [min, max] from flux variability
%       analysis into qualitative state codes (-3 '-', -2 '--', -1 '-0', 0 '0', 1 '0+', 2 '++',
%       3 '+', 4 '-+', 5 'err'), treating |x| <= delta and |max - min| <= delta as zero. The
%       function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       the zero band is applied inconsistently, so with delta = 0 (allowed: "non-negative
%       scalar") or at the band edge the states -1, -3 and 3 are wrong (defect below). No
%       assertion about the function is made.
%
% Function under test:
%     src/analysis/ecosystem/getQualitativeFluxStates.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-built flux ranges.
%
% Coverage exemptions:
%     every line - getQualitativeFluxStates is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Zero band applied inconsistently to the maximum and to max - min
%       SEVERITY: wrong-result
%       TRIGGER: getQualitativeFluxStates([-1 2 -2], [0 2 -2], 0); with the default band
%         getQualitativeFluxStates(-1, 1e-9); and at the edge of a band that is exact in
%         binary, getQualitativeFluxStates([-1 2 -2.5], [0.5 2.5 -2], 0.5)
%       OBSERVED: (R2025a, 2026-11-17) [5 2 -2] ({'err', '++', '--'}) for delta = 0, 5 for the
%         default band, and [5 2 -2] for delta = 0.5 (just inside that band,
%         getQualitativeFluxStates([-1 2 -2.5], [0.4 2.4 -2.1], 0.5) gives [-1 3 -3]): the
%         state -1 requires max < delta (not <= delta) and the fixed states -3 and 3 require
%         |max - min| < delta (not <= delta), so with delta = 0 they cannot occur. A
%         difference of exactly 1e-9 is hard to produce in double precision ((2 + 1e-9) - 2
%         is 1.000000082740371e-09), so the edge of the fixed states is shown with delta = 0.5
%       EXPECTED: [-1 3 -3] ({'-0', '+', '-'}), -1 and [-1 3 -3]: the documented table treats
%         |x| <= delta, and a difference max - min within delta, as zero
%       LINES: 68, 75, 85
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetQualitativeFluxStates'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
