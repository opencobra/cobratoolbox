% The COBRAToolbox: testBuildRxnEquations.m
%
% Purpose:
%     - buildRxnEquations writes a text equation for every reaction of a model from its stoichiometry, metabolite IDs and bounds (the arrow shows the direction).
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/buildRxnEquations.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Line 62 of buildRxnEquations.m (the line printing "Do not understand directionality" reached only for bounds with lower bound > 0 and upper bound <= 0) is uncovered: that input has no defined arrow.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testBuildRxnEquations'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% small model: R1 reversible, R2 irreversible forward with a coefficient 2, R3 backward with a
% coefficient 2, R4 empty, R5 blocked, R6 forward
model.rxns = {'R1'; 'R2'; 'R3'; 'R4'; 'R5'; 'R6'};
model.mets = {'a_c'; 'b_c'; 'c_c'; 'd_c'};
model.S = sparse([-1  0 -2 0 -1  0;
                   1 -1  0 0  1  0;
                   0  2  1 0  0 -1;
                   0  0  0 0  0  1]);
model.lb = [-1; 0; -1; 0; 0; 0];
model.ub = [ 1; 1;  0; 0; 0; 1];

%% equations of a plain model (a coefficient of -1 or 1 is not written)

plainModel = buildRxnEquations(model);
assert(strcmp(plainModel.rxnEquations{1}, 'a_c <==> b_c'));
assert(strcmp(plainModel.rxnEquations{2}, 'b_c --> (2) c_c'));
assert(strcmp(plainModel.rxnEquations{3}, '(2) a_c <-- c_c'));
% a reaction without any metabolite has an empty equation
assert(isempty(plainModel.rxnEquations{4}));
% lower and upper bound both 0: blocked
assert(strcmp(plainModel.rxnEquations{5}, 'a_c ||| b_c'));
assert(strcmp(plainModel.rxnEquations{6}, 'c_c --> d_c'));

%% a merged (Tmodel-like) structure: bounds are taken from the first model

mergedModel = model;
mergedModel.lb = struct('modelA', [-1; 0; -1; 0; 0; 0], 'modelB', [-2; -2; -2; -2; -2; -2]);
mergedModel.ub = struct('modelA', [1; 1; 0; 0; 0; 1], 'modelB', [2; 2; 2; 2; 2; 2]);
mergedModel.Models = struct('modelA', 1, 'modelB', 2);
mergedModel = buildRxnEquations(mergedModel);
% the equations use the bounds of modelA, so they are the same as for the plain model
assert(strcmp(mergedModel.rxnEquations{1}, 'a_c <==> b_c'));
assert(strcmp(mergedModel.rxnEquations{2}, 'b_c --> (2) c_c'));
assert(strcmp(mergedModel.rxnEquations{3}, '(2) a_c <-- c_c'));
assert(strcmp(mergedModel.rxnEquations{5}, 'a_c ||| b_c'));
assert(strcmp(mergedModel.rxnEquations{6}, 'c_c --> d_c'));

% change the directory
cd(currentDir)
