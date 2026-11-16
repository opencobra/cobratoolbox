% The COBRAToolbox: testClassifyMoieties.m
%
% Purpose:
%     - classifyMoieties classifies each moiety (row of L) as Internal (conserved in the
%       open network: L * S = 0), Transitive (found only in primary metabolites) or
%       Integrative (all others), where secondary metabolites are those containing an
%       internal moiety. The test uses a hand-built network whose classification follows
%       directly from these definitions, a closed network, a network without internal
%       moieties, sparse inputs and an empty moiety matrix.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns; severity audit T009a): isSecondary is returned with a shape other than the
%       documented m x 1 (defect below), so no assertion about the function is made; the
%       checks described above are the plan for the test once the defect is resolved.
%
% Function under test:
%     src/analysis/topology/conservedMoieties/classifyMoieties.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built matrices.
%
% Coverage exemptions:
%     every line - classifyMoieties is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers, severity audit T009a)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: isSecondary is returned as a row vector, not m x 1
%       SEVERITY: wrong-result
%       TRIGGER: [~, isSecondary] = classifyMoieties([1 1 0 0; 0 0 1 0], [-1 0; 1 0; 0 -1; 0 0])
%       OBSERVED: size(isSecondary) is [1 4] (MATLAB R2025a): any(..., 1) returns a row
%       EXPECTED: an m x 1 Boolean vector, as the OUTPUTS documentation says. Severity audit
%         2026-11-15: OUTPUTS documents "isSecondary: `m x 1` Boolean vector"; any(..., 1) at
%         line 27 returns 1 x m and nothing in the code shows a row is intended
%       LINES: 27
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15; severity audit
%       2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testClassifyMoieties'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
