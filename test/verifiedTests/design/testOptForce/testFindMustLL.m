% The COBRAToolbox: testFindMustLL.m
%
% Purpose:
%     - findMustLL(model, minFluxesW, maxFluxesW, ...) runs the second step of OptForce: it
%       solves a bilevel MILP repeatedly to find the pairs of reactions of the MustLL set and
%       returns them with their positions in model.rxns, optionally writing a report, the
%       inputs and the sets to files. The function is quarantined for the defects below: this
%       file asserts nothing about it.
%
% Function under test:
%     src/design/optForce/findMustLL.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - solves MILPs (quarantined: no solver is used here).
%
% Coverage exemptions:
%     every line - findMustLL is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The positions of the second reaction of each pair are not returned
%       SEVERITY: wrong-result
%       TRIGGER: any call that finds a set; reproduction:
%         model = getDistributedModel('AntCore.mat'); model.c(strcmp(model.rxns, 'R75')) = 1;
%         lower bounds of EX_gluc, EX_o2, EX_so4, EX_nh3, EX_cit, EX_glyc set to -100;
%         model = changeObjective(model, 'EX_suc'); [minFluxesW, maxFluxesW] =
%         FVAOptForce(model, struct('rxnList', {{'R75'}}, 'rxnValues', 14, 'rxnBoundType', 'b'),
%         struct('rxnList', {{'R75', 'EX_suc'}}, 'rxnValues', [0, 155.55], 'rxnBoundType', 'bb'));
%         constrOpt = struct('rxnList', {{'EX_gluc', 'R75', 'EX_suc'}}, 'values', [-100, 0, 155.5]');
%         findMustLL(model, minFluxesW, maxFluxesW, 'constrOpt', constrOpt, 'excludedRxns',
%         exchangeRxns, 'printLevel', 0, 'printExcel', 0), exchangeRxns = the reactions named EX_*
%       OBSERVED: (R2025a, 2026-11-23, gurobi) with 'excludedRxns' set to the EX_* reactions
%         the 687 sets found all have posMustLL(:, 2) = 0, while mustLL(:, 2) holds the
%         second reaction (for example mustLL(1, :) = {'R37', 'R73'}, posMustLL(1, :) = [37 0]):
%         line 298 repeats line 297 and column 2 is never assigned
%       EXPECTED: posMustLL(i, :) holds the positions of both reactions of mustLL(i, :), as
%         the help text says (number of sets found x 2)
%       LINES: 297-298
%     - DEFECT: The documented default of excludedRxns (empty) is a function handle, so a call without it stops
%       SEVERITY: error
%       TRIGGER: the model and inputs above; findMustLL(model, minFluxesW, maxFluxesW, 'constrOpt',
%         constrOpt, 'printLevel', 0, 'printExcel', 0), with or without 'printReport', 0,
%         'keepInputs', 0
%       OBSERVED: (R2025a, 2026-11-23) "Brace indexing is not supported for variables of this
%         type." at line 249 (report on, the default); with 'printReport', 0, 'keepInputs', 0:
%         "Input A of class cell and input B of class function_handle must be the same class,
%         unless one is double." in intersect, called from line 425. Line 159 passes the
%         validation function as the default value (addParamValue has no validator argument here)
%       EXPECTED: excludedRxns defaults to an empty list (help text: "Default: empty") and a call
%         without it searches all reactions
%       LINES: 159, 248-250, 421, 425
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindMustLL'));
cd(fileDir);

% findMustLL is quarantined: the standard opening only, no requirement is declared because
% nothing is solved
prepareTest();

% change the directory
cd(currentDir)
