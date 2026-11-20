% The COBRAToolbox: testFindMetsInMap.m
%
% Purpose:
%     - findMetsInMap returns the indices in map.specName of the species whose names are in a
%       given list (exact, case-sensitive name match). The test uses a hand-built map and
%       checks a list, a single name given as a character vector, duplicated map names, the
%       order of the result (map order, not list order) and the empty result. Expected indices
%       are read off the hand-built names.
%
% Function under test:
%     src/visualization/metabolicCartography/findMetsInMap.m
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
fileDir = fileparts(which('testFindMetsInMap'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% species names of a map; atp[c] is listed twice (two species of the same name)
map.specName = {'atp[c]'; 'glc_D[c]'; 'adp[c]'; 'atp[c]'; 'g6p[c]'};

%% indices of the listed metabolites, in map order

% indices are integers, so comparisons are exact; the list order (g6p first) is not kept
metID = findMetsInMap(map, {'g6p[c]'; 'glc_D[c]'});
assert(isequal(metID, [2; 5]));

%% a name present several times in the map returns all its indices

metID = findMetsInMap(map, {'atp[c]'});
assert(isequal(metID, [1; 4]));

%% a single name may be given as a character vector

metID = findMetsInMap(map, 'adp[c]');
assert(isequal(metID, 3));

%% names absent from the map (also with another case) are ignored

metID = findMetsInMap(map, {'ATP[c]'; 'nad[c]'});
assert(isempty(metID));

% change the directory
cd(currentDir)
