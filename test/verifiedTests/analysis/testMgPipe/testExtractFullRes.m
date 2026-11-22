% The COBRAToolbox: testExtractFullRes.m
%
% Purpose:
%     - extractFullRes collects, for one diet, the minimal and maximal uptake and secretion
%       fluxes of every exchange reaction of every sample from the FVA results of mgPipe,
%       skips infeasible samples, returns them as a cell table and writes
%       <resPath><dietType>_allFlux.csv. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): it errors when the first sample is
%       infeasible (defect below), so no assertion about the function is made.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/extractFullRes.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-built FVA cell arrays and a
%     temporary results folder.
%
% Coverage exemptions:
%     every line - extractFullRes is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Errors when the first sample is infeasible and a later one is feasible
%       SEVERITY: error
%       TRIGGER: ID = {'EX_a[fe]'; 'EX_b[fe]'}; fva = cell(3, 2); ns = cell(3, 2);
%         fva{2, 2} = {'EX_a[fe]', -1, 2; 'EX_b[fe]', -3, 4};
%         ns{2, 2} = {'EX_a[fe]', -5, 6; 'EX_b[fe]', -7, 8};
%         extractFullRes([tempname filesep], ID, 'sDiet', {'s1'; 's2'}, fva, ns)
%       OBSERVED: prints 'Jumping not feasible model', then MATLAB:catenate:dimensionMismatch,
%         Dimensions of arrays being concatenated are not consistent. The 'Rxn' column name
%         is added to the header only when k == 1, so the header row has 4 columns and the
%         flux rows 5.
%       EXPECTED: the infeasible sample s1 is skipped, as the message says, and the table
%         Rxn, minUpt_s2, maxUpt_s2, minScr_s2, maxScr_s2 with the fluxes of s2 is returned
%         and written
%       LINES: 70-76
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testExtractFullRes'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
