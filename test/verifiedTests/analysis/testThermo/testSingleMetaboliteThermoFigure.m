% The COBRAToolbox: testSingleMetaboliteThermoFigure.m
%
% Purpose:
%     - singleMetaboliteThermoFigure is documented to draw a vertical error-bar figure of the
%       reactions involving the metabolite metAbbr (dGt0 and dGt ranges, the probability that
%       each reaction is forward) and saves it as fwdProbReverseGC.fig. A test would check the
%       figure contents for a hand-built model in a tempname folder.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): every call stops with an error (first defect below), so this file makes no
%       assertion about the function.
%
% Function under test:
%     src/analysis/thermo/directionalityReport/singleMetaboliteThermoFigure.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - hand-built thermodynamic model fields, a figure, no solver.
%
% Coverage exemptions:
%     every line - singleMetaboliteThermoFigure is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every call fails on the undefined variable directions
%       SEVERITY: error
%       TRIGGER: any call, e.g. singleMetaboliteThermoFigure(model, false, 'a') with model.S =
%       [-1 0; 1 -1], dGt0Min = [-1; -2], dGt0Max = [1; 2], dGtMin = [-3; -4], dGtMax = [3; 4]
%       OBSERVED: "Unable to resolve the name 'directions.ChangeForwardReversibleBool_dGfGC'." at
%       line 34 (MATLAB R2025a): directions is neither an input nor assigned in the function
%       EXPECTED: the documented figure of the reactions involving metAbbr
%       LINES: 34-38
%     - DEFECT: The metabolite argument metAbbr is never read
%       SEVERITY: unusable-option
%       TRIGGER: any value of metAbbr, e.g. singleMetaboliteThermoFigure(model, false, 'a')
%       OBSERVED: metAbbr appears only in the signature (line 1); the reactions are selected by
%       the fields of directions, not by the metabolite (read from the code)
%       EXPECTED: the figure restricted to the reactions involving the metabolite given by the
%       abbreviation, as the description says
%       LINES: 1
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSingleMetaboliteThermoFigure'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file needs no
% solver, MATLAB toolbox or particular operating system; the call is the standard opening of
% a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
