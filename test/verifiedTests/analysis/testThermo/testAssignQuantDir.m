% The COBRAToolbox: testAssignQuantDir.m
%
% Purpose:
%     - assignQuantDir sets the thermodynamically feasible bounds and the directionality label of
%     every internal reaction from the minimum and maximum of its transformed reaction Gibbs energy,
%     falling back to the model bounds when the energy is unknown.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/thermo/thermoDirectionality/assignQuantDir.m
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
fileDir = fileparts(which('testAssignQuantDir'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% six internal reactions
%   1 forward (DrGt always negative)      2 unknown energy, bounds 0..10 (forward)
%   3 reversible (range -2..2)            4 unknown-free reversible, bounds -10..0
%   5 DrGtMin = DrGtMax > 0 (equilibrium) 6 DrGtMin = DrGtMax = 0
base.S = zeros(2, 6);
base.rxns = {'r1'; 'r2'; 'r3'; 'r4'; 'r5'; 'r6'};
base.SIntRxnBool = true(6, 1);
base.DfGt0 = [1; 2];
base.DrGt0 = [1; NaN; 2; 3; 4; 5];
base.DrGtMin = [-5; 1; -2; -2; 3; 0];
base.DrGtMax = [-1; 5; 2; 2; 3; 0];
base.lb = [-10; 0; -10; -10; 0; -5];
base.ub = [10; 10; 10; 0; 10; 5];

%% thermodynamic bounds and directionality labels

[text, model] = runAssign(base);
assert(isequal(model.lb_reconThermo, [0; 0; -Inf; -Inf; -Inf; -5]));
assert(isequal(model.ub_reconThermo, [Inf; Inf; Inf; Inf; 0; 5]));
% r2 has no energy: no label (NaN). r5 is first 'reverse' and then 'equilibrium' because DrGtMin == DrGtMax
assert(strcmp(model.directionalityThermo{1}, 'forward'));
assert(isnan(model.directionalityThermo{2}));
assert(strcmp(model.directionalityThermo{3}, 'reversible'));
assert(strcmp(model.directionalityThermo{4}, 'reversible'));
assert(strcmp(model.directionalityThermo{5}, 'equilibrium'));
assert(strcmp(model.directionalityThermo{6}, 'equilibrium'));
% boolean helpers
assert(isequal(model.NaNdfG0MetBool, [false; false]));
assert(isequal(model.NaNd0GRxnBool, [false; true; false; false; false; false]));

%% messages about equal and zero energy ranges

[text, ~] = runAssign(base);
assert(contains(text, '1/6 reactions with DrGtMin=DrGtMax~=0'));
assert(contains(text, '1/6 reactions with DrGtMin=DrGtMax=0'));

%% model bounds are used when the energy is unknown

m = base;
m.DrGt0 = NaN(6, 1);
% reversible, forward, reverse and a reversible reaction with bounds -1..0
m.lb = [-5; 0; -3; -2; -1; 0];
m.ub = [5; 8; -1; 4; 0; 1];
[~, model] = runAssign(m);
assert(isequal(model.lb_reconThermo, [-Inf; 0; -Inf; -Inf; -Inf; 0]));
assert(isequal(model.ub_reconThermo, [Inf; Inf; 0; Inf; 0; Inf]));
assert(all(cellfun(@(x) isnan(x), model.directionalityThermo)));

%% a minimum above the maximum is an error

m = base;
m.DrGtMin(1) = 0;
m.DrGtMax(1) = -1;
verifyCobraFunctionError('assignQuantDir', 'inputs', {m}, 'testMessage', 'DrGtMin greater than DrGtMax');

%% a reaction with both bounds at zero is an error

% with unknown energy
m = base;
m.DrGt0(1) = NaN;
m.lb(1) = 0;
m.ub(1) = 0;
verifyCobraFunctionError('assignQuantDir', 'inputs', {m}, 'testMessage', 'bounds set to zero');
% with known energy
m = base;
m.lb(1) = 0;
m.ub(1) = 0;
verifyCobraFunctionError('assignQuantDir', 'inputs', {m}, 'testMessage', 'bounds set to zero');

%% only internal reactions are changed

m = base;
m.SIntRxnBool = false(6, 1);
[~, model] = runAssign(m);
assert(isequal(model.lb_reconThermo, base.lb) && isequal(model.ub_reconThermo, base.ub));


function [text, model] = runAssign(model)
% Run assignQuantDir and return the text it prints; warnings stay visible in the log.
text = evalc('model = assignQuantDir(model);');
end

% change the directory
cd(currentDir)
