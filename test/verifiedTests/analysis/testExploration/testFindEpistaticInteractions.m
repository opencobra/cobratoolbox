% The COBRAToolbox: testFindEpistaticInteractions.m
%
% Purpose:
%     - findEpistaticInteractions finds synthetic sick and synthetic lethal gene pairs from a matrix
%     of double-deletion fitness values and returns a symmetric interaction matrix and the size of
%     each epistatic effect.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/exploration/findEpistaticInteractions.m
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
fileDir = fileparts(which('testFindEpistaticInteractions'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons: effects are differences of values of order 1
tol = 1e-12;

% three genes; the diagonal holds the single-deletion fitness values
model.genes = {'g1'; 'g2'; 'g3'};
fitness = [1.0 0.5 0.9; ...
           0.5 1.0 0.0; ...
           0.9 0.0 0.8];

%% synthetic sick interactions with the default minimum effect (0.01)

[interactions, effect] = findEpistaticInteractions(model, fitness);
% the pair (g1,g2) falls from 1 and 1 to 0.5 and the pair (g2,g3) from 1 and 0.8 to 0;
% the pair (g1,g3) (0.9 against 1 and 0.8) is not lower than both single deletions
assert(issparse(interactions));
assert(isequal(full(interactions), [0 1 0; 1 0 1; 0 1 0]));
% effect = min(f1 - f12, f2 - f12), stored symmetrically
assert(norm(effect - [0 0.5 0; 0.5 0 0.8; 0 0.8 0], 'fro') < tol);

%% synthetic lethal interactions only

% only the pair (g2,g3) has a double-deletion fitness below the minimum effect
[interactions, effect] = findEpistaticInteractions(model, fitness, true);
assert(isequal(full(interactions), [0 0 0; 0 0 1; 0 1 0]));
assert(abs(effect(2, 3) - 0.8) < tol && effect(1, 2) == 0);

%% a larger minimum effect removes weak interactions

% requiring a drop of at least 0.6 removes the pair (g1,g2), which drops by 0.5
[interactions, effect] = findEpistaticInteractions(model, fitness, false, 0.6);
assert(isequal(full(interactions), [0 0 0; 0 0 1; 0 1 0]));
assert(abs(effect(3, 2) - 0.8) < tol);

%% no interaction

[interactions, effect] = findEpistaticInteractions(model, ones(3));
assert(nnz(interactions) == 0 && all(effect(:) == 0));

% change the directory
cd(currentDir)
