% The COBRAToolbox: testTransformToReversibleMap.m
%
% Purpose:
%     - transformToReversibleMap sets .rxnReversibility to 'true' for every map reaction
%       whose name is in rxnlist (all copies of a duplicated name) and leaves the other
%       reactions and all other fields unchanged. Expected values follow from the
%       documentation.
%
% Function under test:
%     src/visualization/metabolicCartography/transformToReversibleMap.m
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
fileDir = fileparts(which('testTransformToReversibleMap'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a map of four irreversible reactions; HEX1 is drawn twice (two copies of one name)
map.rxnName = {'HEX1'; 'PGI'; 'HEX1'; 'PFK'};
map.rxnID = {'re1'; 're2'; 're3'; 're4'};
map.rxnReversibility = repmat({'false'}, 4, 1);

%% listed reactions become reversible, every copy of a duplicated name included

mapRev = transformToReversibleMap(map, {'HEX1'; 'PFK'});
assert(isequal(mapRev.rxnReversibility, {'true'; 'false'; 'true'; 'true'}));
% the other fields are copied unchanged
assert(isequal(rmfield(mapRev, 'rxnReversibility'), rmfield(map, 'rxnReversibility')));

%% names not in the map are ignored; reactions already reversible stay reversible

map.rxnReversibility{2} = 'true';
mapRev2 = transformToReversibleMap(map, {'PFK'; 'NOTINMAP'});
assert(isequal(mapRev2.rxnReversibility, {'false'; 'true'; 'false'; 'true'}));

%% no listed reaction in the map: the map is returned unchanged

mapRev3 = transformToReversibleMap(map, {'NOTINMAP'});
assert(isequal(mapRev3, map));

% change the directory
cd(currentDir)
