% The COBRAToolbox: testPlotModelConsistency.m
%
% Purpose:
%     - plotModelConsistency draws, for each model result of checkModelProperties, a schematic
%       of the stoichiometric matrix coloured by stoichiometric, flux and thermodynamic flux
%       consistency, after flagging models whose fraction of stoichiometrically consistent rows
%       is below 60%. The function is quarantined for the defect below: the fraction is inverted,
%       so no model is ever flagged. This file only opens the test; it asserts nothing about the
%       function.
%
% Function under test:
%     src/reconstruction/modelGeneration/modelProperties/plotModelConsistency.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - the input is a structure of model results (S and Boolean property vectors); no
%     solver; draws a figure.
%
% Coverage exemptions:
%     every line - plotModelConsistency is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The fraction of stoichiometrically consistent rows is inverted
%       SEVERITY: wrong-result
%       TRIGGER: one model result with S of 10 rows and SConsistentMetBool true for 1 row (10%
%         consistent), the other Boolean vectors true, modelID 'toy';
%         plotModelConsistency(modelResults, {'sp', 'toy', 'f', 1, ''}, 1, 1, 2)
%       OBSERVED: (R2025a, 2026-11-16) the function prints "1 models that are sufficiently
%         stochiometrically consistent for plotting." and plots the model: line 75 computes
%         size(S, 1) / nnz(SConsistentMetBool) = 10, which is never below the tolerance 0.60, so
%         lines 77-78 are unreachable and no model is flagged or skipped (line 78 would also read
%         modelResults(j).modelID, a field the results do not have)
%       EXPECTED: the fraction nnz(SConsistentMetBool) / size(S, 1) = 0.1 < 0.60 flags the model
%         as not sufficiently consistent (comment at line 67 and the printed heading)
%       LINES: 75-78
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPlotModelConsistency'));
cd(fileDir);

% declare the requirements of this test. This test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
