% The COBRAToolbox: testFindMustUU.m
%
% Purpose:
%     - findMustUU(model, minFluxesW, maxFluxesW, ...) runs the second step of OptForce: it
%       solves a bilevel MILP repeatedly to find the pairs of reactions of the MustUU set and
%       returns them with their positions in model.rxns, optionally writing a report, the
%       inputs and the sets to files. The function is quarantined for the defects below: this
%       file asserts nothing about it.
%
% Function under test:
%     src/design/optForce/findMustUU.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - solves MILPs (quarantined: no solver is used here).
%
% Coverage exemptions:
%     every line - findMustUU is quarantined for the defects below (feature
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
%         findMustUU(model, minFluxesW, maxFluxesW, 'constrOpt', constrOpt, 'excludedRxns',
%         excludedRxns, 'printLevel', 0, 'printExcel', 0), excludedRxns = the first order must sets
%         (findMustU, findMustL) and the EX_* reactions, as in the OptForce tutorial
%       OBSERVED: (R2025a, 2026-11-23, gurobi) with the tutorial inputs below mustUU = {'R30', 'R65';
%         'R31', 'R65'} but posMustUU = [30 0; 31 0] (expected [30 65; 31 65]): line 299 repeats
%         line 298 and column 2 is never assigned
%       EXPECTED: posMustUU(i, :) holds the positions of both reactions of mustUU(i, :), as
%         the help text says (number of sets found x 2)
%       LINES: 298-299
%     - DEFECT: The documented default of excludedRxns (empty) is a function handle, so a call without it stops
%       SEVERITY: error
%       TRIGGER: the model and inputs above; findMustUU(model, minFluxesW, maxFluxesW, 'constrOpt',
%         constrOpt, 'printLevel', 0, 'printExcel', 0), with or without 'printReport', 0,
%         'keepInputs', 0
%       OBSERVED: (R2025a, 2026-11-23) "Brace indexing is not supported for variables of this
%         type." at line 250 (report on, the default); with 'printReport', 0, 'keepInputs', 0:
%         "Input A of class cell and input B of class function_handle must be the same class,
%         unless one is double." in intersect, called from line 426. Line 159 passes the
%         validation function as the default value (addParamValue has no validator argument here)
%       EXPECTED: excludedRxns defaults to an empty list (help text: "Default: empty") and a call
%         without it searches all reactions
%       LINES: 159, 249-251, 422, 426
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindMustUU'));
cd(fileDir);

% findMustUU is quarantined: the standard opening only, no requirement is declared because
% nothing is solved
prepareTest();

% change the directory
cd(currentDir)
