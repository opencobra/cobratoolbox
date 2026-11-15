% The COBRAToolbox: testElementalMatrixToFormulae.m
%
% Purpose:
%     - elementalMatrixToFormulae writes the rows of an elemental composition matrix as
%       chemical formulae: duplicate element columns are added, C, H, N, O, P and S come first
%       and Charge last, a count of 1 is written without a number, counts are rounded to at
%       most dMax decimal places (default 12), a row of zeros gives 'Mass0' and a row with NaN
%       gives ''. The function is QUARANTINED (Constitution III-Defects, quarantine in
%       back-fill campaigns): with few decimal places, counts that the requested precision
%       can write are dropped, so no assertion about the function is made.
%
% Function under test:
%     src/reconstruction/modelGeneration/massBalance/elementalMatrixToFormulae.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would pass hand-built matrices.
%
% Coverage exemptions:
%     every line - elementalMatrixToFormulae is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A count equal to 10^-dMax or smaller is dropped, so dMax = 0 drops every count of 1
%       SEVERITY: wrong-result
%       TRIGGER: elementalMatrixToFormulae([1 4], {'C', 'H'}, 0) (methane, no decimal places);
%         elementalMatrixToFormulae([0.1 2], {'C', 'H'}, 1)
%       OBSERVED: {'H4'} and {'H2'}: line 52 keeps a count only when abs(count) > 10^(-dMax),
%         which is 1 for dMax = 0 and 0.1 for dMax = 1 (R2025a, 2026-11-15); with the default
%         dMax the same call gives {'CH4'}
%       EXPECTED: {'CH4'} and {'C0.1H2'} (dMax is documented as the maximum number of decimal
%         places, so 0 and 1 are valid and 1 and 0.1 are written exactly at those precisions)
%       LINES: 52
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testElementalMatrixToFormulae'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
