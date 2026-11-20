% The COBRAToolbox: testFindRxnsInMap.m
%
% Purpose:
%     - findRxnsInMap returns the indices in map.rxnName of a list of reaction names and the
%       matching map.rxnID references; a single name given as a character vector returns its
%       first index, or 0 and {} when the name is not in the map. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): a single name found once
%       leaves the second output unassigned, and a list with a name absent from the map is an
%       error; no assertion about the function is made.
%
% Function under test:
%     src/visualization/metabolicCartography/findRxnsInMap.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use a hand-built map structure.
%
% Coverage exemptions:
%     every line - findRxnsInMap is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A single reaction name found once leaves the output rxnIDref unassigned
%       SEVERITY: error
%       TRIGGER: map.rxnName = {'A'; 'B'; 'A'}; map.rxnID = {'r1'; 'r2'; 'r3'};
%         [rxnID, rxnIDref] = findRxnsInMap(map, 'B')
%       OBSERVED: (R2025a, 2026-11-15) error MATLAB:unassignedOutputs 'Output argument
%         "rxnIDref" (and possibly others) not assigned a value in the execution with
%         "findRxnsInMap" function.': the character-vector branch sets rxnIDref only when the
%         name is absent or found more than once
%       EXPECTED: rxnID = 2 and rxnIDref = {'r2'}
%       LINES: 26-34
%     - DEFECT: A list with a reaction name absent from the map is an error
%       SEVERITY: error
%       TRIGGER: the same map; [rxnID, rxnIDref] = findRxnsInMap(map, {'B'; 'Z'})
%       OBSERVED: (R2025a, 2026-11-15) error MATLAB:badsubscript 'Array indices must be
%         positive integers or logical values.': ismember returns index 0 for 'Z' and line 24
%         indexes map.rxnID with it
%       EXPECTED: rxnID = [2; 0] without an error, as the single-name form returns 0 for a name
%         that is not in the map
%       LINES: 23-24
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindRxnsInMap'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
