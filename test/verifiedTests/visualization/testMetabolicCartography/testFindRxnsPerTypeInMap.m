% The COBRAToolbox: testFindRxnsPerTypeInMap.m
%
% Purpose:
%     - findRxnsPerTypeInMap lists the reactions of a CellDesigner map structure of a given
%       type (map.rxnType, e.g. TRANSPORT): a cell array with the reaction indices in the first
%       column and the reaction names in the second. The test uses a hand-built map and checks
%       several matches, one match and no match (an empty 0-by-2 cell array). Expected values
%       are read off the hand-built map (documentation of the output).
%
% Function under test:
%     src/visualization/metabolicCartography/findRxnsPerTypeInMap.m
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
fileDir = fileparts(which('testFindRxnsPerTypeInMap'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% four reactions of a map (column cell arrays, as transformXML2Map builds them)
map.rxnName = {'GLCt'; 'HEX1'; 'ATPtm'; 'PGI'};
map.rxnType = {'TRANSPORT'; 'STATE_TRANSITION'; 'TRANSPORT'; 'STATE_TRANSITION'};

%% several reactions of the type: indices (first column) and names (second column)

listRxns = findRxnsPerTypeInMap(map, 'TRANSPORT');
% indices are integers and names text, so the comparison is exact
assert(isequal(listRxns, {1, 'GLCt'; 3, 'ATPtm'}));

listRxns = findRxnsPerTypeInMap(map, 'STATE_TRANSITION');
assert(isequal(listRxns, {2, 'HEX1'; 4, 'PGI'}));

%% one reaction of the type

map.rxnType{4} = 'CATALYSIS';
listRxns = findRxnsPerTypeInMap(map, 'CATALYSIS');
assert(isequal(listRxns, {4, 'PGI'}));

%% no reaction of the type (the match is exact and case-sensitive): empty 0-by-2 list

listRxns = findRxnsPerTypeInMap(map, 'transport');
assert(iscell(listRxns));
assert(isequal(size(listRxns), [0, 2]));

% change the directory
cd(currentDir)
