% The COBRAToolbox: testChrrParseModel.m
%
% Purpose:
%     - chrrParseModel converts a COBRA model into the polytope structure used by the CHRR sampler:
%     bounds as inequalities, the stoichiometric equalities, and optional extra inequalities
%     converted to the less-or-equal form.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/sampling/CHRR/chrrParseModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 53-54, the branch for a sense other than G (see the known defect below): every input
%     that reaches it stops with an error.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Extra constraints with a less-than or equality sense cannot be used
%       SEVERITY: error
%       TRIGGER: model.C, model.d and model.dsense with an L or E entry, or with dsense given as a
%         cell array
%       OBSERVED: the sense is read with parentheses for G and with braces for E, so a character
%         dsense with an L entry (or any E entry) stops with "Brace indexing is not supported" and a
%         cell dsense stops with an invalid data type error; only a character dsense made of G
%         entries works
%       EXPECTED: L entries are kept, G entries are negated, and E entries raise the documented "not
%         supported" error
%       LINES: 49-56
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testChrrParseModel'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.S = [1 -1];
model.b = 0;
model.lb = [0; 0];
model.ub = [5; 6];

%% bounds and mass balance only

[P, newModel] = chrrParseModel(model);
% identity for the upper bounds and minus identity for the lower bounds
assert(isequal(P.A, [1 0; 0 1; -1 0; 0 -1]));
assert(isequal(P.b, [5; 6; 0; 0]));
assert(isequal(P.A_eq, model.S) && isequal(P.b_eq, model.b));
assert(isequal(newModel, model));

%% extra constraints written with sense G are converted to the less-or-equal form

withC = model;
withC.C = [1 1; 1 -1];
withC.d = [3; 1];
withC.dsense = 'GG';
[P, newModel] = chrrParseModel(withC);
% C x >= d becomes -C x <= -d and is appended below the bounds
assert(isequal(P.A(5:6, :), [-1 -1; -1 1]));
assert(isequal(P.b(5:6), [-3; -1]));
assert(isequal(newModel.C, [-1 -1; -1 1]) && isequal(newModel.d, [-3; -1]));

% change the directory
cd(currentDir)
