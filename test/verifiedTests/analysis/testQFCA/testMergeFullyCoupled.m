% The COBRAToolbox: testMergeFullyCoupled.m
%
% Purpose:
%     - mergeFullyCoupled merges two fully coupled reactions i and j of a stoichiometric matrix:
%     column j is added to column i (times the coupling ratio c) and removed, with the reversibility
%     and the names combined.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/QFCA/mergeFullyCoupled.m
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
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMergeFullyCoupled'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

S = [1 2 0; 0 1 3; 1 0 1];
rxns = {'a'; 'b'; 'c'};

%% merge reaction 2 into 1 with a positive ratio

% column 1 becomes column 1 + 2 * column 2 = [5; 2; 1]; column 2 is removed
[mergedS, mergedRev, mergedRxns] = mergeFullyCoupled(S, [1; 0; -1], rxns, 1, 2, 2);
assert(isequal(mergedS, [5 0; 2 3; 1 1]));
% reaction 2 is not flagged 1, so its reversibility is taken over (c > 0)
assert(isequal(mergedRev, [0; -1]));
assert(isequal(mergedRxns, {'a, b'; 'c'}));

%% a negative ratio flips the reversibility

% rev(i) = -1 - rev(j) = -1
[~, mergedRev] = mergeFullyCoupled(S, [1; 0; -1], rxns, 1, 2, -2);
assert(isequal(mergedRev, [-1; -1]));
[~, mergedRev] = mergeFullyCoupled(S, [0; -1; -1], rxns, 1, 2, 3);
assert(isequal(mergedRev, [-1; -1]));

%% a reaction j flagged 1 leaves the reversibility of i unchanged

[~, mergedRev] = mergeFullyCoupled(S, [1; 1; -1], rxns, 1, 2, -2);
assert(isequal(mergedRev, [1; -1]));

% change the directory
cd(currentDir)
