% The COBRAToolbox: testBuildFluxDistLayout.m
%
% Purpose:
%     - buildFluxDistLayout builds a MINERVA overlay from a flux vector (one URL-encoded line
%       per reaction with non-zero flux: reaction ID, line width from the normalized absolute
%       flux, colour) and sends it with postMINERVArequest. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): the maxThickness input
%       is ignored and the largest flux gets the thinnest line (defects below); no assertion
%       about the function is made.
%
% Function under test:
%     src/visualization/maps/ReconMap/buildFluxDistLayout.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; a test would use a hand-built model and flux
%     vector, and replace postMINERVArequest (internet) by a recording stand-in in a tempname
%     folder made the current folder (pattern of testWebDatabases).
%
% Coverage exemptions:
%     every line - buildFluxDistLayout is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The maxThickness input is ignored
%       SEVERITY: unusable-option
%       TRIGGER: minerva.map = 'ReconMap-2.01'; model.rxns = {'R1'; 'R2'; 'R3'};
%         solution.v = [0; 5; 10]; buildFluxDistLayout(minerva, model, solution, 'id', '#ff0000', 4)
%       OBSERVED: (R2025a, 2026-11-16, postMINERVArequest replaced by a recording stand-in)
%         content '...%09R2%095%09#ff0000%0D%09R3%090%09#ff0000%0D', the same widths as
%         without maxThickness: line 46 tests exist('thickness', 'var'), which is always
%         false, so maxThickness is always reset to 10
%       EXPECTED: widths scaled to the given maximum thickness 4
%       LINES: 46-48
%     - DEFECT: The largest flux gets line width 0 and the smallest the maximum width
%       SEVERITY: wrong-result
%       TRIGGER: the call above without the last two inputs
%       OBSERVED: (R2025a, 2026-11-16) content
%         'name%09reactionIdentifier%09lineWidth%09color%0D%09R2%095%09#57c657%0D%09R3%090%09#57c657%0D':
%         flux 10 gets width 0 and flux 5 width 5, because normalizeFluxes returns
%         thickness * (1 - (f - min) / range)
%       EXPECTED: width growing with the absolute flux (flux 10 the widest line), as the use
%         of the width as a flux thickness implies
%       LINES: 136-140
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testBuildFluxDistLayout'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
