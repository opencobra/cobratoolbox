% The COBRAToolbox: testCalculateGeneWeight.m
%
% Purpose:
%     - calculateGeneWeight gives each stoichiometrically consistent reaction a weight from
%       transcriptomic data: the minimum expression of the genes of each 'and' group (values
%       below Threshold set to 0), summed over the 'or' groups; reactions whose rule finds no
%       gene get the median weight. The function is QUARANTINED (Constitution III-Defects,
%       quarantine in back-fill campaigns): the median is never assigned when the model has
%       an inconsistent reaction (defect below); no assertion about the function is made.
%
% Function under test:
%     src/visualization/entropicFBA/calculateGeneWeight.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; a test would use a hand-built model (grRules,
%     SConsistentRxnBool) and hand-built expression tables.
%
% Coverage exemptions:
%     every line - calculateGeneWeight is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Reactions without expressed genes keep weight 0 when any reaction is inconsistent
%       SEVERITY: wrong-result
%       TRIGGER: model.grRules = {'g1 and g2'; ''; 'g3 or g1'; 'g4'};
%         model.SConsistentRxnBool = [true; true; true; false];
%         T = table({'g1'; 'g2'; 'g3'; 'g4'}, [5; 2; 7; 1], 'VariableNames', {'entrezID', 'val'});
%         calculateGeneWeight(model, T, 0)
%       OBSERVED: (R2025a, 2026-11-16) [2; 0; 12]: the test isEmptyFirstColumn(i) &
%         model.SConsistentRxnBool combines a scalar with the whole n x 1 vector, so the if is
%         false as soon as one reaction is inconsistent; with SConsistentRxnBool = true(4, 1)
%         the same call gives [2; 1.5; 12; 1] (median 1.5 assigned to the empty rule)
%       EXPECTED: [2; 2; 12], the empty rule replaced by the median of [2 0 12] as the comment
%         of the function says
%       LINES: 104
%     - DEFECT: A model without SConsistentRxnBool fails before the function's own check
%       SEVERITY: cosmetic
%       TRIGGER: a model with grRules and no SConsistentRxnBool field
%       OBSERVED: MATLAB's error "Unrecognized field name" at line 35; the check of line 39
%         and its message (which names grRules) are never reached
%       EXPECTED: the error of line 40 naming the missing field
%       LINES: 35, 39-41
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCalculateGeneWeight'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
