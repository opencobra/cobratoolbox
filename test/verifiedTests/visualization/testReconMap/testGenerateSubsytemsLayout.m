% The COBRAToolbox: testGenerateSubsytemsLayout.m
%
% Purpose:
%     - generateSubsytemsLayout builds a MINERVA overlay (tab-separated, URL-encoded lines
%       '%09<reaction>%095%09<colour>%0D', reaction IDs prefixed 'r_' unless the map is
%       ReconMap-2.01, default colour #009933) for the reactions of a model subsystem and
%       sends it with postMINERVArequest. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): the overlay content is cut to its
%       first word before it is sent (defect below); no assertion about the function is made.
%
% Function under test:
%     src/visualization/maps/ReconMap/generateSubsytemsLayout.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model file, no solver; a test would use a hand-built model and replace
%     postMINERVArequest (internet) by a recording stub on a tempname path.
%
% Coverage exemptions:
%     every line - generateSubsytemsLayout is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The overlay content is truncated to 'name' before it is sent
%       SEVERITY: wrong-result
%       TRIGGER: any call, e.g. a model with rxns {'R1'; 'R2'} in subsystem 'S1' and
%         generateSubsytemsLayout(minerva, model, 'S1') with minerva.map = 'ReconMap-2.01'
%       OBSERVED: MATLAB R2025a: content = sprintf(content) on
%         'name%09reactionIdentifier%09lineWidth%09color%0D%09R1%095%09#009933%0D' returns
%         'name' (4 characters): '%09r' is read as an incomplete format specifier and
%         sprintf stops there, so postMINERVArequest receives content 'name' and no
%         reaction; buildFluxDistLayout sends the URL-encoded text unchanged.
%       EXPECTED: content holding the header and one line per subsystem reaction
%       LINES: 54-55
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGenerateSubsytemsLayout'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
