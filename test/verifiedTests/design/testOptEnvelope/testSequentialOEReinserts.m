% The COBRAToolbox: testSequentialOEReinserts.m
%
% Purpose:
%     - sequentialOEReinserts(modelOld, data, K, toDel, minP, midPoints, numTries, timeLimit)
%       reinserts the inactive reactions of data one by one (in numTries random orders) and keeps
%       as knockouts those whose reinsertion lowers the minimal target production; it returns
%       the knockouts of the main and of the mid envelopes. Helper of optEnvelope. The function
%       is quarantined for the defect below: this file asserts nothing about it.
%
% Function under test:
%     src/design/optEnvelope/sequentialOEReinserts.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - solves LPs (quarantined: no solver is used here).
%
% Coverage exemptions:
%     every line - sequentialOEReinserts is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented options toDel = 1 (genes) and toDel = 2 (enzymes) always stop
%       with an error
%       SEVERITY: unusable-option
%       TRIGGER: m = createModel({'EX_a','R1','R2','BIO','EX_p'}, {'','','','',''}, {' -> a[c]',
%         'a[c] -> b[c]','a[c] -> p[c]','b[c] -> ','p[c] -> '}, 'lowerBoundList', [0 0 0 0 0],
%         'upperBoundList', [10 1000 1000 1000 1000], 'grRuleList', {'','g1','g2','',''},
%         'printLevel', 0); minP = struct('bioID', 4, 'proID', 5);
%         [ko, midKo] = sequentialOEReinserts(m, struct(), [1 4 5], 1, minP, 0, 1, 60) (or toDel 2)
%       OBSERVED: (R2025a, 2026-11-25) toDel 1: "Unrecognized function or variable
%         'ActiveRxns'." at line 150 (ActiveRxns is a variable of minActiveRxns, not an input
%         here); toDel 2: 'Output argument "mainKnockouts" (and possibly others) not assigned a
%         value in the execution with "sequentialOEReinserts" function.'
%       EXPECTED: the gene knockouts (toDel 1), or an error that says the option is not
%         available, as optEnvelope does
%       LINES: 148-159
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSequentialOEReinserts'));
cd(fileDir);

% sequentialOEReinserts is quarantined: the standard opening only, no requirement is declared because
% nothing is solved
prepareTest();

% change the directory
cd(currentDir)
