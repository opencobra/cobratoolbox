% The COBRAToolbox: testAddColourNode.m
%
% Purpose:
%     - addColourNode(map, rxnList, colour) gives the colour colour (a name of createColorsMap,
%       default 'RED') to every molecule alias linked to the reactions named in rxnList: base
%       reactants, base products, secondary reactants, secondary products and modifiers. The
%       test uses a hand-built map with the fields transformXML2Map writes (a reaction without
%       secondary species or modifiers holds '' there) in which each linked alias of reaction
%       HEX1 comes from a different one of the five lists, so each list is checked on its own.
%       Expected colour codes are the CSS named colours (#RRGGBB) with the opaque alpha 'FF'
%       that createColorsMap prepends.
%
% Function under test:
%     src/visualization/metabolicCartography/addColourNode.m
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
fileDir = fileparts(which('testAddColourNode'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% seven molecule aliases, all with the colour 'ffccff66'. Reactions:
%   HEX1: base reactant sa1, base product sa3, secondary reactant sa2, secondary product
%         sa4, modifier sa5
%   PGI:  base reactants sa3 and sa6, base product sa4, nothing else ('' as in
%         transformXML2Map)
%   R3:   base reactant sa7, base product sa6, nothing else
map.molAlias = {'sa1'; 'sa2'; 'sa3'; 'sa4'; 'sa5'; 'sa6'; 'sa7'};
map.molColor = repmat({'ffccff66'}, 7, 1);
map.rxnName = {'HEX1'; 'PGI'; 'R3'};
map.rxnBaseReactantAlias = {{'sa1'}; {'sa3'; 'sa6'}; {'sa7'}};
map.rxnBaseProductAlias = {{'sa3'}; {'sa4'}; {'sa6'}};
map.rxnReactantAlias = {{'sa2'}; ''; ''};
map.rxnProductAlias = {{'sa4'}; ''; ''};
map.rxnModAlias = {{'sa5'}; ''; ''};

originalColour = 'ffccff66';
red = 'FFFF0000';    % CSS red #FF0000
blue = 'FF0000FF';   % CSS blue #0000FF
green = 'FF008000';  % CSS green #008000

%% by default the aliases linked to the listed reaction become RED

% sa1 to sa5 are linked to HEX1 through the five lists; sa6 and sa7 are not linked to HEX1
newMap = addColourNode(map, {'HEX1'});
assert(isequal(newMap.molColor, [repmat({red}, 5, 1); {originalColour; originalColour}]));
% only molColor changes
assert(isequal(rmfield(newMap, 'molColor'), rmfield(map, 'molColor')));

%% a given colour is used; empty secondary and modifier lists colour nothing

% R3 links only sa7 and sa6
newMap = addColourNode(map, {'R3'}, 'BLUE');
assert(isequal(newMap.molColor, [repmat({originalColour}, 5, 1); {blue; blue}]));

%% several reactions: every alias linked to one of them

% PGI links sa3, sa6 (two base reactants) and sa4; R3 links sa6 and sa7
newMap = addColourNode(map, {'PGI', 'R3'}, 'GREEN');
assert(isequal(newMap.molColor, [{originalColour; originalColour}; {green; green}; ...
    {originalColour}; {green; green}]));

%% names that are not reactions of the map change nothing

assert(isequal(addColourNode(map, {'notInMap'}), map));
assert(isequal(addColourNode(map, {}), map));

% change the directory
cd(currentDir)
