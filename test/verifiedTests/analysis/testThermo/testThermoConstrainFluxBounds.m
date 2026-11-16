% The COBRAToolbox: testThermoConstrainFluxBounds.m
%
% Purpose:
%     - thermoConstrainFluxBounds(model, confidenceLevel, DrG0_Uncertainty_Cutoff, printLevel)
%       classifies every internal reaction by its reconstruction bounds and, where the
%       uncertainty of its Gibbs energy estimate is below the cutoff, by the sign of DrGtMin and
%       DrGtMax (forward, reverse, reversible, equilibrium, uncertain); it sets lb_reconThermo
%       and ub_reconThermo from that classification and returns the direction vectors with the
%       probability that each reaction runs forward. Quarantined: no behaviour of
%       thermoConstrainFluxBounds is asserted until the defect below is fixed.
%
% Function under test:
%     src/analysis/thermo/thermoDirectionality/thermoConstrainFluxBounds.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - bound manipulation, no solver; a test would use a hand-built model with S, rxns,
%     lb, ub, SIntRxnBool, DrG0_Uncertainty, DrGtMin, DrGtMax and DrGt0.
%
% Coverage exemptions:
%     every line - thermoConstrainFluxBounds is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A Gibbs energy range with one bound at zero stops the call
%       SEVERITY: error
%       TRIGGER: model.S = sparse([-1 0; 1 -1]), rxns {'r1'; 'r2'}, lb [-10; 0], ub [10; 10],
%         SIntRxnBool [true; true], DrG0_Uncertainty [1; 1], DrGtMin [0; -5], DrGtMax [5; -1],
%         DrGt0 [2; -3], thermoConstrainFluxBounds(model, 0.95, 10, 0)
%       OBSERVED: MATLAB R2025a, 2026-11-16: the call prints 5 and 0 (lines 136-137) and stops
%         with "Some thermo reactions direction categories are not assigned." at line 138: a
%         reaction with DrGtMin = 0 < DrGtMax (or DrGtMin < 0 = DrGtMax) fits none of the
%         categories of lines 120-124, which use strict inequalities, so the sanity check of line
%         135 fails. With DrGtMin = [-1; -5] the call ends normally
%       EXPECTED: r1 classified (it cannot run forward with a negative Gibbs energy) and the
%         bounds returned, since the categories are meant to cover every internal reaction
%       LINES: 120-124, 135-138
%     - DEFECT: A confidence level outside the built-in table stops the call
%       SEVERITY: limitation
%       TRIGGER: the model above with DrGtMin = [-1; -5] and confidenceLevel 0.9
%       OBSERVED: MATLAB R2025a, 2026-11-16: "Unable to perform assignment because the left and
%         right sides have a different number of elements." at line 167: only -1, 0.5, 0.7, 0.95
%         and 0.99 are in the table of lines 62-66, any other value gives an empty tValue
%       EXPECTED: the documentation of confidenceLevel is empty; an error naming the supported
%         values
%       LINES: 68, 167
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testThermoConstrainFluxBounds'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
