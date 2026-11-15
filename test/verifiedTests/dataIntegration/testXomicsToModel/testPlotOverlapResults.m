% The COBRAToolbox: testPlotOverlapResults.m
%
% Purpose:
%     - plotOverlapResults draws, for the outputs of compareXomicsModels, one heat map per
%       feature type (metabolites, reactions, genes) of the overlap proportions between models,
%       with the proportions as text labels, the model sizes on the diagonal and, when savepath
%       is given, a title and a saved .fig file. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): the documented optional input savepath
%       stops with an error after changing the working directory, so no assertion about the
%       function is made. Without savepath it draws the three heat maps on the inputs of the
%       defect below (3 axes, 12 text labels; R2025a, 2026-11-15).
%
% Function under test:
%     src/dataIntegration/XomicsToModel/analysis/plotOverlapResults.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model and no solver; a test would use two hand-built models
%     compared by compareXomicsModels and an invisible figure.
%
% Coverage exemptions:
%     every line - plotOverlapResults is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The optional input savepath cannot be used
%       SEVERITY: unusable-option
%       TRIGGER: plotOverlapResults(overlapResults, statistic, savepath) with
%         [overlapResults, statistic] = compareXomicsModels(models), models.mA = struct('mets',
%         {{'a'; 'b'; 'c'}}, 'rxns', {{'r1'; 'r2'}}, 'genes', {{'g1'}}), models.mB =
%         struct('mets', {{'b'; 'c'; 'd'; 'e'}}, 'rxns', {{'r2'; 'r3'}}, 'genes', {{'g1'; 'g2'}})
%         and savepath an existing folder fullfile(tempname, 'models_test')
%       OBSERVED: the call stops with "Unrecognized function or variable 'ax'."
%         (MATLAB:UndefinedFunction, line 64; R2025a, 2026-11-15): the axes handle ax exists
%         only in the local function plotHeatmapWithLabels; before the error, cd(savepath) has
%         changed the working directory of the session to savepath, and no file is written
%       EXPECTED: the figure saved as overlap_test.fig in savepath, with the working directory
%         of the session unchanged
%       LINES: 60-65
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPlotOverlapResults'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
