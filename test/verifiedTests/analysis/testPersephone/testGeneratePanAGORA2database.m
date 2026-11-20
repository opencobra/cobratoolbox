% The COBRAToolbox: testGeneratePanAGORA2database.m
%
% Purpose:
%     - generatePanAGORA2database loads every strain model of the folder AGORA2 found on the
%       MATLAB path, records the union of their reactions, metabolites and strain names and
%       the sparse presence matrices (strain x reaction, strain x metabolite), and saves them
%       as AGORA2_lookupFile.mat in the current folder. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): it processes only the
%       first three strains (defect below), so no assertion about the function is made.
%
% Function under test:
%     src/analysis/persephone/additionalFunctions/generatePanAGORA2database.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver; a test would use a temporary AGORA2 folder of
%     tiny hand-built models.
%
% Coverage exemptions:
%     every line - generatePanAGORA2database is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Only the first three strains are processed
%       SEVERITY: wrong-result
%       TRIGGER: a folder named AGORA2 on the MATLAB path holding strain1.mat to strain4.mat
%         (each a struct model with rxns = {'r<k>'}, mets = {'x'}, S = sparse(1)); from a
%         writable folder: p = generatePanAGORA2database(); s = load(p)
%       OBSERVED: s.agoraStruct.strains = {'strain1'; 'strain2'; 'strain3'} and
%         s.agoraStruct.rxns = {'r1'; 'r2'; 'r3'}; strain4 and r4 are missing (line 26 keeps
%         strains(1:3))
%       EXPECTED: all four strains and reactions, as the header says (which reactions and
%         metabolites are present in which AGORA2 strains)
%       LINES: 26
%     - DEFECT: Hard-coded personal input folder
%       SEVERITY: cosmetic
%       TRIGGER: any call
%       OBSERVED: line 15 sets a folder under a Windows user profile (C:\Users\...), line 16
%         looks it up and line 17 overwrites the result with what('AGORA2')
%       EXPECTED: no leftover machine-specific path (lines 15-16 have no effect)
%       LINES: 15-16
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGeneratePanAGORA2database'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
