% The COBRAToolbox: testFlux2json.m
%
% Purpose:
%     - flux2json(model, FBAtype, outputFolder) solves the model with optimizeCbModel ('FBA')
%       or entropicFluxBalanceAnalysis with MOSEK ('EFBA') and writes the reaction fluxes as a
%       JSON object {rxnId: flux} to data.json in outputFolder, for display in Escher.
%       Quarantined: no behaviour of flux2json is asserted until the defects below are fixed.
%
% Function under test:
%     src/visualization/EscherMap/flux2json.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - a hand-built createModel model solved by optimizeCbModel (LP solver); the file is
%     written to a tempname folder. The 'EFBA' branch needs MOSEK.
%
% Coverage exemptions:
%     every line - flux2json is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The optional FBAtype cannot be omitted
%       SEVERITY: error
%       TRIGGER: m = createModel({'R1';'R2'}, {'r1';'r2'}, {' -> A'; 'A -> '}, [], [0;0],
%         [10;10]); m.c = [0;1]; flux2json(m)
%       OBSERVED: (R2025a, 2026-11-25) error "Unrecognized function or variable 'solution'."
%         at line 51: without FBAtype no solution is computed
%       EXPECTED: the call succeeds with a default analysis, as the help lists FBAtype under
%         OPTIONAL INPUTS
%       LINES: 32-42, 51
%     - DEFECT: outputFolder is ignored and data.json is always written to the current folder
%       SEVERITY: unusable-option
%       TRIGGER: flux2json(m, 'FBA', outFolder) with m as above and outFolder an existing folder
%         other than pwd
%       OBSERVED: (R2025a, 2026-11-25) no data.json in outFolder; data.json written to pwd
%         with {"R1":10,"R2":10}: line 44 tests the undefined name outputFilename, so line 45
%         always overwrites outputFolder with pwd
%       EXPECTED: data.json written to outputFolder, as the help says
%       LINES: 44-47
%     - DEFECT: Fluxes of reactions whose id contains '[' or '-' are left out of the file
%       SEVERITY: wrong-result
%       TRIGGER: m3 = createModel({'EX_a[e]';'R-2';'3R';'R4'}, {'a';'b';'c';'d'}, {' -> A';
%         'A -> B'; 'B -> C'; 'C -> '}, [], [0;0;0;0], [10;10;10;10]); m3.c = [0;0;0;1];
%         flux2json(m3, 'FBA')
%       OBSERVED: (R2025a, 2026-11-25) data.json = {"x_3R":10,"R4":10}: EX_a[e] and R-2 are
%         missing; lines 70-73 change the key but never assign it
%       EXPECTED: one entry per reaction (the help: "A data.json file with the reaction
%         fluxes"), with the key made a valid field name as lines 70-77 intend
%       LINES: 70-73
%     - DEFECT: A reaction id with parentheses stops the function with an error
%       SEVERITY: error
%       TRIGGER: m4 = createModel({'EX_a(e)';'R4'}, {'a';'d'}, {' -> A'; 'A -> '}, [], [0;0],
%         [10;10]); m4.c = [0;1]; flux2json(m4, 'FBA') (ids as in ecoli_core_model)
%       OBSERVED: (R2025a, 2026-11-25) error "Invalid field name: 'x_EX_a(e)'." at line 77,
%         inside the catch block of line 69, which nothing protects
%       EXPECTED: the file is written with one entry per reaction
%       LINES: 76-77
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFlux2json'));
cd(fileDir);

% the standard opening of a COBRA test; the requirements of the full test (an LP solver) are
% declared here once the defects are fixed
prepareTest();

% change the directory
cd(currentDir)
