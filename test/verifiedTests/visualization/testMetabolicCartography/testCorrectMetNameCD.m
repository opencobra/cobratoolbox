% The COBRAToolbox: testCorrectMetNameCD.m
%
% Purpose:
%     - correctMetNameCD(map, metStructure, metList) replaces, for each i, every species name
%       of the map equal to metStructure.extraMetsMap{i} (the map names checkCDerrors does not
%       find in the model) by metList{i}. The test uses a hand-built map and a structure with
%       the fields checkCDerrors returns, and checks a name used twice, a name not in the map,
%       an empty list, and that nothing but specName changes. Expected names follow from the
%       documentation.
%
% Function under test:
%     src/visualization/metabolicCartography/correctMetNameCD.m
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
fileDir = fileparts(which('testCorrectMetNameCD'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the map names glc_D[c] (twice) and water[c] are not model metabolites
map.specName = {'glc_D[c]'; 'atp[c]'; 'glc_D[c]'; 'water[c]'};
map.specID = {'s1'; 's2'; 's3'; 's4'};
metStructure = struct('commonMetsMapAndModel', {{'atp[c]'}}, ...
    'extraMetsMap', {{'glc_D[c]'; 'water[c]'}}, 'extraMetsModel', {{'glc-D[c]'; 'h2o[c]'}});

%% every occurrence of each wrong name gets the corresponding right name

newMap = correctMetNameCD(map, metStructure, {'glc-D[c]'; 'h2o[c]'});
assert(isequal(newMap.specName, {'glc-D[c]'; 'atp[c]'; 'glc-D[c]'; 'h2o[c]'}));
% only specName changes
assert(isequal(rmfield(newMap, 'specName'), rmfield(map, 'specName')));

%% a wrong name that is not in the map is skipped; an empty list changes nothing

metStructure.extraMetsMap = {'notInMap[c]'; 'water[c]'};
newMap = correctMetNameCD(map, metStructure, {'unused[c]', 'h2o[c]'});
assert(isequal(newMap.specName, {'glc_D[c]'; 'atp[c]'; 'glc_D[c]'; 'h2o[c]'}));

metStructure.extraMetsMap = {};
assert(isequal(correctMetNameCD(map, metStructure, {}), map));

% change the directory
cd(currentDir)
