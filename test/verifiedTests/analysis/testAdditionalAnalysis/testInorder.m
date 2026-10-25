% The COBRAToolbox: testInorder.m
%
% Purpose:
%     - inorder collects the metabolites and reactions that are connected to a starting metabolite
%     within a given number of levels of the stoichiometric network.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/inorder.m
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
fileDir = fileparts(which('testInorder'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a linear chain of five metabolites and four reactions: m1 -> m2 -> m3 -> m4 -> m5
model.S = [-1  0  0  0; ...
            1 -1  0  0; ...
            0  1 -1  0; ...
            0  0  1 -1; ...
            0  0  0  1];

%% one level from the first metabolite

% the starting metabolite and its direct neighbour, over the first reaction
[mets, rxns] = inorder(1, model, [], [], 1);
assert(isequal(mets, [1 2]));
assert(isequal(rxns, 1));

%% two levels

[mets, rxns] = inorder(1, model, [], [], 2);
assert(isequal(mets, [1 2 3]));
assert(isequal(rxns, [1 2]));

%% enough levels to reach the whole network

[mets, rxns] = inorder(1, model, [], [], 5);
assert(isequal(mets, [1 2 3 4 5]));
assert(isequal(rxns, [1 2 3 4]));

%% starting from the last metabolite

% it only has the last reaction, which connects it to the fourth metabolite
[mets, rxns] = inorder(5, model, [], [], 0);
assert(isequal(mets, [4 5]));
assert(isequal(rxns, 4));

%% an empty start node returns the visited lists unchanged

[mets, rxns] = inorder([], model, [7], [8], 2);
assert(isequal(mets, 7) && isequal(rxns, 8));

%% reactions that were already visited are excluded

% the only reaction of m1 is already visited, so nothing new is found
[mets, rxns] = inorder(1, model, [], [1], 3);
assert(isequal(mets, 1) && isequal(rxns, 1));

% change the directory
cd(currentDir)
