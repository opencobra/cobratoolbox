% The COBRAToolbox: testNormalizePoints.m
%
% Purpose:
%     - normalizePoints scales the sampled points and the bounds of model2 by the ratio of
%       model1 to model2 of either the median summed absolute flux through the shared
%       gene-associated reactions not listed as loop reactions (NormalizePointsParam 1) or the
%       optimal objective value (NormalizePointsParam 2), building rxnGeneMat when missing.
%     - Once the defect below is fixed, the test should use two createModel models with
%       hand-written points (ratio of medians derived by hand), check the scaled points and
%       bounds, the exclusion of loop reactions and of reactions without genes, the missing
%       rxnGeneMat, NormalizePointsParam 2 (ratio of objective values derived by hand), and the
%       documented defaults (NormalizePointsParam 1, loop reactions from FVA). Line 96 (the
%       error branch) cannot be reached: the indices of line 59-60 are those of reactions in
%       both models, never 0, and have equal lengths after the removals of lines 65-66.
%       Quarantined: no behaviour of normalizePoints is asserted until the defect below is
%       fixed; this file only opens the test.
%
% Function under test:
%     src/analysis/rumba/normalizePoints.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - NormalizePointsParam 2 solves two LPs (createModel models), every available LP
%     solver.
%
% Coverage exemptions:
%     every line - normalizePoints is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented defaults of NormalizePointsParam and LoopRxnsToIgnore are not
%         implemented, so these arguments cannot be omitted
%       SEVERITY: error
%       TRIGGER: normalizePoints(model1, model2) or normalizePoints(model1, model2, 1) with
%         model1 = createModel({'R1', 'R2'}, {'R1', 'R2'}, {' -> A', 'A -> '}, 'grRuleList',
%         {'g1', 'g2'}, 'printLevel', 0), model1.points = [1 2; 1 2], model2 = model1,
%         model2.points = [2 4; 2 4]
%       OBSERVED: (R2025a, gurobi, 2026-11-25) MATLAB:minrhs "Not enough input arguments." at
%         line 62 (LoopRxnsToIgnore) for both calls; NormalizePointsParam is never given its
%         default either (line 74 would fail next)
%       EXPECTED: the documented defaults: NormalizePointsParam = 1, LoopRxnsToIgnore =
%         reaction loops defined using FVA
%       LINES: 62-63, 74
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testNormalizePoints'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined and not called, so no
% solver is needed; the call is the standard opening of a COBRA test and the place where the
% requirement (an LP solver, for NormalizePointsParam = 2) is added when the defect is fixed
prepareTest();

% change the directory
cd(currentDir)
