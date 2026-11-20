% The COBRAToolbox: testFindMetsFromCompartInMap.m
%
% Purpose:
%     - findMetsFromCompartInMap returns the species names of a CellDesigner map structure that
%       contain a compartment string (e.g. '[m]') and their indices in map.specName. The test
%       uses a hand-built map and checks matches, the substring rule (the string may appear
%       anywhere in the name) and the empty result. Expected values are read off the hand-built
%       names (documentation: names and indexes of the metabolites of the compartment).
%
% Function under test:
%     src/visualization/metabolicCartography/findMetsFromCompartInMap.m
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
fileDir = fileparts(which('testFindMetsFromCompartInMap'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% species names of a map: two mitochondrial, two cytosolic, one without compartment
map.specName = {'atp[m]'; 'glc_D[c]'; 'cit[m]'; 'hk'; 'g6p[c]'};

%% the metabolites of a compartment and their indices

[mets, id] = findMetsFromCompartInMap(map, '[m]');
% indices are integers, so the comparison is exact
assert(isequal(id, [1; 3]));
assert(isequal(mets, {'atp[m]'; 'cit[m]'}));

[mets, id] = findMetsFromCompartInMap(map, '[c]');
assert(isequal(id, [2; 5]));
assert(isequal(mets, {'glc_D[c]'; 'g6p[c]'}));

%% the compartment string is matched anywhere in the name (substring search)

% 'g' is no compartment but occurs in glc_D[c] and g6p[c]
[mets, id] = findMetsFromCompartInMap(map, 'g');
assert(isequal(id, [2; 5]));
assert(isequal(mets, {'glc_D[c]'; 'g6p[c]'}));

%% no metabolite in the compartment: empty outputs

[mets, id] = findMetsFromCompartInMap(map, '[e]');
assert(isempty(id));
assert(iscell(mets) && isempty(mets));

% change the directory
cd(currentDir)
