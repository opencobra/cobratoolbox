% The COBRAToolbox: testAddSubSystemsToReactions.m
%
% Purpose:
%     - addSubSystemsToReactions adds one or more subsystems to the reactions given by
%       identifier(s), positions or a Boolean vector, keeping the subsystems a reaction already
%       has, dropping empty names and never duplicating a subsystem; a model without
%       subSystems gets the field (one {''} per reaction) first; identifiers not in the model
%       raise a warning. The expected subsystem sets follow by hand from the documentation
%       (old non-empty values are retained, all supplied subsystems are added to all identified
%       reactions, the empty string is filtered).
%
% Function under test:
%     src/reconstruction/refinement/addSubSystemsToReactions.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation of a four-reaction model built with createModel; no solver.
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
fileDir = fileparts(which('testAddSubSystemsToReactions'));
cd(fileDir);

% declare the requirements of this test. This test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a four-reaction model; the subSystems field is removed to start from a model without it
model = createModel({'r1'; 'r2'; 'r3'; 'EX_a'}, {'r1'; 'r2'; 'r3'; 'EX_a'}, ...
    {'A[c] -> B[c]'; 'B[c] -> C[c]'; 'C[c] -> A[c]'; 'A[c] <=> '});
if isfield(model, 'subSystems')
    model = rmfield(model, 'subSystems');
end
nRxns = numel(model.rxns);

% subsystem sets are compared as sets of names (the function returns the union, whose order
% and orientation are those of MATLAB's union); all values are text, so no tolerance applies
sameSet = @(a, b) isempty(setxor(a, b)) && numel(a) == numel(unique(b));

%% a model without subSystems gets the field; one identifier, one subsystem name

model1 = addSubSystemsToReactions(model, 'r1', 'TCA');
assert(isequal(size(model1.subSystems), [nRxns, 1]));
assert(sameSet(model1.subSystems{1}, {'TCA'}));
% the other reactions hold the empty subsystem {''} created for the new field
assert(all(cellfun(@(x) isequal(x, {''}), model1.subSystems(2:end))));

% the stoichiometry and the identifiers are unchanged
assert(isequal(model1.S, model.S) && isequal(model1.rxns, model.rxns) && isequal(model1.mets, model.mets));

%% several identifiers and several subsystems: old values are retained, no duplicates

% r1 keeps TCA and gets Glycolysis and Gluconeogenesis; adding TCA again does not duplicate it
model2 = addSubSystemsToReactions(model1, {'r1'; 'r2'}, {'Glycolysis', 'TCA', 'Gluconeogenesis'});
assert(sameSet(model2.subSystems{1}, {'Gluconeogenesis', 'Glycolysis', 'TCA'}));
assert(sameSet(model2.subSystems{2}, {'Gluconeogenesis', 'Glycolysis', 'TCA'}));
assert(isequal(model2.subSystems(3:4), model1.subSystems(3:4)));

%% positions and a Boolean vector select reactions as well

model3 = addSubSystemsToReactions(model, [3, 4], 'Transport');
assert(sameSet(model3.subSystems{3}, {'Transport'}) && sameSet(model3.subSystems{4}, {'Transport'}));
assert(isequal(model3.subSystems{1}, {''}) && isequal(model3.subSystems{2}, {''}));

model4 = addSubSystemsToReactions(model3, logical([0; 1; 1; 0]), {'Exchange'});
assert(sameSet(model4.subSystems{2}, {'Exchange'}));
assert(sameSet(model4.subSystems{3}, {'Exchange', 'Transport'}));
assert(sameSet(model4.subSystems{4}, {'Transport'}));

%% a model whose subsystems are character arrays keeps the name and gets the new one

% the empty character array of r2 is dropped like the empty string
modelChar = model;
modelChar.subSystems = {'Glycolysis'; ''; 'TCA'; 'Exchange'};
model5 = addSubSystemsToReactions(modelChar, {'r1'; 'r2'}, 'Pyruvate');
assert(sameSet(model5.subSystems{1}, {'Glycolysis', 'Pyruvate'}));
assert(sameSet(model5.subSystems{2}, {'Pyruvate'}));
assert(isequal(model5.subSystems(3:4), modelChar.subSystems(3:4)));

%% the empty name is filtered; only empty names leave the model as it is

model6 = addSubSystemsToReactions(model1, 'r2', {'', 'Shunt'});
assert(sameSet(model6.subSystems{2}, {'Shunt'}));

% only the empty name: nothing is added (a model without subSystems still gets the field)
model7 = addSubSystemsToReactions(model1, 'r2', '');
assert(isequal(model7, model1));
model8 = addSubSystemsToReactions(model, 'r2', '');
assert(isequal(size(model8.subSystems), [nRxns, 1]));
assert(all(cellfun(@(x) isequal(x, {''}), model8.subSystems)));

%% identifiers not in the model raise a warning; the present ones are still annotated

% a cell array with one unknown identifier
lastwarn('');
model9 = addSubSystemsToReactions(model, {'r1'; 'unknown'}, 'TCA');
[warnMsg] = lastwarn();
assert(strcmp(warnMsg, 'There were reaction IDs not present in the model'));
assert(sameSet(model9.subSystems{1}, {'TCA'}));
assert(all(cellfun(@(x) isequal(x, {''}), model9.subSystems(2:end))));

% a single unknown identifier as a character array
lastwarn('');
model10 = addSubSystemsToReactions(model, 'unknown', 'TCA');
[warnMsg] = lastwarn();
assert(strcmp(warnMsg, 'There were reaction IDs not present in the model'));
assert(all(cellfun(@(x) isequal(x, {''}), model10.subSystems)));

% change the directory
cd(currentDir)
