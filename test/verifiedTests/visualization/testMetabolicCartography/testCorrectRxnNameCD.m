% The COBRAToolbox: testCorrectRxnNameCD.m
%
% Purpose:
%     - correctRxnNameCD(map, rxnStucture, rxnList) replaces, for each i, every reaction name
%       of the map equal to rxnStucture.extraRxnsMap{i} (the map names checkCDerrors does not
%       find in the model) by rxnList{i}. The test uses a hand-built map and a structure with
%       the fields checkCDerrors returns, and checks a name used twice, a name not in the map,
%       an empty list, and that nothing but rxnName changes. Expected names follow from the
%       documentation.
%
% Function under test:
%     src/visualization/metabolicCartography/correctRxnNameCD.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built map and checkCDerrors-like structure.
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
fileDir = fileparts(which('testCorrectRxnNameCD'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the map names HEX (twice) and PGI_old are not model reactions
map.rxnName = {'HEX'; 'ENO'; 'HEX'; 'PGI_old'};
map.rxnID = {'re1'; 're2'; 're3'; 're4'};
rxnStructure = struct('commonRxnsMapAndModel', {{'ENO'}}, ...
    'extraRxnsMap', {{'HEX'; 'PGI_old'}}, 'extraRxnModel', {{'HEX1'; 'PGI'}});

%% every occurrence of each wrong name gets the corresponding right name

newMap = correctRxnNameCD(map, rxnStructure, {'HEX1'; 'PGI'});
assert(isequal(newMap.rxnName, {'HEX1'; 'ENO'; 'HEX1'; 'PGI'}));
% only rxnName changes
assert(isequal(rmfield(newMap, 'rxnName'), rmfield(map, 'rxnName')));

%% a wrong name that is not in the map is skipped; an empty list changes nothing

rxnStructure.extraRxnsMap = {'notInMap'; 'PGI_old'};
newMap = correctRxnNameCD(map, rxnStructure, {'unused', 'PGI'});
assert(isequal(newMap.rxnName, {'HEX'; 'ENO'; 'HEX'; 'PGI'}));

rxnStructure.extraRxnsMap = {};
assert(isequal(correctRxnNameCD(map, rxnStructure, {}), map));

% change the directory
cd(currentDir)
