% The COBRAToolbox: testCombineFluxResults.m
%
% Purpose:
%     - combineFluxResults merges the FBA solution files of two runs of
%       optimiseRxnMultipleWBMs for the samples present in both folders: reactions, fluxes,
%       statistics and (except for germ-free 'GF' samples) shadow prices of the second run
%       are appended to those of the first, duplicate reactions removed, and one file per
%       sample is written to the result folder. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): when the two folders hold different
%       samples, the germ-free test uses the wrong file (defects below), so no assertion
%       about the function is made.
%
% Function under test:
%     src/analysis/persephone/additionalFunctions/combineFluxResults.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use small hand-built solution files in a
%     temporary folder.
%
% Coverage exemptions:
%     every line - combineFluxResults is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Shadow prices of the second run are dropped when the folders hold different samples
%       SEVERITY: wrong-result
%       TRIGGER: folder d1 holds FBA_sol_GF_female.mat (rxns, ID, sex, f, stat, OrigStat) and
%         FBA_sol_S1.mat (rxns = {'r1'}, ID, sex, speciesBIO, shadowPriceBIO = 10, f = 1,
%         stat, relAbundances, OrigStat); folder d2 holds FBA_sol_S1.mat (rxns = {'r2'},
%         shadowPriceBIO = 20, f = 2, stat, OrigStat); combineFluxResults(d1, d2, d3)
%       OBSERVED: d3/S1.mat holds rxns {'r1' 'r2'} and f [1 2] but shadowPriceBIO 10. Line 93
%         tests pathsRun1(i) (here the GF file of the first run) instead of the path of the
%         i-th common sample, pathsRun1_commonSamples(i).
%       EXPECTED: shadowPriceBIO [10 20], as for any non-GF sample
%       LINES: 93-96
%     - DEFECT: Errors for a common germ-free sample preceded by a sample of the first run only
%       SEVERITY: error
%       TRIGGER: folder d1 holds FBA_sol_A1.mat (all variables, shadowPriceBIO = 10) and
%         FBA_sol_GF_female.mat (rxns, ID, sex, f, stat, OrigStat); folder d2 holds
%         FBA_sol_GF_female.mat (rxns, f, stat, OrigStat); combineFluxResults(d1, d2, d3)
%       OBSERVED: MATLAB:nonExistentField, Unrecognized field name "shadowPriceBIO". (line 95,
%         reached because line 93 tests the non-GF file A1 instead of the GF sample)
%       EXPECTED: the GF sample is merged without shadow prices
%       LINES: 93-96
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCombineFluxResults'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
