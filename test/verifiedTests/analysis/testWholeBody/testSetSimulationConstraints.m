% The COBRAToolbox: testSetSimulationConstraints.m
%
% Purpose:
%     - setSimulationConstraints applies a fixed set of bound changes of the host-microbe whole-body
%     simulation (closed uptake of listed liver, colon and small intestine exchanges, limited bile
%     duct exchanges and brain glucose uptake).
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/hostMicrobeInteraction/setSimulationConstraints.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Warnings stay switched off after the call
%       SEVERITY: cosmetic
%       TRIGGER: any call
%       OBSERVED: the function runs warning off and does not restore the previous state, so every
%         later warning in the session is silenced
%       EXPECTED: the warning state is restored before returning
%       LINES: 2
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSetSimulationConstraints'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% keep the warning state of the session and restore it after the test
previousWarnings = warning;
cleanup = onCleanup(@() warning(previousWarnings));

% a model with a few of the reactions the function changes and one unrelated bile duct exchange
model.rxns = {'Liver_EX_4abut[bdL]_[bd]'; 'BileDuct_EX_Rtotal[bd]_[luSI]'; 'BileDuct_EX_other'; ...
              'Brain_EX_glc_D(e)_[csf]'; 'Colon_EX_o2[luC]_[luLI]'; 'unrelated'};
model.lb = -5 * ones(6, 1);
model.ub = 5 * ones(6, 1);
model.S = zeros(1, 6);
model.c = zeros(6, 1);
model.mets = {'m'};
model.b = 0;
model.csense = 'E';

%% bounds changed by the function

newModel = setSimulationConstraints(model);
% the upper bound of the liver exchange is closed and the colon oxygen lower bound is closed
assert(newModel.ub(1) == 0 && newModel.lb(5) == 0);
% every bile duct exchange is closed first, then the listed ones are reopened with their limits
assert(newModel.ub(2) == 15);
assert(newModel.ub(3) == 0);
% the brain glucose uptake limit
assert(newModel.ub(4) == -400);
% reactions not mentioned keep their bounds
assert(newModel.lb(6) == -5 && newModel.ub(6) == 5);
assert(newModel.lb(1) == -5 && newModel.lb(4) == -5);

% change the directory
cd(currentDir)
