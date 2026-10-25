% The COBRAToolbox: testFixIrr.m
%
% Purpose:
%     - fixIrr marks the reversible reactions of a model and rewrites reactions that only run
%     backward as forward reactions by flipping the sign of their stoichiometry and swapping the
%     bounds.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/transcriptomics/rFASTCORMICS/fixIrr.m
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
fileDir = fileparts(which('testFixIrr'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% reversible, forward only, backward only
model.rxns = {'rev'; 'fwd'; 'bwd'};
model.S = [1 1 1; -1 -1 -1];
model.lb = [-5; 0; -3];
model.ub = [5; 4; 0];

%% reversibility flags

out = fixIrr(model);
assert(isequal(out.rev, [1; 0; 0]));

%% backward reactions become forward reactions

out = fixIrr(model);
assert(isequal(out.S(:, 3), [-1; 1]));
% bounds: lb = 0 and ub = old -lb
assert(isequal(out.lb, [-5; 0; 0]) && isequal(out.ub, [5; 4; 3]));
% the other reactions are unchanged
assert(isequal(out.S(:, 1:2), model.S(:, 1:2)));

%% a reaction with both bounds at zero is neither reversible nor flipped

closed = model;
closed.lb(2) = 0;
closed.ub(2) = 0;
out = fixIrr(closed);
assert(out.rev(2) == 0 && out.lb(2) == 0 && out.ub(2) == 0);

% change the directory
cd(currentDir)
