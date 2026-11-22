% The COBRAToolbox: testModifyReactionsMetabolites.m
%
% Purpose:
%     - modifyReactionsMetabolites sets the colour (an HTML code looked up by name in
%       createColorsMap) and the width of the listed reactions of a CellDesigner map structure,
%       and the colour of the drawings (aliases) of the listed metabolites that take part in
%       those reactions as base or secondary reactants or products. The test uses a hand-built
%       map (one metabolite drawn twice) and checks which reactions and aliases change, a width
%       given as a number and as text, a reaction list that matches nothing, and the error for
%       a colour name that createColorsMap does not define. Expected values follow from the
%       documentation and from the colour table of createColorsMap (RED = 'FFFF0000',
%       BLUE = 'FF0000FF').
%
% Function under test:
%     src/visualization/metabolicCartography/modifyReactionsMetabolites.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built map structure.
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
fileDir = fileparts(which('testModifyReactionsMetabolites'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% species s1 glc, s2 atp, s3 g6p, s4 adp, s5 f6p; aliases sa1-sa5 draw s1-s5 and sa6 is a
% second drawing of glc. Reactions:
%   re1 HEX1: glc (sa1) + atp (sa2, secondary) -> g6p (sa3) + adp (sa4, secondary)
%   re2 PGI:  g6p (sa3) -> f6p (sa5), no secondary species ('' as transformXML2Map stores it)
%   re3 R3:   glc (sa6) -> atp (sa2)
map.specID = {'s1'; 's2'; 's3'; 's4'; 's5'};
map.specName = {'glc'; 'atp'; 'g6p'; 'adp'; 'f6p'};
map.molAlias = {'sa1'; 'sa2'; 'sa3'; 'sa4'; 'sa5'; 'sa6'};
map.molID = {'s1'; 's2'; 's3'; 's4'; 's5'; 's1'};
map.molColor = repmat({'ffccff66'}, 6, 1);
map.rxnName = {'HEX1'; 'PGI'; 'R3'};
map.rxnColor = repmat({'ff000000'}, 3, 1);
map.rxnWidth = repmat({'1.0'}, 3, 1);
map.rxnBaseReactantID = {{'s1'}; {'s3'}; {'s1'}};
map.rxnBaseReactantAlias = {{'sa1'}; {'sa3'}; {'sa6'}};
map.rxnReactantID = {{'s2'}; ''; ''};
map.rxnReactantAlias = {{'sa2'}; ''; ''};
map.rxnBaseProductID = {{'s3'}; {'s5'}; {'s2'}};
map.rxnBaseProductAlias = {{'sa3'}; {'sa5'}; {'sa2'}};
map.rxnProductID = {{'s4'}; ''; ''};
map.rxnProductAlias = {{'sa4'}; ''; ''};

%% one reaction: its colour and width change, and the listed metabolites drawn in it

newMap = modifyReactionsMetabolites(map, {'HEX1'}, {'glc'; 'atp'; 'f6p'}, 'RED', 5);
% text and integer values, so comparisons are exact
assert(isequal(newMap.rxnColor, {'FFFF0000'; 'ff000000'; 'ff000000'}));
assert(isequal(newMap.rxnWidth, {5; '1.0'; '1.0'}));
% glc (sa1, base reactant) and atp (sa2, secondary reactant) take the colour; f6p (sa5) is
% listed but not in HEX1, and sa6 draws glc in another reaction, so both keep their colour;
% g6p and adp are in HEX1 but not listed
assert(isequal(newMap.molColor, {'FFFF0000'; 'FFFF0000'; 'ffccff66'; 'ffccff66'; 'ffccff66'; 'ffccff66'}));
% no other field changes
assert(isequal(rmfield(newMap, {'rxnColor', 'rxnWidth', 'molColor'}), rmfield(map, {'rxnColor', 'rxnWidth', 'molColor'})));

%% several reactions and a width given as text; base and secondary products are reached

newMap = modifyReactionsMetabolites(map, {'PGI'; 'R3'}, {'g6p'; 'glc'; 'atp'; 'adp'}, 'BLUE', '2.5');
assert(isequal(newMap.rxnColor, {'ff000000'; 'FF0000FF'; 'FF0000FF'}));
assert(isequal(newMap.rxnWidth, {'1.0'; '2.5'; '2.5'}));
% g6p (sa3, base reactant of PGI), glc (sa6, base reactant of R3) and atp (sa2, base product
% of R3) are coloured; glc drawn as sa1 and adp (sa4) are not in PGI or R3
assert(isequal(newMap.molColor, {'ffccff66'; 'FF0000FF'; 'FF0000FF'; 'ffccff66'; 'ffccff66'; 'FF0000FF'}));

% the secondary product adp (sa4) of HEX1 is reached as well
newMap = modifyReactionsMetabolites(map, 'HEX1', 'adp', 'BLUE', 2);
assert(isequal(newMap.molColor, {'ffccff66'; 'ffccff66'; 'ffccff66'; 'FF0000FF'; 'ffccff66'; 'ffccff66'}));

%% reactions absent from the map: the map is returned unchanged

newMap = modifyReactionsMetabolites(map, {'NOT_IN_MAP'}, {'glc'}, 'RED', 5);
assert(isequal(newMap, map));

%% a colour name that createColorsMap does not define (names are upper case) is an error

assert(verifyCobraFunctionError('modifyReactionsMetabolites', 'inputs', {map, {'HEX1'}, {'glc'}, 'red', 5}));

% change the directory
cd(currentDir)
