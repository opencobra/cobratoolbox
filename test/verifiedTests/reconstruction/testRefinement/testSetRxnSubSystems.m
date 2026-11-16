% The COBRAToolbox: testSetRxnSubSystems.m
%
% Purpose:
%     - setRxnSubSystems replaces the subSystems of the reactions given by ID (char or cell),
%       index or logical vector with one cell array of subSystem names; with more than one
%       name the empty name is dropped (setdiff, so the names come back sorted); a missing
%       subSystems field is created with {''} for every reaction; IDs not in the model raise a
%       warning. Expected values are worked out by hand from a four-reaction createModel model.
%
% Function under test:
%     src/reconstruction/refinement/setRxnSubSystems.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation without a solver; a hand-built createModel model with four
%     reactions reaches every branch.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSetRxnSubSystems'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a small model, built once: R1 A -> B, R2 B <=> C, EX_A, EX_C
model = createModel({'R1', 'R2', 'EX_A', 'EX_C'}, {'R1', 'R2', 'EX_A', 'EX_C'}, ...
    {'A -> B', 'B <=> C', 'A <=> ', 'C -> '});
model.subSystems = {{'Old1'}; {'Old2', 'Old3'}; {''}; {'Old4'}};
nRxns = numel(model.rxns);

%% a reaction ID given as char: its subSystems become exactly {'TCA'}, all else unchanged
modelOut = setRxnSubSystems(model, 'R2', 'TCA');
assert(isequal(modelOut.subSystems, {{'Old1'}; {'TCA'}; {''}; {'Old4'}}));
% structural consistency: one entry per reaction, S and rxns untouched
assert(numel(modelOut.subSystems) == nRxns);
assert(isequal(modelOut.S, model.S) && isequal(modelOut.rxns, model.rxns));

%% several IDs (cell) and several names: the empty name is removed and setdiff sorts
modelOut = setRxnSubSystems(model, {'R1'; 'EX_C'}, {'Glycolysis', '', 'Gluconeogenesis'});
assert(isequal(modelOut.subSystems{1}, {'Gluconeogenesis', 'Glycolysis'}));
assert(isequal(modelOut.subSystems{4}, {'Gluconeogenesis', 'Glycolysis'}));
assert(isequal(modelOut.subSystems([2, 3]), model.subSystems([2, 3])));

%% a single empty name is kept (setdiff only applies to more than one name)
modelOut = setRxnSubSystems(model, 1, '');
assert(isequal(modelOut.subSystems{1}, {''}));

%% positions as a double vector and as a logical vector give the same result
modelIdx = setRxnSubSystems(model, [3, 4], {'Exchange'});
modelBool = setRxnSubSystems(model, logical([0; 0; 1; 1]), {'Exchange'});
assert(isequal(modelIdx.subSystems, modelBool.subSystems));
assert(isequal(modelIdx.subSystems, {{'Old1'}; {'Old2', 'Old3'}; {'Exchange'}; {'Exchange'}}));

%% a model without subSystems: the field is created with {''} for the other reactions
modelNoSub = rmfield(model, 'subSystems');
modelOut = setRxnSubSystems(modelNoSub, 'EX_A', 'Transport');
assert(isequal(modelOut.subSystems, {{''}; {''}; {'Transport'}; {''}}));

%% IDs that are not in the model raise a warning; the IDs that exist are still set
% (the warning is shown, not suppressed; lastwarn reads it back)
lastwarn('');
modelOut = setRxnSubSystems(model, {'R1', 'notThere'}, 'X');
assert(strcmp(lastwarn, 'There were reaction IDs not present in the model'));
assert(isequal(modelOut.subSystems{1}, {'X'}));
lastwarn('');
modelOut = setRxnSubSystems(model, 'notThere', 'X');
assert(strcmp(lastwarn, 'There were reaction IDs not present in the model'));
assert(isequal(modelOut.subSystems, model.subSystems));

% change the directory
cd(currentDir)
