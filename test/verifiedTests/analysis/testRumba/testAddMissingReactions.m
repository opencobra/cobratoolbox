% The COBRAToolbox: testAddMissingReactions.m
%
% Purpose:
%     - addMissingReactions maps the sampled flux points of a sampled model onto the reaction set of
%     a complete model, leaving the points of reactions missing from the sampled model at zero.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/rumba/addMissingReactions.m
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
fileDir = fileparts(which('testAddMissingReactions'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

completeModel.rxns = {'r1'; 'r2'; 'r3'};

%% points of reactions that are present are copied, missing reactions get zeros

clear sampled
sampled.rxns = {'r1'; 'r3'};
sampled.points = [1 2 3; 4 5 6];
model = addMissingReactions(sampled, completeModel);
assert(isequal(model.points, [1 2 3; 0 0 0; 4 5 6]));
assert(isequal(model.rxns, completeModel.rxns));

%% a different order in the sampled model is respected

sampled.rxns = {'r3'; 'r1'};
sampled.points = [1 2 3; 4 5 6];
model = addMissingReactions(sampled, completeModel);
assert(isequal(model.points, [4 5 6; 0 0 0; 1 2 3]));

%% all reactions present

sampled.rxns = {'r1'; 'r2'; 'r3'};
sampled.points = [1 2; 3 4; 5 6];
model = addMissingReactions(sampled, completeModel);
assert(isequal(model.points, sampled.points));

% change the directory
cd(currentDir)
