% The COBRAToolbox: testPValDistForModelOverlap.m
%
% Purpose:
%     - pValDistForModelOverlap computes, for every reaction of two sampled models, the change in
%     the median absolute flux between the two conditions, treating a reaction missing from one
%     model as carrying zero flux.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/rumba/pValDistForModelOverlap.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Line 42, the warning for reactions missing from the sampled models: both models are first
%     extended with the reactions of the other, so every reaction of the first model is always in
%     common and the warning cannot be reached.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPValDistForModelOverlap'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model1.rxns = {'r1'; 'r2'};
model1.points = [1 -2 3; 4 5 6];
model2.rxns = {'r2'; 'r3'};
model2.points = [2 2 2; 7 7 7];

%% reactions in common and a reaction missing from the second model

[rxnsInCommon, medianChange] = pValDistForModelOverlap(model1, model2);
% the list is that of the first model followed by the reactions only in the second model
assert(isequal(rxnsInCommon, {'r1'; 'r2'; 'r3'}));
% median |flux| in model 2 minus model 1: r1 0 - 2, r2 2 - 5, r3 7 - 0
assert(isequal(medianChange, [-2; -3; 7]));

%% identical models give no change

[rxnsInCommon, medianChange] = pValDistForModelOverlap(model1, model1);
assert(isequal(rxnsInCommon, model1.rxns));
assert(all(medianChange == 0));

%% only the first columns are used when the sample sizes differ

shortModel = model1;
shortModel.points = [1; 4];
[~, medianChange] = pValDistForModelOverlap(model1, shortModel);
% with one point each: model 2 minus model 1, using only column 1 of both
assert(isequal(medianChange, [0; 0]));

% change the directory
cd(currentDir)
