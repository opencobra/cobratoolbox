% The COBRAToolbox: testPlotFluxesAgainstOrganismAbundances.m
%
% Purpose:
%     - plotFluxesAgainstOrganismAbundances creates the folder Metabolite_plots in the
%       current folder and, for every metabolite of the flux table whose fluxes do not sum to
%       zero and for every organism of the abundance table, prints a scatter plot of the
%       fluxes against the organism abundances of the samples to
%       <metabolite name>_<organism>.png in that folder. The metabolite name comes from the
%       VMH database (prefix EX_ and suffixes (e) and [fe] removed). The optional list of
%       metabolites restricts the plots. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): the documented orientation of the
%       flux table and file names relative to the current folder stop with an error (defect
%       below), so no assertion about the function is made.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/plotFluxesAgainstOrganismAbundances.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-written tables and a VMH database
%     in a temporary folder and invisible figures.
%
% Coverage exemptions:
%     every line - plotFluxesAgainstOrganismAbundances is quarantined for the defect below
%     (feature 20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented orientation of the flux table and relative file paths stop with an error
%       SEVERITY: error
%       TRIGGER: a flux file with sample IDs as rows and reactions as columns, as documented
%         ('ID,EX_ac[fe],EX_but[fe]' then 'S1,1,3', 'S2,2,1', 'S3,3,2') with an abundance file
%         'ID,S1,S2,S3' / 'panBact_a,0.1,0.2,0.3' / 'Esch_c,0.9,0.8,0.7'; or the file names
%         relative to the current folder: plotFluxesAgainstOrganismAbundances('abun2.csv',
%         'flux2.csv')
%       OBSERVED: Sample IDs in abundance and flux files do not agree! (line 37 compares the
%         first row of the flux table with the samples; no transposition as in
%         correlateFluxWithTaxonAbundance). Relative names: Unable to find or open
%         'abun2.csv'. Check the path and filename or file permissions., because line 26
%         changes to Metabolite_plots before the files are read.
%       EXPECTED: the plots of the documented layout (sample IDs as rows) and of files given
%         relative to the current folder
%       LINES: 26, 29, 37-39
%     - DEFECT: The current folder stays Metabolite_plots after an error
%       SEVERITY: cosmetic
%       TRIGGER: abundance and flux tables with different samples
%       OBSERVED: after the error of line 38, pwd is <current folder>/Metabolite_plots (the
%         cd .. of line 90 is not reached)
%       EXPECTED: the current folder of the caller
%       LINES: 26, 38, 90
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPlotFluxesAgainstOrganismAbundances'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
