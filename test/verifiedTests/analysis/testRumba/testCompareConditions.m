% The COBRAToolbox: testCompareConditions.m
%
% Purpose:
%     - compareConditions compares reaction scores around shared metabolites between two sampled conditions and returns the reactions that changed, with up/down p-values and flux directions.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/rumba/compareConditions.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Sample-point count taken from the first metabolite of the first list
%       SEVERITY: limitation
%       TRIGGER: metabolites with different numbers of sample points
%       OBSERVED: MinNumPts is computed once from the first metabolite of the first list and used
%         for all
%       EXPECTED: the minimum over all compared metabolites
%       LINES: 52
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCompareConditions'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% metabolite Met_a: three reactions, 2 sample points in condition 1, 3 in condition 2
% (only the first 2 points of each are compared)
connectivity1.Met_a = struct('RxnScore', [0.5 0.6; 0.5 0.4; 0.3 0.2], 'MetNotUsed', [0 0], ...
                             'Direction', [1 1; -1 -1; 1 -1], 'ConnRxns', {{'R1'; 'R2'; 'R3'}});
connectivity2.Met_a = struct('RxnScore', [0.4 0.7 0.9; 0.5 0.4 0.9; 0.6 0.4 0.9], 'MetNotUsed', [0 0 0], ...
                             'Direction', [1 1 1; -1 -1 -1; -1 -1 -1], 'ConnRxns', {{'R1'; 'R2'; 'R3'}});
% metabolite Met_b: unused by (almost) all sample points of condition 1 -> skipped
connectivity1.Met_b = struct('RxnScore', [0.5 0.5], 'MetNotUsed', [1 1], 'Direction', [1 1], 'ConnRxns', {{'R4'}});
connectivity2.Met_b = struct('RxnScore', [0.1 0.9], 'MetNotUsed', [0 0], 'Direction', [1 1], 'ConnRxns', {{'R4'}});
% metabolite Met_c exists only in condition 1 -> not compared
connectivity1.Met_c = connectivity1.Met_b;

%% metabolites present in both conditions are compared, reactions without change are skipped

[metsAndRxns, pValUp, pValDown, direction1, direction2] = compareConditions( ...
    connectivity1, {'Met_a'; 'Met_b'; 'Met_c'}, connectivity2, {'Met_a'; 'Met_b'});

% Met_a / R1: score differences [0.1 -0.1] -> half of the points up, half down
% Met_a / R2: differences [0 0] -> no change, skipped
% Met_a / R3: differences [-0.3 -0.2] -> never up, always down
% Met_b is skipped because condition 1 does not use it; Met_c is not shared
assert(isequal(metsAndRxns, {'Met_a', 'R1'; 'Met_a', 'R3'}));
% p-values are fractions of 2 sample points, hence exactly representable
assert(isequal(pValUp, [0.5; 0]));
assert(isequal(pValDown, [0.5; 1]));
% median flux direction of each reaction in each condition (R3 in condition 1 is [1 -1] -> 0)
assert(isequal(direction1, [1; 0]));
assert(isequal(direction2, [1; -1]));

%% the roles of the two conditions can be swapped

% the unused metabolite is now in condition 2's position and is still skipped
[metsAndRxns, pValUp, pValDown, direction1, direction2] = compareConditions( ...
    connectivity2, {'Met_a'; 'Met_b'}, connectivity1, {'Met_a'; 'Met_b'; 'Met_c'});
assert(isequal(metsAndRxns, {'Met_a', 'R1'; 'Met_a', 'R3'}));
assert(isequal(pValUp, [0.5; 1]));
assert(isequal(pValDown, [0.5; 0]));
assert(isequal(direction1, [1; -1]));
assert(isequal(direction2, [1; 0]));

% change the directory
cd(currentDir)
