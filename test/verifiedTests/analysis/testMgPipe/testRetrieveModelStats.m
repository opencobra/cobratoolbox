% The COBRAToolbox: testRetrieveModelStats.m
%
% Purpose:
%     - retrieveModelStats counts the reactions and metabolites of each microbiome model of a
%       folder and the microbes present in each sample (abundance above 1e-7), returns a
%       table per model and a summary (mean, median, min, max), and plots the counts (with a
%       stratification file it also compares the groups). The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): without a
%       stratification file the plot is never produced (defect below), so no assertion
%       about the function is made.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/retrieveModelStats.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a test would use small hand-built models (createModel) saved to a temporary
%     folder and a hand-written abundance table, no solver.
%
% Coverage exemptions:
%     every line - retrieveModelStats is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The size plot is never produced without a stratification file
%       SEVERITY: wrong-result
%       TRIGGER: retrieveModelStats(modelPath, modelList, abunFilePath, 1, '-dpng') with
%         three models microbiota_model_samp_S1..S3 of 2, 3 and 4 reactions (and
%         metabolites) and an abundance table with the columns S1, S2, S3
%       OBSERVED: no figure is opened and no file MicrobiomeModel_Sizes.png is written
%         (MATLAB R2025a): the condition of line 108,
%         ~numel(unique(data(:,1)))==1 && ..., is parsed as (~numel(...)) == 1 and is false
%         whenever the data has a row, so lines 109-117 never run; modelStats (2, 3, 4
%         reactions and metabolites; 2, 1, 2 microbes) and summary (mean 3, 3, 1.6667;
%         median 3, 3, 2; min 2, 2, 1; max 4, 4, 2) are returned correctly
%       EXPECTED: the violin plot of reactions, metabolites and microbes saved in the figForm
%         format unless all values of a column are equal, as the comment of line 107 says
%       LINES: 108-117
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRetrieveModelStats'));
cd(fileDir);

% declare the requirements of this test: a Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system; the function is quarantined, so nothing below calls it
prepareTest();

% change the directory
cd(currentDir)
