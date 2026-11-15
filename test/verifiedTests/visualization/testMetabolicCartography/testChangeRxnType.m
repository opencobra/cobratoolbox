% The COBRAToolbox: testChangeRxnType.m
%
% Purpose:
%     - changeRxnType sets the CellDesigner reaction type of every map reaction whose name is
%       in rxnsList (all copies of a duplicated name) and leaves the other reactions and all
%       other fields unchanged. Expected values follow from the documentation.
%
% Function under test:
%     src/visualization/metabolicCartography/changeRxnType.m
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
fileDir = fileparts(which('testChangeRxnType'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a map of four reactions; HEX1 appears twice (two drawings of the same reaction)
map.rxnName = {'HEX1'; 'PGI'; 'HEX1'; 'PFK'};
map.rxnID = {'re1'; 're2'; 're3'; 're4'};
map.rxnType = repmat({'STATE_TRANSITION'}, 4, 1);

%% listed reactions get the new type, all copies of a duplicated name included

map2 = changeRxnType(map, {'HEX1'; 'PFK'}, 'TRANSPORT');
assert(isequal(map2.rxnType, {'TRANSPORT'; 'STATE_TRANSITION'; 'TRANSPORT'; 'TRANSPORT'}));
% the other fields are copied unchanged
assert(isequal(map2.rxnName, map.rxnName));
assert(isequal(map2.rxnID, map.rxnID));

%% names not in the map are ignored; a char list of one reaction works as a list

map3 = changeRxnType(map, {'PGI'; 'NOTINMAP'}, 'KNOWN_TRANSITION_OMITTED');
assert(isequal(map3.rxnType, {'STATE_TRANSITION'; 'KNOWN_TRANSITION_OMITTED'; 'STATE_TRANSITION'; 'STATE_TRANSITION'}));
map4 = changeRxnType(map, 'PFK', 'TRANSPORT');
assert(isequal(map4.rxnType, {'STATE_TRANSITION'; 'STATE_TRANSITION'; 'STATE_TRANSITION'; 'TRANSPORT'}));

%% no listed reaction in the map: the map is returned unchanged

map5 = changeRxnType(map, {'NOTINMAP'}, 'TRANSPORT');
assert(isequal(map5, map));

% change the directory
cd(currentDir)
