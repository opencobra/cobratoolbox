% The COBRAToolbox: testRemoveSubSystemsFromRxns.m
%
% Purpose:
%     - removeSubSystemsFromRxns removes the given subSystem names from the subSystems of
%       the reactions given by ID (char or cell), index or logical vector; what remains is
%       setdiff(old, removed) (sorted), or {''} when nothing remains; an empty subSystems
%       argument changes nothing; a missing subSystems field is created with {''} for every
%       reaction; IDs not in the model raise a warning. Expected values are worked out by hand
%       from a four-reaction createModel model.
%
% Function under test:
%     src/reconstruction/refinement/removeSubSystemsFromRxns.m
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
%     - Help text of removeSubSystemsFromRxns corrected to match the code (feature 20261120-151023-doc-matches-code), 2026-11-20.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRemoveSubSystemsFromRxns'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a small model, built once: R1 A -> B, R2 B <=> C, EX_A, EX_C
model = createModel({'R1', 'R2', 'EX_A', 'EX_C'}, {'R1', 'R2', 'EX_A', 'EX_C'}, ...
    {'A -> B', 'B <=> C', 'A <=> ', 'C -> '});
model.subSystems = {{'TCA', 'Other'}; {'TCA'}; {'Exchange'}; {'Exchange', 'TCA'}};
nRxns = numel(model.rxns);

%% one name removed from one reaction given as char: the other names stay
modelOut = removeSubSystemsFromRxns(model, 'R1', 'TCA');
assert(isequal(modelOut.subSystems{1}, {'Other'}));
assert(isequal(modelOut.subSystems(2:4), model.subSystems(2:4)));
% structural consistency: one entry per reaction, S and rxns untouched
assert(numel(modelOut.subSystems) == nRxns);
assert(isequal(modelOut.S, model.S) && isequal(modelOut.rxns, model.rxns));

%% removing the only name leaves {''}; several reactions given as a cell of IDs
modelOut = removeSubSystemsFromRxns(model, {'R2'; 'EX_C'}, {'TCA'});
assert(isequal(modelOut.subSystems{2}, {''}));
assert(isequal(modelOut.subSystems{4}, {'Exchange'}));

%% several names removed at once; a name a reaction does not have is ignored
modelOut = removeSubSystemsFromRxns(model, 1, {'TCA', 'Other', 'Absent'});
assert(isequal(modelOut.subSystems{1}, {''}));

%% positions as a double vector and as a logical vector give the same result
modelIdx = removeSubSystemsFromRxns(model, [3, 4], 'Exchange');
modelBool = removeSubSystemsFromRxns(model, logical([0; 0; 1; 1]), 'Exchange');
assert(isequal(modelIdx.subSystems, modelBool.subSystems));
assert(isequal(modelIdx.subSystems, {{'TCA', 'Other'}; {'TCA'}; {''}; {'TCA'}}));

%% an empty subSystems argument returns the model unchanged
modelOut = removeSubSystemsFromRxns(model, 'R1', {});
assert(isequal(modelOut, model));

%% a model without subSystems: the field is created with {''} for every reaction
modelNoSub = rmfield(model, 'subSystems');
modelOut = removeSubSystemsFromRxns(modelNoSub, 'R1', 'TCA');
assert(isequal(modelOut.subSystems, {{''}; {''}; {''}; {''}}));

%% IDs that are not in the model raise a warning; the IDs that exist are still changed
% (the warning is shown, not suppressed; lastwarn reads it back)
lastwarn('');
modelOut = removeSubSystemsFromRxns(model, {'R2', 'notThere'}, 'TCA');
assert(strcmp(lastwarn, 'There were reaction IDs not present in the model'));
assert(isequal(modelOut.subSystems{2}, {''}));
lastwarn('');
modelOut = removeSubSystemsFromRxns(model, 'notThere', 'TCA');
assert(strcmp(lastwarn, 'There were reaction IDs not present in the model'));
assert(isequal(modelOut.subSystems, model.subSystems));

% change the directory
cd(currentDir)
