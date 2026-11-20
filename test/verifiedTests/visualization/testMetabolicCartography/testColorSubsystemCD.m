% The COBRAToolbox: testColorSubsystemCD.m
%
% Purpose:
%     - colorSubsystemCD colours (default 'RED') and widens (default 8) every map reaction of
%       one model subsystem, and also its secondary reactant and product lines when the map has
%       the complete structure. The function is QUARANTINED (Constitution III-Defects,
%       quarantine in back-fill campaigns): reactions are selected from a list of subsystems
%       that is not aligned with model.rxns when a reaction has several subsystems (defect
%       below); no assertion about the function is made.
%
% Function under test:
%     src/visualization/metabolicCartography/colorSubsystemCD.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; a test would use a hand-built map and a model
%     with rxns and subSystems.
%
% Coverage exemptions:
%     every line - colorSubsystemCD is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Reactions with several subsystems shift the selection to the wrong reactions
%       SEVERITY: wrong-result
%       TRIGGER: model.rxns = {'R1'; 'R2'; 'R3'}; model.subSystems = {{'A', 'B'}; {'C'}; {'B'}};
%         map.rxnName = {'R1'; 'R2'; 'R3'}; map.rxnColor = {'X'; 'X'; 'X'};
%         map.rxnWidth = {1; 1; 1}; colorSubsystemCD(map, model, 'C')
%       OBSERVED: (R2025a, 2026-11-16) rxnColor = {'X'; 'X'; 'FFFF0000'}: R3 is coloured
%         instead of R2, because [model.subSystems{:}] has 4 entries for 3 reactions; with
%         subsystem 'B' the call fails with "The logical indices contain a true value outside
%         of the array bounds."; subSystems given as a cell of char vectors (model.rxns =
%         {'R1'; 'R2'}, model.subSystems = {'S1'; 'S2'}, subsystem 'S2') are concatenated into
%         one character row 'S1S2', compared character by character, and fail with the same
%         error
%       EXPECTED: rxnColor = {'X'; 'FFFF0000'; 'X'} for 'C', and R1 and R3 coloured for 'B'
%       LINES: 45
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testColorSubsystemCD'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
