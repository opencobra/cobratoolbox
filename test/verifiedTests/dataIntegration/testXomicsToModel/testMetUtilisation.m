% The COBRAToolbox: testMetUtilisation.m
%
% Purpose:
%     - metUtilisation(model, met, flux_v, printFig, param) builds a directed graph of the
%       reactions that produce and consume a metabolite (unweighted, weighted by one flux
%       vector, by a pair of flux vectors or by flux samples), a summary table of these
%       reactions and, optionally, a figure. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): every call without param.modelName
%       and param.saveFig errors, the default flux threshold is 1e6 instead of the documented
%       1e-6, and the flux-sampling branch reads a table variable that does not exist; no
%       assertion about the function is made.
%
% Function under test:
%     src/dataIntegration/XomicsToModel/analysis/metUtilisation.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a hand-built model of three reactions (createModel); no solver. The figure
%     branches would need invisible figures that are closed at the end.
%
% Coverage exemptions:
%     every line - metUtilisation is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every call without param.modelName and param.saveFig errors
%       SEVERITY: error
%       TRIGGER: model = createModel({'R1', 'R2', 'R3'}, {'n1', 'n2', 'n3'}, {'a[c] -> b[c]',
%         'b[c] -> c[c]', 'b[c] <=> d[c]'}, 'printLevel', 0);
%         [graphData, summary] = metUtilisation(model, 'b[c]', [], 0)
%       OBSERVED: (R2025a, 2026-11-23) "Unrecognized field name "modelName"." at line 721
%         after the graph and the summary were built; with param.modelName but no
%         param.saveFig the error moves to line 722
%       EXPECTED: both fields are optional (the help lists them as optional parameters and
%         the calls with fewer than five inputs never set them): no file name is built and no
%         figure is saved unless param.saveFig is true
%       LINES: 721-722
%     - DEFECT: The default flux threshold is 1e6, not the documented 1e-6
%       SEVERITY: wrong-result
%       TRIGGER: the model above; metUtilisation(model, 'b[c]', [1; 2; 3], 0)
%       OBSERVED: (R2025a, 2026-11-23) "Index exceeds array bounds." at line 378: with
%         param.treshold_v = 1e6 (line 124) no reaction is active (line 329), so the graph has
%         no node; the message printed just before says "Default values for flux treshold
%         (1e-6) and labels will be used"
%       EXPECTED: the threshold 1e-6 of the help and the message, so R1, R2 and R3 are
%         active
%       LINES: 124
%     - DEFECT: The flux-sampling branch reads the nonexistent table variable metRxns
%       SEVERITY: error
%       TRIGGER: the model above; param.modelName = 'm'; param.saveFig = false;
%         metUtilisation(model, 'b[c]', [ones(1, 5); ones(1, 5); zeros(1, 5)], 0, param)
%       OBSERVED: (R2025a, 2026-11-23) "Unrecognized table variable name 'metRxns'." at line
%         614: the summary table of line 225 has the variable rxns, not metRxns
%       EXPECTED: edge labels "mean +/- sd" for the reactions of the summary (summary.rxns)
%       LINES: 614, 616
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMetUtilisation'));
cd(fileDir);

% the function is quarantined: no requirement is declared and nothing calls it
prepareTest();

% change the directory
cd(currentDir)
