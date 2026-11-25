% The COBRAToolbox: testTestSecretionProducts.m
%
% Purpose:
%     - testSecretionProducts(model, microbeID, biomassReaction, database, inputDataFolder) is
%       a DEMETER test-suite function (its name starts with "test"; this file tests it). It
%       reads secretionProductTable.txt from inputDataFolder, removes the reference columns,
%       adds the products of the global additionalSecretionRxns, runs flux variability on the
%       exchanges of the products set to 1 for microbeID and reports the products the model
%       can secrete (TruePositives) and those it cannot (FalseNegatives), as metabolite names.
%       The function is quarantined for the defect below: this file asserts nothing about it.
%
% Function under test:
%     src/reconstruction/demeter/suite/tests/testSecretionProducts.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - flux variability (LP) (quarantined: no solver is used here).
%
% Coverage exemptions:
%     every line - testSecretionProducts is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A product secreted only through a second or third exchange is in neither output list
%       SEVERITY: wrong-result
%       TRIGGER: a product with several exchanges (for example Folate: EX_fol(e), EX_5mthf(e),
%         EX_thf(e)) whose first exchange cannot carry flux while another can; reproduction in
%         a temporary folder sb: m = createModel({'EX_glc_D(e)'; 'GLCt'; 'bio1'; 'EX_fol(e)';
%         'EX_5mthf(e)'; 'MTHFsec'}, repmat({''}, 6, 1), {'glc_D[e] <=> '; 'glc_D[e] -> glc_D[c]';
%         'glc_D[c] -> '; 'fol[e] <=> '; '5mthf[e] <=> '; 'glc_D[c] -> 5mthf[e]'}, 'printLevel', 0);
%         db.metabolites = {'fol', 'Folate'; '5mthf', '5-Methyltetrahydrofolate'};
%         secretionProductTable.txt in sb = "MicrobeID<TAB>Folate" / "Microbe_A<TAB>1";
%         [tp, fn] = testSecretionProducts(m, 'Microbe_A', 'bio1', db, sb)
%       OBSERVED: (R2025a, 2026-11-25, gurobi) tp = 0x1 empty cell, fn = 0x0 empty cell,
%         although the FVA the function runs gives maxFlux = 0 for EX_fol(e) and 1000 for
%         EX_5mthf(e): line 146 keeps only intersect(allEx{1}, flux), which is empty when the
%         first exchange carries no flux, and line 144 is not reached because another
%         exchange carries flux
%       EXPECTED: Folate is a true positive: the help counts the secretions the model can
%         secrete, and the comment of lines 122-126 says that with several exchanges per
%         product at least one should carry flux
%       LINES: 142-147
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTestSecretionProducts'));
cd(fileDir);

% testSecretionProducts is quarantined: the standard opening only, no requirement is
% declared because nothing is solved
prepareTest();

% change the directory
cd(currentDir)
