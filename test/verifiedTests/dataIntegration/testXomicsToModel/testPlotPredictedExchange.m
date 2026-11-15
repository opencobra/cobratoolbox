% The COBRAToolbox: testPlotPredictedExchange.m
%
% Purpose:
%     - plotPredictedExchange plots predicted exchange fluxes (a table with rxns, v, lb, ub and
%       labels or metNames) on a log-modulus scale, ordered from uptake to secretion, optionally
%       next to one or two other flux tables (v, lb, ub or mean, SD), and returns the plotted
%       reaction identifiers. The function is QUARANTINED (Constitution III-Defects, quarantine
%       in back-fill campaigns): the documented option saveFigures and the documented optional
%       input extraFluxes without otherFluxes stop with an error, so no assertion about the
%       function is made. Without them it plots the table of the defects below and returns
%       {'EX_a'; 'EX_b'; 'EX_c'} (R2025a, 2026-11-15).
%
% Function under test:
%     src/dataIntegration/XomicsToModel/metabolomics/plotPredictedExchange.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model and no solver; a test would use hand-built flux tables and an
%     invisible figure.
%
% Coverage exemptions:
%     every line - plotPredictedExchange is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The option saveFigures cannot be used
%       SEVERITY: unusable-option
%       TRIGGER: plotPredictedExchange(predictedFluxes, [], [], struct('saveFigures', 1)) with
%         predictedFluxes = table({'EX_a'; 'EX_b'; 'EX_c'}, [-2; 0; 3], [-5; -1; 0], [0; 1; 5],
%         {'A'; 'B'; 'C'}, 'VariableNames', {'rxns', 'v', 'lb', 'ub', 'metNames'}) and
%         predictedFluxes.Properties.Description = 'pred'
%       OBSERVED: after the plot is drawn the call stops with "Unrecognized function or
%         variable 'names'." (MATLAB:UndefinedFunction, line 421; R2025a, 2026-11-15); the
%         file name is built from a variable that is never set
%       EXPECTED: the figure saved as .fig and .png in the current directory
%       LINES: 420-423
%     - DEFECT: extraFluxes without otherFluxes stops with an error
%       SEVERITY: error
%       TRIGGER: plotPredictedExchange(predictedFluxes, [], extraFluxes) with predictedFluxes as
%         above and extraFluxes = table({'EX_a'; 'EX_b'; 'EX_c'}, [-1; 0; 2], [0.1; 0.1; 0.1],
%         'VariableNames', {'rxns', 'mean', 'SD'}), Description 'extra'
%       OBSERVED: "Unrecognized function or variable 'v2'." (MATLAB:UndefinedFunction, line 241;
%         R2025a, 2026-11-15): the limits and the NaN filter of the extra fluxes use the
%         transformed otherFluxes, which exist only when otherFluxes is given
%       EXPECTED: the predicted and the extra fluxes plotted (both inputs are documented as
%         optional)
%       LINES: 241-244
%     - DEFECT: predictedFluxes without lb and ub stops with an error
%       SEVERITY: limitation
%       TRIGGER: plotPredictedExchange(predictedFluxes(:, {'rxns', 'v', 'metNames'})) with
%         predictedFluxes as above
%       OBSERVED: "Unable to resolve the name 'measuredFluxes.mean'."
%         (MATLAB:undefinedVarOrClass, line 170; R2025a, 2026-11-15): the branch for tables
%         without bounds uses the undefined variables measuredFluxes and x
%       EXPECTED: the documented input lists lb and ub; without them, a plot without bounds or
%         an explicit error message
%       LINES: 170-173
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPlotPredictedExchange'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
