% The COBRAToolbox: testOrderModelFieldsBorg.m
%
% Purpose:
%     - orderModelFieldsBorg reorders the fields of a model structure into the standard
%     modelBorgifier order, placing unknown fields after the known ones.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/orderModelFieldsBorg.m
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
fileDir = fileparts(which('testOrderModelFieldsBorg'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.ub = 1;
model.S = 2;
model.rxns = 3;
model.mets = 4;

%% known fields in a shuffled order

ordered = orderModelFieldsBorg(model);
% the standard order starts with rxns, mets, S, lb, ub, ...
assert(isequal(fieldnames(ordered), {'rxns'; 'mets'; 'S'; 'ub'}));

%% unknown fields come last in their original order

model.zzz = 5;
model.aaa = 6;
ordered = orderModelFieldsBorg(model);
assert(isequal(fieldnames(ordered), {'rxns'; 'mets'; 'S'; 'ub'; 'zzz'; 'aaa'}));
% the values travel with their fields
assert(ordered.rxns == 3 && ordered.zzz == 5 && ordered.aaa == 6);

% change the directory
cd(currentDir)
