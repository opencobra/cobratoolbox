% The COBRAToolbox: testTransportReactionBool.m
%
% Purpose:
%     - transportReactionBool returns a logical n x 1 vector that is true for the reactions whose
%       substrates and products lie in more than one compartment (transport reactions); with
%       unidirectionalBool = 1 only those from the origin to the destination compartment, after
%       reactions that can only run backwards (lb < 0, ub <= 0) have been reoriented.
%       Quarantined: no behaviour of transportReactionBool is asserted until the defect below is
%       fixed.
%
% Function under test:
%     src/analysis/thermo/transport/transportReactionBool.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model look-up, no solver; a test would use a small model built with createModel.
%
% Coverage exemptions:
%     every line - transportReactionBool is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Origin and destination compartments filter the result when unidirectionalBool is 0
%       SEVERITY: wrong-result
%       TRIGGER: a createModel model with reactions r1 'a[e] -> a[c]', r2 'a[c] -> b[c]',
%         r3 'b[c] <=> b[m]', r4 'a[e] <=> ', r5 'c[e] <=> c[c]', r6 'a[e] + c[e] -> a[c] + c[c]',
%         lowerBoundList [0; 0; -10; -10; -10; 0], upperBoundList [10; 10; 10; 10; 0; 10];
%         transportReactionBool(model, 'c', 'e', 0)
%       OBSERVED: MATLAB R2025a, 2026-11-16: [1; 0; 0; 0; 1; 1]; the c <-> m transport r3 is
%         dropped because lines 65-68 keep only the reactions between the two given compartments
%         when unidirectionalBool is 0 (transportReactionBool(model) gives [1; 0; 1; 0; 1; 1])
%       EXPECTED: [1; 0; 1; 0; 1; 1], every transport reaction, since the help (lines 17-18) says
%         the origin and destination compartments are only relevant for unidirectional
%       LINES: 65-69
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTransportReactionBool'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
