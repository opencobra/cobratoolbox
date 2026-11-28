% The COBRAToolbox: testCheckEffectRxnKO.m
%
% Purpose:
%     - checkEffectRxnKO finds the reactions of a set of genes (findRxnsFromGenes) and, for
%       each sample to test, blocks one reaction at a time in the sample's modelMin and
%       records the FBA objective and status. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): the result holds rows that belong to
%       no reaction, and only the last sample's results are kept, so no assertion about the
%       function is made.
%
% Function under test:
%     src/dataIntegration/metabotools/checkEffectRxnKO.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - an LP solver and a toy model would be needed.
%
% Coverage exemptions:
%     every line - checkEffectRxnKO is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Fewer than six reactions give extra result rows that belong to no reaction
%       SEVERITY: wrong-result
%       TRIGGER: model = createModel({'R1'; 'R2'; 'R3'; 'R4'}, {'r1'; 'r2'; 'r3'; 'r4'},
%         {' -> A'; 'A -> B'; 'A -> B'; 'B -> '}, 'grRuleList', {''; 'g1'; 'g2'; 'g1 or g3'});
%         model.lb = zeros(4, 1); model.ub = 10 * ones(4, 1); model.c = [0; 0; 0; 1];
%         R.S1.modelMin = model; [FBA_Rxns_KO, ListResults] = checkEffectRxnKO({'S1'}, NaN,
%         {'g1'}, {'S1'}, R)
%       OBSERVED: (R2025a, 2026-11-25, gurobi) FBA_Rxns_KO has 7 rows: the header, R2 (f 10,
%         stat 1), R4 (f 0, stat 1) and four rows with an empty reaction and the fill value NaN;
%         ListResults is 2 x 6, and the loop of line 35 runs over length(ListResults) = 6, so
%         ListResults{i} also takes the formulas and the cells of columns 2 and 3
%       EXPECTED: one row per reaction of the genes (2 rows after the header), in the order of
%         ListResults, as the help documents
%       LINES: 35
%     - DEFECT: With several samples to test only the last sample's results are returned
%       SEVERITY: wrong-result
%       TRIGGER: the model of the first entry with R.S1.modelMin = model, R.S2.modelMin = the
%         same model with ub(3) = 4; checkEffectRxnKO({'S1'; 'S2'}, 100, {'g1'; 'g2'}, {'S1';
%         'S2'}, R)
%       OBSERVED: (R2025a, 2026-11-25, gurobi) rows R2 (f 4), R4 (f 0), R3 (f 10): the
%         objective 10 of S1 with R2 blocked is overwritten by the 4 of S2, because n = 1
%         (line 23) is never advanced, so every sample writes the same columns
%       EXPECTED: the results of every sample in samples_to_test, which the function loops
%         over (line 27)
%       LINES: 23, 39-41, 44-45
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCheckEffectRxnKO'));
cd(fileDir);

% declare the requirements of this test; nothing that calls checkEffectRxnKO runs while it
% is quarantined, so no solver is required yet
prepareTest();

% change the directory
cd(currentDir)
