% The COBRAToolbox: testChangeNodesArea.m
%
% Purpose:
%     - changeNodesArea sets the height and width of every molecule alias of the map whose
%       species name is in metList (defaults: height 25, width 70; both are documented as
%       optional inputs). The function is QUARANTINED (Constitution III-Defects, quarantine
%       in back-fill campaigns): a call that gives areaHeight but not areaWidth fails (defect
%       below); no assertion about the function is made.
%
% Function under test:
%     src/visualization/metabolicCartography/changeNodesArea.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use a hand-built map structure.
%
% Coverage exemptions:
%     every line - changeNodesArea is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The optional areaWidth is not defaulted when areaHeight is given
%       SEVERITY: error
%       TRIGGER: map.specID = {'s1';'s2'}; map.specName = {'A';'B'}; map.molID = {'s1';'s2';'s1'};
%         map.molHeight = {'40';'40';'40'}; map.molWidth = {'80';'80';'80'};
%         changeNodesArea(map, {'A'}, 30)
%       OBSERVED: MATLAB R2025a: error 'Not enough input arguments.' at changeNodesArea line 42;
%         the default areaWidth = 70.0 is set only inside 'if nargin < 3', so it is never
%         set for three inputs.
%       EXPECTED: heights of the aliases of A set to 30 and widths to the default 70
%       LINES: 24-27, 42
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testChangeNodesArea'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
