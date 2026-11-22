% The COBRAToolbox: testChangeMetColor.m
%
% Purpose:
%     - changeMetColor(map, metList, color) gives the colour color (a name of createColorsMap,
%       default 'RED') to every molecule node whose species ID belongs to a species named in
%       metList (specName and specID are parallel lists; a species can be drawn by several
%       nodes of molID). The test uses a hand-built map in which glucose is drawn twice and
%       checks the default and a given colour, several names, and names not in the map.
%       Expected colour codes are the CSS named colours (#RRGGBB) with the opaque alpha 'FF'
%       that createColorsMap prepends.
%
% Function under test:
%     src/visualization/metabolicCartography/changeMetColor.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built map structure.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testChangeMetColor'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% species s1 glc, s2 atp, s3 g6p; nodes: s1, s2, s3 and a second drawing of s1
map.specName = {'glc'; 'atp'; 'g6p'};
map.specID = {'s1'; 's2'; 's3'};
map.molID = {'s1'; 's2'; 's3'; 's1'};
map.molColor = repmat({'ffccff66'}, 4, 1);

originalColour = 'ffccff66';
red = 'FFFF0000';   % CSS red #FF0000
blue = 'FF0000FF';  % CSS blue #0000FF

%% by default every node of the named species becomes RED

% glc is drawn by the first and the fourth node
newMap = changeMetColor(map, {'glc'});
assert(isequal(newMap.molColor, {red; originalColour; originalColour; red}));
% only molColor changes
assert(isequal(rmfield(newMap, 'molColor'), rmfield(map, 'molColor')));

%% a given colour and several names

newMap = changeMetColor(map, {'atp', 'g6p'}, 'BLUE');
assert(isequal(newMap.molColor, {originalColour; blue; blue; originalColour}));

%% names that are not species of the map change nothing

assert(isequal(changeMetColor(map, {'notInMap'}, 'BLUE'), map));

% change the directory
cd(currentDir)
