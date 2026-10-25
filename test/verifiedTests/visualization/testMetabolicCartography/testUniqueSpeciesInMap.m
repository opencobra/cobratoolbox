% The COBRAToolbox: testUniqueSpeciesInMap.m
%
% Purpose:
%     - uniqueSpeciesInMap lists the unique metabolites (names with the compartment removed) and the
%     unique non-metabolite species in the species names of a map.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/visualization/metabolicCartography/uniqueSpeciesInMap.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testUniqueSpeciesInMap'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% metabolites in several compartments and other species

map.specName = {'glc[c]'; 'glc[e]'; 'ATP'; 'atp'; 'ATP'; 'pyr[m]'};
species = uniqueSpeciesInMap(map);
assert(isequal(species.mets, {'glc'; 'pyr'}));
assert(isequal(species.nonMets, {'ATP'; 'atp'}));

%% only non-metabolites

species = uniqueSpeciesInMap(struct('specName', {{'a'; 'b'}}));
assert(isempty(species.mets) && isequal(species.nonMets, {'a'; 'b'}));

% change the directory
cd(currentDir)
