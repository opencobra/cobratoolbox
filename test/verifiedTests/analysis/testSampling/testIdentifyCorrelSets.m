% The COBRAToolbox: testIdentifyCorrelSets.m
%
% Purpose:
%     - identifyCorrelSets finds sets of reactions whose sampled fluxes are correlated above a
%     threshold, returning the sets sorted by size, the set number of each reaction and the set
%     sizes.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/sampling/identifyCorrelSets.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The function stops with an error when no reactions are correlated
%       SEVERITY: error
%       TRIGGER: a correlation matrix (or sample) in which no pair of reactions reaches the
%         threshold
%       OBSERVED: no set is created, so the set list is never defined and the function stops with
%         "Unrecognized function or variable setSize"
%       EXPECTED: empty outputs
%       LINES: 65-79
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testIdentifyCorrelSets'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.rxns = {'a'; 'b'; 'c'; 'd'};
% a, b and d are linear functions of t; c is a sine of t and not fully correlated
t = 1:10;
sample = [t; 2 * t; sin(t); 3 * t + 1];

%% correlation computed from a sample

[setsSorted, setNoSorted, setSize] = identifyCorrelSets(model, sample);
assert(isequal(setNoSorted, [1; 1; 0; 1]));
assert(isequal(setSize, 3));
assert(isequal(setsSorted{1}.set, [1; 2; 4]));
assert(isequal(setsSorted{1}.names, {'a'; 'b'; 'd'}));

%% a given correlation matrix and threshold

% a-b fully correlated, c-d fully anticorrelated, a-c at 0.5 (below the threshold)
R = zeros(4);
R(1, 2) = 1; R(2, 1) = 1;
R(3, 4) = -1; R(4, 3) = -1;
R(1, 3) = 0.5; R(3, 1) = 0.5;
[setsSorted, setNoSorted, setSize] = identifyCorrelSets(model, sample, 0.9, R);
% two sets of the same size: the set found last comes first after sorting
assert(isequal(setSize, [2; 2]));
assert(isequal(setNoSorted, [2; 2; 1; 1]));
assert(isequal(setsSorted{1}.names, {'c'; 'd'}) && isequal(setsSorted{2}.names, {'a'; 'b'}));

%% sets are sorted by size, largest first

% five reactions: a pair (a, b) and a group of three (c, d, e), all fully correlated within
% their group; the group of three is found second but sorted first
model5.rxns = {'a'; 'b'; 'c'; 'd'; 'e'};
R = zeros(5);
R(1, 2) = 1; R(2, 1) = 1;
R(3, 4) = 1; R(3, 5) = 1; R(4, 3) = 1; R(4, 5) = 1; R(5, 3) = 1; R(5, 4) = 1;
[setsSorted, setNoSorted, setSize] = identifyCorrelSets(model5, rand(5, 4), 0.9, R);
assert(isequal(setSize, [3; 2]));
assert(isequal(setNoSorted, [2; 2; 1; 1; 1]));
assert(isequal(setsSorted{1}.names, {'c'; 'd'; 'e'}) && isequal(setsSorted{2}.names, {'a'; 'b'}));

% change the directory
cd(currentDir)
