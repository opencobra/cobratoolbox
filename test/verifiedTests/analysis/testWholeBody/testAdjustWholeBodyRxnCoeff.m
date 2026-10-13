% The COBRAToolbox: testAdjustWholeBodyRxnCoeff.m
%
% Purpose:
%     - adjustWholeBodyRxnCoeff sets, in the whole-body objective reaction, the coefficient of each
%     organ biomass dummy metabolite to minus its organ fraction in percent.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/adjustWholeBodyRxnCoeff.m
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
fileDir = fileparts(which('testAdjustWholeBodyRxnCoeff'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons
tol = 1e-12;

% two organ dummy-objective metabolites and one metabolite that does not match
model.rxns = {'Whole_body_objective_rxn'; 'other'};
model.mets = {'Liver_biomass_dummy_objective'; 'Brain_biomass_dummy_objective'; 'Liver_biomass[c]'};
model.S = zeros(3, 2);

%% coefficients of the listed organs

newModel = adjustWholeBodyRxnCoeff(model, {'Liver', 'Brain'}, [0.5 0.25]);
% fractions are written as percentages with a negative sign
assert(norm(newModel.S(:, 1) - [-50; -25; 0]) < tol);
assert(all(newModel.S(:, 2) == 0));
% the helper matrix A is not left in the model
assert(~isfield(newModel, 'A'));

%% only the listed organs change

newModel = adjustWholeBodyRxnCoeff(model, {'Brain'}, 0.4);
assert(norm(newModel.S(:, 1) - [0; -40; 0]) < tol);

%% an existing field A is kept and updated

withA = model;
withA.A = zeros(3, 2);
newModel = adjustWholeBodyRxnCoeff(withA, {'Liver'}, 0.2);
assert(isfield(newModel, 'A'));
assert(norm(newModel.A(:, 1) - [-20; 0; 0]) < tol && isequal(newModel.S, newModel.A));

%% an organ without a dummy objective metabolite changes nothing

newModel = adjustWholeBodyRxnCoeff(model, {'Kidney'}, 0.3);
assert(isequal(newModel.S, model.S));

% change the directory
cd(currentDir)
