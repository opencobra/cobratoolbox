% The COBRAToolbox: testAssignSubSystems.m
%
% Purpose:
%     - assignSubSystems reads a SimPheny GPRA file and sets the subsystem of every reaction
%       from it ('Exchange' for reactions not in the file). The function is quarantined for the
%       defect below: the parser it calls does not exist, so every call stops. This file only
%       opens the test; it asserts nothing about the function.
%
% Function under test:
%     src/reconstruction/refinement/assignSubSystems.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation (subSystems); no solver.
%
% Coverage exemptions:
%     every line - assignSubSystems is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every call stops because parseSimPhenyGPRA does not exist
%       SEVERITY: error
%       TRIGGER: model = createModel({'r1', 'EX_a'}, {'r1', 'EX_a'}, {'A[c] -> B[c]', 'A[c] <=> '});
%         assignSubSystems(model, 'gpra.txt') (any model and any file name)
%       OBSERVED: (R2025a, 2026-11-16) error "Undefined function 'parseSimPhenyGPRA' for input
%         arguments of type 'char'." at line 23: parseSimPhenyGPRA is not part of the toolbox
%         (no file of that name in the repository)
%       EXPECTED: the SimPheny GPRA file is parsed and the subSystems of the
%         model are set from it
%       LINES: 23-35
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAssignSubSystems'));
cd(fileDir);

% declare the requirements of this test. This test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
