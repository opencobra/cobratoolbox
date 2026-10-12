% The COBRAToolbox: testBuildRxnEquationsFromName.m
%
% Purpose:
%     - buildRxnEquationsFromName writes a text equation for every reaction of a model using the metabolite NAMES (instead of IDs), with an arrow for the direction.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/buildRxnEquationsFromName.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Line 63 of buildRxnEquationsFromName.m (the line printing "do not understand directionality" for lower bound > 0 and upper bound <= 0) is uncovered: that input has no defined arrow.
%
% Known defects documented (NOT tested, NOT fixed here):
%     For a reaction that runs only backward (lower bound < 0, upper bound <= 0) the swap of educts and products is wrong (products = educts), so the equation lists the substrate on both sides (for example "(2) A <-- (-2) A"). That reaction is part of the model below only so that the branch runs; its equation is documented here and NOT tested.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testBuildRxnEquationsFromName'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% small model: R1 reversible, R2 forward, R3 backward only (see the header), R4 empty, R5 blocked
model.rxns = {'R1'; 'R2'; 'R3'; 'R4'; 'R5'; 'R6'};
model.mets = {'a_c'; 'b_c'; 'c_c'; 'd_c'};
model.metNames = {'A'; 'B'; 'C'; 'D'};
model.S = sparse([-1  0 -2 0 -1  0;
                   1 -1  0 0  1  0;
                   0  2  1 0  0 -1;
                   0  0  0 0  0  1]);
model.lb = [-1; 0; -1; 0; 0; 0];
model.ub = [ 1; 1;  0; 0; 0; 1];

%% equations written with metabolite names

plainModel = buildRxnEquationsFromName(model);
assert(strcmp(plainModel.rxnEquations{1}, 'A <==> B'));
assert(strcmp(plainModel.rxnEquations{2}, 'B --> (2) C'));
% (the equation of R3, the backward reaction, is not tested, see the header)
assert(isempty(plainModel.rxnEquations{4}));
assert(strcmp(plainModel.rxnEquations{5}, 'A ||| B'));
assert(strcmp(plainModel.rxnEquations{6}, 'C --> D'));

%% a merged (Tmodel-like) structure: bounds are taken from the first model

mergedModel = model;
mergedModel.lb = struct('modelA', [-1; 0; -1; 0; 0; 0], 'modelB', [-2; -2; -2; -2; -2; -2]);
mergedModel.ub = struct('modelA', [1; 1; 0; 0; 0; 1], 'modelB', [2; 2; 2; 2; 2; 2]);
mergedModel.Models = struct('modelA', 1, 'modelB', 2);
mergedModel = buildRxnEquationsFromName(mergedModel);
assert(strcmp(mergedModel.rxnEquations{1}, 'A <==> B'));
assert(strcmp(mergedModel.rxnEquations{2}, 'B --> (2) C'));
assert(strcmp(mergedModel.rxnEquations{6}, 'C --> D'));

% change the directory
cd(currentDir)
