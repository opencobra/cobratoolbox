% The COBRAToolbox: testChrrParseModel.m
%
% Purpose:
%     - chrrParseModel converts a COBRA model into the polytope structure used by the CHRR sampler:
%     bounds as inequalities, the stoichiometric equalities, and optional extra inequalities
%     converted to the less-or-equal form.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Defect(s) fixed by feature 20261102-140321-tier1-safe-defect-fixes: Extra constraints with
%       a less-than or equality sense cannot be used.
%
% Function under test:
%     src/analysis/sampling/CHRR/chrrParseModel.m
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
%     - Updated for feature 20261102-140321-tier1-safe-defect-fixes, 2026-11-02.

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

%% extra constraints with sense L are kept, also when the sense is a cell array

withL = model;
withL.C = [1 1; 1 -1];
withL.d = [3; 1];
withL.dsense = 'LG';
[P, newModel] = chrrParseModel(withL);
% the L row is appended unchanged, the G row is negated
assert(isequal(P.A(5:6, :), [1 1; -1 1]));
assert(isequal(P.b(5:6), [3; -1]));
assert(isequal(newModel.C, [1 1; -1 1]) && isequal(newModel.d, [3; -1]));

% the same senses given as a cell array give the same result
withCell = withL;
withCell.dsense = {'L'; 'G'};
[PCell, newModelCell] = chrrParseModel(withCell);
assert(isequal(PCell, P));
assert(isequal(newModelCell.C, newModel.C) && isequal(newModelCell.d, newModel.d));

%% extra constraints with sense E raise the documented error

withE = model;
withE.C = [1 1; 1 -1];
withE.d = [3; 1];
withE.dsense = 'GE';
assert(verifyCobraFunctionError('chrrParseModel', 'inputs', {withE}, ...
    'testMessage', 'Equality constraints not supported in C,d fields.'));
withE.dsense = {'G'; 'E'};
assert(verifyCobraFunctionError('chrrParseModel', 'inputs', {withE}, ...
    'testMessage', 'Equality constraints not supported in C,d fields.'));

% change the directory
cd(currentDir)
