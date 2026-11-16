% The COBRAToolbox: testForwardProbablyReverseFigures.m
%
% Purpose:
%     - forwardProbablyReverseFigures draws a horizontal errorbar figure (DrGt and DrGt0
%       ranges, forward probability) of the qualitatively forward reactions that are probably
%       quantitatively reverse (forwardReversible_bydGt0RHS, _byConc_positive_fixed_DrG0,
%       _byConc_positive_uncertain_DrG0), labelled with model.rxn(n).officialName and
%       .equation, and saves it as fwdProbReverseGC.fig in the current folder. The function
%       is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       miliMolarStandard = true stops with an error (defect below), so no assertion about
%       the function is made.
%
% Function under test:
%     src/analysis/thermo/directionalityReport/forwardProbablyReverseFigures.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a test would use a hand-built three-reaction model with the thermodynamic
%     fields, invisible figures and a temporary folder; no solver.
%
% Coverage exemptions:
%     every line - forwardProbablyReverseFigures is quarantined for the defect below
%     (feature 20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: miliMolarStandard true stops with an error
%       SEVERITY: unusable-option
%       TRIGGER: model.S = [1 -1 0; 0 1 -1] (createModel for ' -> A', 'A -> B', 'B -> ',
%         reactions R1-R3), DrGt0Min = [-5; -1; -5], DrGt0Max = [-5; 3; 1], DrGt0Mean =
%         (DrGt0Min + DrGt0Max) / 2, DrGtMin = [-10; -4; -8], DrGtMax = [2; 6; 4], DrGtMean =
%         (DrGtMin + DrGtMax) / 2, dGt0Min = DrGt0Min, dGt0Max = DrGt0Max, dGtMin = DrGtMin,
%         dGtMax = DrGtMax, directions.forwardReversible_bydGt0RHS = [0; 1; 0],
%         .forwardReversible_byConc_positive_fixed_DrG0 = [0; 0; 0],
%         .forwardReversible_byConc_positive_uncertain_DrG0 = [0; 0; 1] (logical),
%         .forwardProbability = [NaN; 0.1; 0.05], rxn = struct('officialName', {'one', 'two',
%         'three'}, 'equation', {'A -> B', 'B -> C', 'C -> D'}):
%         forwardProbablyReverseFigures(model, true)
%       OBSERVED: MATLAB R2025a: the figure is drawn and saved, then the call stops with
%         'Unrecognized function or variable 'dGt0Min'.' at line 181: lines 180-183 restore
%         model.dGt0Min and dGt0Max from variables that are only assigned in the disabled
%         horizontal-bar block (lines 190-197, horizontal = 0). The same call with false runs.
%       EXPECTED: the call with miliMolarStandard = true completes (the vertical figure
%         changes nothing that needs restoring)
%       LINES: 180-183
%     - DEFECT: The structure array model.rxn is required but not documented
%       SEVERITY: limitation
%       TRIGGER: the model above without the field rxn: forwardProbablyReverseFigures(model,
%         false)
%       OBSERVED: MATLAB R2025a: 'Unrecognized field name "rxn".' at line 164; lines 164 and
%         169 label the reactions with model.rxn(n).officialName and model.rxn(n).equation,
%         which the header does not list (the header lists only S and the energy fields)
%       EXPECTED: the header lists model.rxn, or the labels come from rxnNames and the
%         formulas
%       LINES: 164, 169
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testForwardProbablyReverseFigures'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
