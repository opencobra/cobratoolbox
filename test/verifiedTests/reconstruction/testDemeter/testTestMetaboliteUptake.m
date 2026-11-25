% The COBRAToolbox: testTestMetaboliteUptake.m
%
% Purpose:
%     - testMetaboliteUptake(model, microbeID, biomassReaction, database, inputDataFolder) is
%       a DEMETER test-suite function (its name starts with "test"; this file tests it). It
%       reads uptakeTable.txt from inputDataFolder, maps the metabolites set to 1 for
%       microbeID to their exchange reactions (a fixed table in the function, extended by
%       the global additionalUptakeRxns; several exchanges for some metabolites, e.g.
%       Menaquinone: EX_mqn7(e), EX_mqn8(e)), runs flux variability at 0% of the biomass
%       optimum with every exchange opened, and reports the metabolites that the model can
%       take up (TruePositives) and those it cannot (FalseNegatives).
%     - The function is quarantined for the defect below: this file asserts nothing about it.
%
% Function under test:
%     src/reconstruction/demeter/suite/tests/testMetaboliteUptake.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - flux variability (LP) on a hand-built model (once the function is released
%     from quarantine).
%
% Coverage exemptions:
%     Every line - testMetaboliteUptake is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: an uptake through a second or later exchange of a metabolite is reported in neither list
%       SEVERITY: wrong-result
%       TRIGGER: uptakeTable.txt marks Menaquinone 1 for the microbe and the model can take up
%       EX_mqn8(e) but not EX_mqn7(e) (the first exchange listed for Menaquinone); the same
%       holds for Niacin, Cobalamin and Pyridoxal, which also have several exchanges
%       OBSERVED: MATLAB R2025a, hand-built model (EX_mqn7(e) dead end, EX_mqn8(e) feeding the
%       biomass reaction; minimum flux of EX_mqn8(e) -1000): TruePositives {'Glycerol',
%       'Ammonium'} and FalseNegatives {'Hydrogen', 'Nitrate'} - Menaquinone appears in
%       neither list. Line 145 keeps only intersect(allEx{1}, flux), the first exchange, which
%       is empty although intersect(allEx, flux) is not (line 142)
%       EXPECTED: the help lists in TruePositives all metabolites (exchange reactions) that
%       the model can take up and that are taken up in vitro, so Menaquinone 8 (EX_mqn8(e))
%       should be a true positive; the comment before line 127 says that one consumed
%       exchange of the metabolite is enough
%       LINES: 145
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTestMetaboliteUptake'));
cd(fileDir);

% standard opening of a COBRA test; the function is quarantined, so nothing below calls it
prepareTest();

% change the directory
cd(currentDir)
