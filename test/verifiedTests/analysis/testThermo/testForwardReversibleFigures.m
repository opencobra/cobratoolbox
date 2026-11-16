% The COBRAToolbox: testForwardReversibleFigures.m
%
% Purpose:
%     - forwardReversibleFigures draws errorbar figures (DrGt and DrGt0 ranges, forward
%       probability from the normal cumulative distribution of DrGt0 with its uncertainty
%       at the given confidence level) of the qualitatively forward, quantitatively
%       reversible reactions: a master figure saved as fwdReversible.fig and .eps in the
%       current folder, and one figure for each non-empty subset (fixed negative or positive
%       DrGt0, uncertain negative or positive DrGt0, DrGt0 range spanning zero). The function
%       is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): the
%       figures of the two fixed-DrGt0 subsets stop with an error (defect below), so no
%       assertion about the function is made.
%
% Function under test:
%     src/analysis/thermo/directionalityReport/forwardReversibleFigures.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a test would use a hand-built three-reaction model with the thermodynamic
%     fields, a hand-built directions structure, invisible figures and a temporary folder;
%     no solver.
%
% Coverage exemptions:
%     every line - forwardReversibleFigures is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Reactions with a fixed DrGt0 stop the figures with an error
%       SEVERITY: error
%       TRIGGER: model.S = [1 -1 0; 0 1 -1] (createModel for ' -> A', 'A -> B', 'B -> ',
%         reactions R1-R3), SIntRxnBool = true(3, 1), DrGt0 = [-5; 1; -2], DrG0_Uncertainty
%         = [0; 2; 3], DrGt0Min = [-5; -1; -5], DrGt0Max = [-5; 3; 1], DrGtMin = [-10; -4;
%         -8], DrGtMax = [2; 6; 4], DrGtMean = (DrGtMin + DrGtMax) / 2; directions with the
%         nine forward2Reversible* fields false(3, 1) except forward2Reversible = true(3, 1),
%         forward2Reversible_bydGt0 = forward2Reversible_bydGt0Mid = [0; 1; 1] and
%         forward2Reversible_byConc_negative_fixed_DrG0 = [1; 0; 0]:
%         forwardReversibleFigures(model, directions); likewise with
%         forward2Reversible_byConc_positive_fixed_DrG0 = [1; 0; 0] instead
%       OBSERVED: MATLAB R2025a: 'Unrecognized function or variable 'P'.' at line 212
%         (negative fixed DrGt0) and 'Undefined function 'P' for input arguments of type
%         'logical'.' at line 327 (positive fixed DrGt0). P is never assigned: the forward
%         probability is held in forwardProbability (lines 84-93), which the other figures
%         use; lines 212, 230 and 283 (figure of the negative fixed class) and 327 and 381
%         (positive fixed class) use P.
%       EXPECTED: the figures of the two fixed-DrGt0 classes drawn with forwardProbability
%       LINES: 212, 230, 283, 327, 381
%     - DEFECT: The warning about extra NaN probabilities is garbled
%       SEVERITY: cosmetic
%       TRIGGER: the call above
%       OBSERVED: MATLAB R2025a: the warning of line 140 is shown as 'Extra category of NaN
%         P(' preceded by the warning 'Escaped character '\D' is not valid. See 'doc sprintf'
%         for supported special characters.': with an identifier, warning treats the TeX
%         text \Delta_{r}G^{\primem} as a format. Line 638 has the same text.
%       EXPECTED: the full message (the backslashes escaped or the text passed as an
%         argument of a %s format)
%       LINES: 140, 638
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testForwardReversibleFigures'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
