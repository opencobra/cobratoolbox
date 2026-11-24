% The COBRAToolbox: testFindEnthalpyChange.m
%
% Purpose:
%     - findEnthalpyChange(model, rxnList, rxnDir, printLevel) sums, for each reaction of
%       rxnList, the average bond enthalpies of the bonds broken minus those formed according
%       to its atom-mapped RXN file (0 for exchange reactions, NaN for missing or unbalanced
%       reactions) and the total mass of its substrates. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): a reaction whose
%       products have no bond errors; no assertion about the function is made.
%
% Function under test:
%     src/dataIntegration/chemoInformatics/reactions/findEnthalpyChange.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a hand-built model (createModel) and RXN files written to a tempname folder;
%     no solver.
%
% Coverage exemptions:
%     every line - findEnthalpyChange is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A reaction whose products have no bond errors
%       SEVERITY: error
%       TRIGGER: model = createModel({'R1', 'EX_h2', 'R3'}, {'', '', ''}, {'h2[c] -> 2 h[c]',
%         'h2[c] <=> ', 'h[c] -> q[c]'}, 'printLevel', 0); a folder holding R1.rxn (H2 -> H +
%         H, atoms mapped 1 and 2, one single bond in the substrate);
%         findEnthalpyChange(model, model.rxns, folder, 0)
%       OBSERVED: (R2025a, 2026-11-23) "Unrecognized function or variable 'matrixS_BBF'." at
%         line 227 (case 1 of the switch, bonds only in the substrates): the line was copied
%         from findBondsBrokenAndFormed and refers to a matrix this function never builds
%       EXPECTED: the H-H bond enthalpy of the bond table ('1 H H') for R1, NaN for R3 (no
%         file) and 0 for EX_h2 (exchange)
%       LINES: 227
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindEnthalpyChange'));
cd(fileDir);

% the function is quarantined: no requirement is declared and nothing calls it
prepareTest();

% change the directory
cd(currentDir)
