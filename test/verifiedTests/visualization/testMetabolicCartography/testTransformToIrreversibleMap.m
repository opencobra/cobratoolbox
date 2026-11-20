% The COBRAToolbox: testTransformToIrreversibleMap.m
%
% Purpose:
%     - transformToIrreversibleMap sets map.rxnReversibility to 'false' for the reactions of a
%       CellDesigner map structure whose names are in a list, and leaves every other field and
%       reaction unchanged. The test uses a hand-built map and checks a list of names
%       (including a name used by two reactions and a name absent from the map), a single name
%       given as a character vector, and an empty list. Expected values follow from the
%       documentation of the output.
%
% Function under test:
%     src/visualization/metabolicCartography/transformToIrreversibleMap.m
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
fileDir = fileparts(which('testTransformToIrreversibleMap'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% four reactions; PGI is drawn twice (two reactions of the same name)
map.rxnID = {'re1'; 're2'; 're3'; 're4'};
map.rxnName = {'HEX1'; 'PGI'; 'PFK'; 'PGI'};
map.rxnReversibility = {'true'; 'true'; 'false'; 'true'};

%% the listed reactions become irreversible; the others are unchanged

mapIrrev = transformToIrreversibleMap(map, {'PGI'; 'PFK'; 'NOT_IN_MAP'});
% text values, so the comparison is exact; PFK was already irreversible
assert(isequal(mapIrrev.rxnReversibility, {'true'; 'false'; 'false'; 'false'}));
assert(isequal(rmfield(mapIrrev, 'rxnReversibility'), rmfield(map, 'rxnReversibility')));

%% a single reaction name may be given as a character vector

mapIrrev = transformToIrreversibleMap(map, 'HEX1');
assert(isequal(mapIrrev.rxnReversibility, {'false'; 'true'; 'false'; 'true'}));

%% an empty list leaves the map unchanged

mapIrrev = transformToIrreversibleMap(map, {});
assert(isequal(mapIrrev, map));

% change the directory
cd(currentDir)
