% The COBRAToolbox: testAddFluxFBA.m
%
% Purpose:
%     - addFluxFBA colours the map reactions that carry flux in an FBA solution (default
%       'RED') and sets every map reaction width from its flux relative to the largest
%       absolute flux (8, 6, 5, 4, 3, 1; 1 for reactions not in the model). The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): its third
%       output returns the widths of the input map, not the new widths (defect below); no
%       assertion about the function is made.
%
% Function under test:
%     src/visualization/metabolicCartography/addFluxFBA.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; a test would use a hand-built map, a model with
%     only rxns, and a hand-made flux vector in place of the FBA solution.
%
% Coverage exemptions:
%     every line - addFluxFBA is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: fluxMap holds the widths of the input map, not the flux widths
%       SEVERITY: wrong-result
%       TRIGGER: map.rxnName = {'R1'; 'R2'; 'R3'}; map.rxnWidth = {1; 1; 1};
%         map.rxnColor = {'X'; 'X'; 'X'}; model.rxns = {'R1'; 'R2'; 'R3'};
%         solution.v = [0; 5; -10]; [map2, flux3, fluxMap] = addFluxFBA(map, model, solution)
%       OBSERVED: (R2025a, 2026-11-16) map2.rxnWidth = {1; 4; 8} but fluxMap =
%         {'R1', 1; 'R2', 1; 'R3', 1}: line 88 reads map.rxnWidth (the input) instead of
%         map2.rxnWidth; addFluxFBAdirectionAndColor returns the new widths
%       EXPECTED: fluxMap = {'R1', 1; 'R2', 4; 'R3', 8}, the reactions with their width value
%         as the header says
%       LINES: 88
%     - DEFECT: A flux vector of zeros gives NaN widths
%       SEVERITY: limitation
%       TRIGGER: the call above with solution.v = [0; 0; 0]
%       OBSERVED: (R2025a, 2026-11-16) map2.rxnWidth = {NaN; NaN; NaN} (0 / 0 at line 62)
%       EXPECTED: width 1 for every reaction without flux
%       LINES: 62
%     - DEFECT: A flux of exactly 1e-3 of the largest flux keeps width 0.001
%       SEVERITY: cosmetic
%       TRIGGER: the call above with solution.v = [1e-3; 1; 0]
%       OBSERVED: (R2025a, 2026-11-16) map2.rxnWidth = {1.0000e-03; 8; 1}: the bands of
%         lines 69-70 are > 1e-3 and < 1e-3, so the ratio 1e-3 itself is in neither
%       EXPECTED: width 1 or 3
%       LINES: 69-70
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddFluxFBA'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
