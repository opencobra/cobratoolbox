% The COBRAToolbox: testPlotMetaboliteProducersConsumers.m
%
% Purpose:
%     - plotMetaboliteProducersConsumers(propertiesFolder, infoFilePath, reconVersion,
%       'metsToAnalyze', mets, 'metCategory', name) lists the strains that take up, secrete
%       or internally produce each metabolite (ComputedFluxes/uptakeFluxes_,
%       secretionFluxes_ and internalProduction_<reconVersion>.txt), writes the lists and
%       plots the strains and taxa enriched in each metabolite (bar and pie charts). The
%       function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): on MATLAB R2020a and newer it raises an error for flux files with
%       numeric values; no assertion about the function is made.
%
% Function under test:
%     src/reconstruction/demeter/src/properties/plotMetaboliteProducersConsumers.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would write the three flux files and the
%     information table in a temporary folder.
%
% Coverage exemptions:
%     every line - plotMetaboliteProducersConsumers is quarantined for the defects below
%     (feature 20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: the header row of a numeric flux file is dropped by readtable
%       SEVERITY: error
%       TRIGGER: in folder d, ComputedFluxes/uptakeFluxes_v.txt, secretionFluxes_v.txt and
%         internalProduction_v.txt, each {'', 'EX_glc_D(e)', 'EX_lac_L(e)'; 's1', -1, 0;
%         's2', 0, -2} written tab-separated; info3.txt with MicrobeID and taxon columns for
%         s1-s3; plotMetaboliteProducersConsumers(d, 'd/info3.txt', 'v', 'metsToAnalyze',
%         {'glc_D', 'lac_L'})
%       OBSERVED: (R2025a, 2026-11-15) error "Cell elements must be character vectors." at
%         line 79: readtable(..., 'ReadVariableNames', false) of line 74 detects the header
%         line and skips it, so data(1, :) is {'s1', -1, 0} and strrep fails on the numbers;
%         the current folder is left at d/Figures_Metabolites/uptakeFluxes
%       EXPECTED: the metabolite header kept as row 1 (as readInputTableForPipeline returns
%         it) and the lists and plots written
%       LINES: 74-75, 79
%     - DEFECT: the default metsToAnalyze analyses no metabolite
%       SEVERITY: unusable-option
%       TRIGGER: plotMetaboliteProducersConsumers(d, info, 'v') without metsToAnalyze
%       OBSERVED: (code reading, R2025a source of 2026-11-15; not reachable while the defect
%         above stops the function at line 79) the default {} makes setdiff of line 83 return
%         every column, so line 84 deletes every metabolite column and nothing is listed or
%         plotted
%       EXPECTED: all computed metabolites (the help: "default: all computed metabolites")
%       LINES: 30, 83-84
%     - DEFECT: the metabolite counter is printed
%       SEVERITY: cosmetic
%       TRIGGER: any call that reaches line 115
%       OBSERVED: (code reading) "j = 2", "j = 3", ... printed for every metabolite (the
%         statement j has no semicolon)
%       EXPECTED: no console output, or progress gated behind a print level
%       LINES: 115
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPlotMetaboliteProducersConsumers'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
