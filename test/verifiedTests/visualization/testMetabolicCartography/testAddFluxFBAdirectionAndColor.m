% The COBRAToolbox: testAddFluxFBAdirectionAndColor.m
%
% Purpose:
%     - addFluxFBAdirectionAndColor draws an FBA flux vector on a CellDesigner map: each map
%       reaction gets a width from its absolute flux relative to the largest absolute flux
%       (ratio 1 -> 8, (0.8, 1) -> 6, (0.5, 0.8] -> 5, (0.2, 0.5] -> 4, (1e-3, 0.2] -> 3,
%       below 1e-3 -> 1; reactions not in the model -> 1); reactions without flux become
%       LIGHTGRAY, all molecules WHITE, reactions with negative flux and their (base and
%       secondary) reactants TOMATO, then reactions with positive flux and their (base and
%       secondary) products DARKTURQUOISE. It also returns the reactions with non-zero flux
%       (ID, flux, width) and the map reactions with their widths.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the independent review (T027/T028) regraded both defects below to
%       wrong-result (a width that is not one of the documented bands on a valid flux
%       vector), so this file makes no assertion about the function. The wave 24 version of
%       this test (git history) checked hand-derived widths and colours on a four-reaction map
%       and is the starting point once the defects are fixed.
%
% Function under test:
%     src/visualization/metabolicCartography/addFluxFBAdirectionAndColor.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation on a hand-built map and model (rxns only); a hand-made flux
%     vector stands for the FBA solution, so no solver is used.
%
% Coverage exemptions:
%     every line - addFluxFBAdirectionAndColor is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers, independent review T027/T028). Before the
%     quarantine every executable line was reached.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A flux vector of zeros gives NaN widths
%       SEVERITY: wrong-result
%       TRIGGER: map.rxnName = {'R1'; 'R2'} (with the other documented map fields),
%         model.rxns = {'R1'; 'R2'}, fbaSolution.v = [0; 0];
%         map = addFluxFBAdirectionAndColor(map, model, fbaSolution)
%       OBSERVED: (R2025a, 2026-11-17) map.rxnWidth is {NaN; NaN}: line 53 divides 0 by
%         max(abs(v)) = 0, no band of lines 56-61 matches NaN, and line 74 stores NaN as the
%         width of every map reaction in the model
%       EXPECTED: width 1 for every reaction without flux, as lines 61 and 72 give for a ratio
%         below 1e-3 and for a reaction not in the model (fbaSolution.v is documented as any
%         n x 1 flux vector)
%       LINES: 53, 74
%     - DEFECT: A flux of exactly 1e-3 of the largest flux keeps width 0.001
%       SEVERITY: wrong-result
%       TRIGGER: the map and model above with fbaSolution.v = [1e-3; 1]
%       OBSERVED: (R2025a, 2026-11-17) map.rxnWidth is {0.0010; 8}: the bands of lines 60-61
%         are '> 1e-3' and '< 1e-3', so the ratio 1e-3 is in neither and keeps its raw value
%       EXPECTED: one of the band widths (1 or 3) for R1
%       LINES: 60-61
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Converted to the quarantine layout after the independent review (T027/T028), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddFluxFBAdirectionAndColor'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
