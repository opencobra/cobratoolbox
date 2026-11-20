% The COBRAToolbox: testAnalyseWBMsol.m
%
% Purpose:
%     - analyseWBMsol loads the FBA solutions saved by analyseWBMs (one .mat file per model),
%       rounds the fluxes, computes summary statistics, removes reactions by the chosen
%       cutoff, subtracts the germ-free fluxes from the personalised ones (when analyseGF is
%       true), correlates fluxes with the microbial relative abundances (Spearman), and
%       writes processed_fluxes.csv, WBM_relative_abundances.csv and the multi-sheet
%       flux_results.xlsx. The function is QUARANTINED (Constitution III-Defects, quarantine
%       in back-fill campaigns): it errors for duplicate reactions and for germ-free and
%       microbiome-personalised iWBMs analysed together (defects below), so no assertion
%       about the function is made.
%
% Function under test:
%     src/analysis/persephone/analyseWBMsol.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-written solution .mat files and
%     a temporary results folder.
%
% Coverage exemptions:
%     every line - analyseWBMsol is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Errors for germ-free and microbiome-personalised iWBMs with analyseGF
%       SEVERITY: error
%       TRIGGER: a folder with FBA_sol_gfiWBM_S1_male.mat, FBA_sol_gfiWBM_S2_female.mat,
%         FBA_sol_miWBM_S1_male.mat and FBA_sol_miWBM_S2_female.mat, each saved with
%         save(file, '-struct', 's') from s = struct('rxns', {{'r1', 'r2', 'r3'}}, 'ID',
%         "<model name>", 'sex', {{'<sex>'}}, 'f', <1x3 fluxes>, 'stat', [1 1 1]) (the miWBM
%         files also with taxonNames {'panA_biomass[c]'; 'panB_biomass[c]'} and
%         relAbundances [61; 41]); analyseWBMsol(folder, struct('rxnRemovalCutoff',
%         {{'count', 0}}), outFolder, true)
%       OBSERVED: MATLAB:table:RowDimensionMismatch, To assign to or create a variable in a
%         table, the number of rows must match the height of the table (describeFluxes,
%         line 598; MATLAB R2025a). meanSd takes the mean over the first dimension of the
%         transposed reactions-by-samples germ-free array, i.e. over the reactions, and
%         returns one value per germ-free sample (here 1) instead of one per reaction (3).
%         With two male germ-free samples, two reactions and no female sample it stops on
%         line 599 with MATLAB:string:MustBeCharCellArrayOrString, Input must be text.
%       EXPECTED: the per-reaction mean (SD) of the male and female germ-free fluxes in the
%         scaled flux summary table, and all results written
%       LINES: 598-599
%     - DEFECT: Errors when the reaction list contains a duplicate
%       SEVERITY: error
%       TRIGGER: one file FBA_sol_WBM_S1_male.mat saved from s = struct('rxns', {{'r1',
%         'r2', 'r1'}}, 'ID', "WBM_S1_male", 'sex', {{'male'}}, 'f', [1 2 1], 'stat',
%         [1 1 1]); analyseWBMsol(folder, struct(), outFolder, false)
%       OBSERVED: MATLAB:table:WrongNumberRHSCols, The value on the right-hand side of the
%         assignment has the wrong width. The assignment requires a value whose width is 2.
%         (line 111): the duplicate is removed from rxns and f (lines 84 and 105) but not
%         from stat
%       EXPECTED: the duplicate removed from stat as well and the results written for r1
%         and r2, as the duplicate handling of lines 81-84 intends
%       LINES: 105-111
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAnalyseWBMsol'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
