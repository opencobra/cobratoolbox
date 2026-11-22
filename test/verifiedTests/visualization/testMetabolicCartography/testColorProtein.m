% The COBRAToolbox: testColorProtein.m
%
% Purpose:
%     - colorProtein(map, protList, color) gives the colour color (a name of createColorsMap,
%       documented default 'RED') to the molecule nodes of the proteins named in protList
%       (species names and names of species included in complexes). The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): the default
%       colour is written 'Red', which is not a key of createColorsMap, so the documented
%       two-argument call raises an error whenever a protein of the list is in the map; no
%       assertion about the function is made.
%
% Function under test:
%     src/visualization/metabolicCartography/colorProtein.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use a hand-built map structure.
%
% Coverage exemptions:
%     every line - colorProtein is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The default colour 'Red' is not a key of createColorsMap
%       SEVERITY: error
%       TRIGGER: map.specName = {'hk'}; map.specMetaID = {'s5'}; map.specIncName = cell(0, 1);
%         map.specIncID = cell(0, 1); map.molID = {'s5'}; map.molColor = {'ffccff66'};
%         colorProtein(map, {'hk'})
%       OBSERVED: (R2025a, 2026-11-15) error 'The specified key is not present in this
%         container.' raised by colorProtein line 49; the same call with 'RED' or 'BLUE' as
%         third input returns molColor {'FF0000FF'} for 'BLUE'
%       EXPECTED: the protein node coloured 'FFFF0000' (RED), the documented default
%       LINES: 32
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testColorProtein'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
