% The COBRAToolbox: testFlipRxnOrientation.m
%
% Purpose:
%     - flipRxnOrientation reverses the direction of the listed reactions: stoichiometry and
%     objective change sign and the bounds are exchanged and negated; reactions not in the model are
%     reported.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/refinement/flipRxnOrientation.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The message for reactions that are not in the model has no line break
%       SEVERITY: cosmetic
%       TRIGGER: a reaction list with identifiers that are not in the model
%       OBSERVED: the message is printed with fprintf and no newline, so several messages are
%         printed on one line
%       EXPECTED: one message per line
%       LINES: 31
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFlipRxnOrientation'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.rxns = {'r1'; 'r2'; 'r3'};
model.S = [-1 1 0; 1 0 -1];
model.c = [1; 0; 2];
model.lb = [0; -5; 1];
model.ub = [10; 5; 3];

%% flipping a reaction

flipped = flipRxnOrientation(model, {'r1'});
assert(isequal(flipped.S(:, 1), [1; -1]) && isequal(flipped.S(:, 2:3), model.S(:, 2:3)));
assert(isequal(flipped.c, [-1; 0; 2]));
assert(isequal(flipped.lb, [-10; -5; 1]) && isequal(flipped.ub, [0; 5; 3]));

%% flipping several reactions, in any order

flipped = flipRxnOrientation(model, {'r3', 'r1'});
assert(isequal(flipped.lb, [-10; -5; -3]) && isequal(flipped.ub, [0; 5; -1]));
assert(isequal(flipped.c, [-1; 0; -2]));

%% flipping twice restores the model

twice = flipRxnOrientation(flipRxnOrientation(model, {'r1', 'r2'}), {'r1', 'r2'});
assert(isequal(twice.S, model.S) && isequal(twice.lb, model.lb) && isequal(twice.ub, model.ub) && isequal(twice.c, model.c));

%% reactions that are not in the model are reported

text = evalc("flipped = flipRxnOrientation(model, {'r1', 'unknown'});");
assert(contains(text, 'Reaction unknown not present in model!'));
assert(isequal(flipped.lb(1), -10));

% change the directory
cd(currentDir)
