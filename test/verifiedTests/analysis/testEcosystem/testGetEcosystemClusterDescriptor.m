% The COBRAToolbox: testGetEcosystemClusterDescriptor.m
%
% Purpose:
%     - getEcosystemClusterDescriptor describes a cluster of grid points: for each reaction with
%       a defined (not NaN) representative state in that cluster it counts the clusters with a
%       different state (NaN counts as different), and returns a table with the label of the
%       state and the count, sorted by count in descending order with NaN counts last. This test
%       checks a hand-built matrix of representative codes for a numeric and a 'c<i>' cluster
%       ID, and every input error. Expected counts and orders are worked out by hand from the
%       documented rule; labels come from the table of qualitativeStateLabels.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the severity audit T009a raised the defect below (the documented output
%       variable is not produced), so this file makes no assertion about the function. The
%       checks described above are those of the wave 03 version of this test (git history),
%       to be restored once the defect is fixed.
%
% Function under test:
%     src/analysis/ecosystem/getEcosystemClusterDescriptor.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built matrices.
%
% Coverage exemptions:
%     every line - getEcosystemClusterDescriptor is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers, severity audit T009a). Before the quarantine the
%     test reached every executable line.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The status variable is named status_c<id>, not status as documented
%       SEVERITY: wrong-result
%       TRIGGER: getEcosystemClusterDescriptor([1 2; 0 0], {'a'; 'b'}, 1)
%       OBSERVED: VariableNames {'status_c1', 'diff'}, so descriptorTable.status errors
%       EXPECTED: a variable named status, as OUTPUT documents ("variables `status` (label of
%         the representative state in the cluster) and `diff`"); the documented access
%         descriptorTable.status fails, so the documented output is not produced (severity
%         audit T009a)
%       LINES: 67
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Converted to the quarantine layout after the severity audit 2026-11-15 (T009a).

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetEcosystemClusterDescriptor'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
