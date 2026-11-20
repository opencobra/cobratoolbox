% The COBRAToolbox: testFindRxnsFromCompartInMap.m
%
% Purpose:
%     - findRxnsFromCompartInMap returns the reaction names of a CellDesigner map structure
%       that contain a compartment string (e.g. '[m]') and their indices in map.rxnName. The
%       test uses a hand-built map and checks matches, the substring rule (the string may
%       appear anywhere in the name) and the empty result. Expected values are read off the
%       hand-built names (documentation: names and indexes of the reactions of the compartment).
%
% Function under test:
%     src/visualization/metabolicCartography/findRxnsFromCompartInMap.m
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
fileDir = fileparts(which('testFindRxnsFromCompartInMap'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% reaction names of a map: transporters named with their compartments
map.rxnName = {'CSm'; 'GLCt[e]'; 'ATPtm[m]'; 'HEX1'; 'ACONT[m]'};

%% the reactions of a compartment and their indices

[rxns, id] = findRxnsFromCompartInMap(map, '[m]');
% indices are integers, so the comparison is exact
assert(isequal(id, [3; 5]));
assert(isequal(rxns, {'ATPtm[m]'; 'ACONT[m]'}));

%% the compartment string is matched anywhere in the name (substring search)

% 'm' without brackets also matches CSm and ATPtm[m]
[rxns, id] = findRxnsFromCompartInMap(map, 'm');
assert(isequal(id, [1; 3; 5]));
assert(isequal(rxns, {'CSm'; 'ATPtm[m]'; 'ACONT[m]'}));

%% no reaction in the compartment: empty outputs

[rxns, id] = findRxnsFromCompartInMap(map, '[n]');
assert(isempty(id));
assert(iscell(rxns) && isempty(rxns));

% change the directory
cd(currentDir)
