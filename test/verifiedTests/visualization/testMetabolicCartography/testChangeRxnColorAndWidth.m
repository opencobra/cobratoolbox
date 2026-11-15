% The COBRAToolbox: testChangeRxnColorAndWidth.m
%
% Purpose:
%     - changeRxnColorAndWidth(map, rxnList, color, areaWidth) gives the reactions named in
%       rxnList the colour color (a name of createColorsMap, default 'RED') and the line width
%       areaWidth (default 8). For a map with the complete structure (field
%       rxnReactantLineColor, as written by transformFullXML2Map) the secondary reactant and
%       product lines of these reactions get the same colour and width; empty line lists stay
%       empty. The test uses two hand-built maps, one without and one with the line fields.
%       Expected colour codes are the CSS named colours (#RRGGBB) with the opaque alpha 'FF'
%       that createColorsMap prepends; widths are the given numbers.
%
% Function under test:
%     src/visualization/metabolicCartography/changeRxnColorAndWidth.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built map structures.
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
fileDir = fileparts(which('testChangeRxnColorAndWidth'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

black = 'ff000000';
red = 'FFFF0000';     % CSS red #FF0000
blue = 'FF0000FF';    % CSS blue #0000FF
green = 'FF008000';   % CSS green #008000

% a map without secondary line fields (the form transformXML2Map writes)
map.rxnName = {'R1'; 'R2'};
map.rxnColor = {black; black};
map.rxnWidth = {'1.0'; '1.0'};

%% defaults: RED and width 8

newMap = changeRxnColorAndWidth(map, {'R1'});
assert(isequal(newMap.rxnColor, {red; black}));
assert(isequal(newMap.rxnWidth, {8; '1.0'}));
% no other field is changed or added
assert(isequal(fieldnames(newMap), fieldnames(map)));
assert(isequal(newMap.rxnName, map.rxnName));

%% a given colour with the default width, then colour and width

newMap = changeRxnColorAndWidth(map, {'R2'}, 'BLUE');
assert(isequal(newMap.rxnColor, {black; blue}));
assert(isequal(newMap.rxnWidth, {'1.0'; 8}));

newMap = changeRxnColorAndWidth(map, {'R1', 'R2'}, 'GREEN', 3);
assert(isequal(newMap.rxnColor, {green; green}));
assert(isequal(newMap.rxnWidth, {3; 3}));

%% names that are not reactions of the map change nothing

assert(isequal(changeRxnColorAndWidth(map, {'notInMap'}), map));

%% complete structure: the secondary lines of the listed reactions follow

% R1 has two secondary reactant lines and no product line; R2 has no reactant line and one
% product line
fullMap = map;
fullMap.rxnReactantLineColor = {{black; black}; ''};
fullMap.rxnReactantLineWidth = {{'1.0'; '1.0'}; ''};
fullMap.rxnProductLineColor = {''; {black}};
fullMap.rxnProductLineWidth = {''; {'1.0'}};

newMap = changeRxnColorAndWidth(fullMap, {'R1', 'R2'}, 'RED', 5);
assert(isequal(newMap.rxnColor, {red; red}));
assert(isequal(newMap.rxnWidth, {5; 5}));
assert(isequal(newMap.rxnReactantLineColor, {{red; red}; ''}));
assert(isequal(newMap.rxnReactantLineWidth, {{5; 5}; ''}));
assert(isequal(newMap.rxnProductLineColor, {''; {red}}));
assert(isequal(newMap.rxnProductLineWidth, {''; {5}}));

% a reaction that is not listed keeps its secondary lines
newMap = changeRxnColorAndWidth(fullMap, {'R2'});
assert(isequal(newMap.rxnReactantLineColor, fullMap.rxnReactantLineColor));
assert(isequal(newMap.rxnProductLineColor, {''; {red}}));
assert(isequal(newMap.rxnProductLineWidth, {''; {8}}));

% change the directory
cd(currentDir)
