% The COBRAToolbox: testAugmentBOF.m
%
% Purpose:
%     - augmentBOF adds a small objective coefficient to the reaction that is connected to the
%     target reaction through its only metabolite, so that the target reaction can be optimised
%     together with it.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%       Defect(s) fixed by feature 20261102-140321-tier1-safe-defect-fixes: The outputs are not
%       assigned when the function cannot augment the objective.
%
% Function under test:
%     src/design/augmentBOF.m
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
fileDir = fileparts(which('testAugmentBOF'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons
tol = 1e-15;

% biomass reaction and one connected reaction through the metabolite m
model.rxns = {'bio'; 'OMtrans'; 'other'};
model.mets = {'m'};
model.S = [-1 1 0];
model.c = [1; 0; 0];

%% the connected reaction gets the epsilon coefficient

[newModel, rxnName] = augmentBOF(model, 'bio');
assert(strcmp(rxnName, 'OMtrans'));
% default epsilon 1e-5
assert(abs(newModel.c(2) - 1e-5) < tol && newModel.c(1) == 1 && newModel.c(3) == 0);

%% a given epsilon

[newModel, ~] = augmentBOF(model, 'bio', 0.01);
assert(abs(newModel.c(2) - 0.01) < tol);

%% three or more reactions on the metabolite: the function does not augment

busy = model;
busy.S = [-1 1 1];
text = evalc("augmentBOF(busy, 'bio', 1e-3, 1);");
assert(contains(text, 'augmentBOF will not work.'));
% without print level there is no message
text = evalc("augmentBOF(busy, 'bio');");
assert(isempty(text));

%% three or more reactions on the metabolite, with outputs: the model is unchanged

% (formerly a known defect: the outputs were not assigned and the call stopped with an error)
[busyModel, busyRxnName] = augmentBOF(busy, 'bio');
assert(isequal(busyModel, busy));
assert(isempty(busyRxnName) && ischar(busyRxnName));

% change the directory
cd(currentDir)
