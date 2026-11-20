% The COBRAToolbox: testColorRxnType.m
%
% Purpose:
%     - colorRxnType(map, type, color, width) gives every reaction of type type (rxnType) the
%       colour color (a name of createColorsMap) and the width width (default 8), and does
%       the same for one secondary reactant (product) line per entry of rxnReactantID
%       (rxnProductID); reactions without secondary reactants (products) keep their line
%       lists. The test uses a hand-built map with the complete structure (line fields as
%       written by transformFullXML2Map) whose reactions have none, one and two secondary
%       reactants and products, and a map without the line fields, to which the lines are
%       added. Expected colour codes are the CSS named colours (#RRGGBB) with the opaque alpha
%       'FF' that createColorsMap prepends; widths are the given numbers.
%
% Function under test:
%     src/visualization/metabolicCartography/colorRxnType.m
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
fileDir = fileparts(which('testColorRxnType'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

black = 'ff000000';
red = 'FFFF0000';    % CSS red #FF0000
blue = 'FF0000FF';   % CSS blue #0000FF

% four reactions: R1 one secondary reactant, two products; R2 (TRANSPORT) one reactant, no
% product; R3 two reactants, one product; R4 none
map.rxnType = {'STATE_TRANSITION'; 'TRANSPORT'; 'STATE_TRANSITION'; 'STATE_TRANSITION'};
map.rxnColor = repmat({black}, 4, 1);
map.rxnWidth = repmat({'1.0'}, 4, 1);
map.rxnReactantID = {{'s1'}; {'s2'}; {'s1'; 's2'}; ''};
map.rxnProductID = {{'s3'; 's4'}; ''; {'s3'}; ''};
map.rxnReactantLineColor = {{black}; {black}; {black; black}; ''};
map.rxnReactantLineWidth = {{'1.0'}; {'1.0'}; {'1.0'; '1.0'}; ''};
map.rxnProductLineColor = {{black; black}; ''; {black}; ''};
map.rxnProductLineWidth = {{'1.0'; '1.0'}; ''; {'1.0'}; ''};

%% the reactions of the type and their secondary lines get the colour and the default width

newMap = colorRxnType(map, 'STATE_TRANSITION', 'RED');
assert(isequal(newMap.rxnColor, {red; black; red; red}));
assert(isequal(newMap.rxnWidth, {8; '1.0'; 8; 8}));
% one and two secondary reactants; R4 has none and keeps ''
assert(isequal(newMap.rxnReactantLineColor, {{red}; {black}; {red; red}; ''}));
assert(isequal(newMap.rxnReactantLineWidth, {{8}; {'1.0'}; {8; 8}; ''}));
% two and one secondary products
assert(isequal(newMap.rxnProductLineColor, {{red; red}; ''; {red}; ''}));
assert(isequal(newMap.rxnProductLineWidth, {{8; 8}; ''; {8}; ''}));
% the other fields are unchanged
assert(isequal(newMap.rxnType, map.rxnType));
assert(isequal(newMap.rxnReactantID, map.rxnReactantID));

%% a given width; a reaction with one reactant and no product

newMap = colorRxnType(map, 'TRANSPORT', 'BLUE', 2);
assert(isequal(newMap.rxnColor, {black; blue; black; black}));
assert(isequal(newMap.rxnWidth, {'1.0'; 2; '1.0'; '1.0'}));
assert(isequal(newMap.rxnReactantLineColor, {{black}; {blue}; {black; black}; ''}));
assert(isequal(newMap.rxnReactantLineWidth, {{'1.0'}; {2}; {'1.0'; '1.0'}; ''}));
assert(isequal(newMap.rxnProductLineColor, map.rxnProductLineColor));

%% a type that no reaction has changes nothing

assert(isequal(colorRxnType(map, 'HETERODIMER_ASSOCIATION', 'RED'), map));

%% without the line fields, the lines of the coloured reactions are added

% only R2 is coloured: the new fields hold its line in row 2 and an empty entry in row 1
simpleMap = rmfield(map, {'rxnReactantLineColor', 'rxnReactantLineWidth', ...
    'rxnProductLineColor', 'rxnProductLineWidth'});
newMap = colorRxnType(simpleMap, 'TRANSPORT', 'BLUE', 2);
assert(isequal(newMap.rxnReactantLineColor, {[]; {blue}}));
assert(isequal(newMap.rxnReactantLineWidth, {[]; {2}}));
assert(~isfield(newMap, 'rxnProductLineColor'));

% change the directory
cd(currentDir)
