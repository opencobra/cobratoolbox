% The COBRAToolbox: testPlotMappingInfo.m
%
% Purpose:
%     - plotMappingInfo plots the mapping information of mgPipe: a heatmap of the number of
%       reactions of each organism in each individual, the metabolic diversity (number of
%       organisms against number of unique reactions, coloured by condition when an
%       information file is given) and a PCoA (Jaccard distances) of the reaction presence of
%       the individuals, and returns the PCoA coordinates. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): the heatmap shows only
%       the first four individuals (defect below), so no assertion about the function is
%       made.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/plotMappingInfo.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-built tables, invisible figures
%     and a temporary results folder.
%
% Coverage exemptions:
%     every line - plotMappingInfo is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The heatmap shows only the first four individuals
%       SEVERITY: wrong-result
%       TRIGGER: reacPat = cell2table({'org1', 1, 2, 3, 4, 5, 6; 'org2', 6, 5, 4, 3, 2, 1});
%         reacTab = cell2table({'s1', 1, 0, 1; 's2', 0, 1, 1; 's3', 1, 1, 0; 's4', 1, 0, 0;
%         's5', 0, 0, 1; 's6', 1, 1, 1}); plotMappingInfo([resDir filesep], [2 2 2 2 2 2],
%         reacPat, reacTab, [3 4 5 3 4 5], '', '-dpng')
%       OBSERVED: the image of the heatmap figure has CData of size 2-by-4: line 48 plots
%         columns 2:5 of reacPat (hard-coded), so individuals 5 and 6 are missing while the
%         x axis has six ticks.
%       EXPECTED: a 2-by-6 heatmap, one column per individual
%       LINES: 48
%     - DEFECT: The documented matrix inputs stop with an error
%       SEVERITY: error
%       TRIGGER: plotMappingInfo([resDir filesep], [2 2 2 2 2 2], [1 2 3 4 5 6; 6 5 4 3 2 1],
%         [1 0 1; 0 1 1; 1 1 0; 1 0 0; 0 0 1; 1 1 1], [3 4 5 3 4 5], '', '-dpng')
%       OBSERVED: MATLAB:table2cell:NonTable, Input argument must be a table. (line 48; the
%         PCoA lines 101 and 169 also call table2cell on reacTab)
%       EXPECTED: reacPat and reacTab are documented as a matrix and a binary matrix
%       LINES: 48, 101, 169
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPlotMappingInfo'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
