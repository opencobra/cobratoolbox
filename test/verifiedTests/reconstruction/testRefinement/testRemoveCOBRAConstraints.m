% The COBRAToolbox: testRemoveCOBRAConstraints.m
%
% Purpose:
%     - removeCOBRAConstraints(model, constraintsToRemove) removes rows of the additional
%       constraints (C, d, dsense, ctrs, ctrNames) given by identifier (text or cell array),
%       position or logical vector, ignores unknown identifiers, removes the constraint fields
%       when no constraint is left, and returns a model without C unchanged. Expected values are
%       the rows of the hand-built model that remain.
%
% Function under test:
%     src/reconstruction/refinement/removeCOBRAConstraints.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation on a hand-built 2 x 3 model with three constraints; no solver
%     (the ledger listed the row as Tier 3; the function calls no solver).
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRemoveCOBRAConstraints'));
cd(fileDir);

prepareTest();

% hand-built model: A -> B -> C as R1, R2 and the exchange R3, no constraints yet
model.S = sparse([-1 0 0; 1 -1 0; 0 1 -1]);
model.mets = {'A'; 'B'; 'C'};
model.rxns = {'R1'; 'R2'; 'R3'};
model.lb = zeros(3, 1);
model.ub = 10 * ones(3, 1);
model.c = [0; 0; 1];
model.b = zeros(3, 1);
model.csense = repmat('E', 3, 1);
model.osenseStr = 'max';
model.genes = cell(0, 1);
model.rules = repmat({''}, 3, 1);

% three constraints with distinct rows, right-hand sides, senses and names
modelWithConstraints = model;
modelWithConstraints.C = sparse([1 1 0; 0 1 1; 1 0 1]);
modelWithConstraints.d = [5; 6; 7];
modelWithConstraints.dsense = ['L'; 'G'; 'E'];
modelWithConstraints.ctrs = {'c1'; 'c2'; 'c3'};
modelWithConstraints.ctrNames = {'first'; 'second'; 'third'};

%% a model without C is returned unchanged
assert(isequal(removeCOBRAConstraints(model, 'c1'), model));

%% one identifier given as text: the second row of every constraint field is removed
modelOut = removeCOBRAConstraints(modelWithConstraints, 'c2');
assert(isequal(modelOut.ctrs, {'c1'; 'c3'}));
assert(isequal(full(modelOut.C), [1 1 0; 1 0 1]));
assert(isequal(modelOut.d, [5; 7]));
assert(isequal(modelOut.dsense, ['L'; 'E']));
assert(isequal(modelOut.ctrNames, {'first'; 'third'}));
% the other fields are untouched
assert(isequal(rmfield(modelOut, {'C', 'd', 'dsense', 'ctrs', 'ctrNames'}), model));

%% a cell array of identifiers: unknown identifiers are ignored
modelOut = removeCOBRAConstraints(modelWithConstraints, {'c3'; 'unknown'});
assert(isequal(modelOut.ctrs, {'c1'; 'c2'}));
assert(isequal(full(modelOut.C), [1 1 0; 0 1 1]));
assert(isequal(modelOut.d, [5; 6]));
assert(isequal(modelOut.dsense, ['L'; 'G']));
% only unknown identifiers: nothing is removed
assert(isequal(removeCOBRAConstraints(modelWithConstraints, {'unknown'}), modelWithConstraints));

%% constraint positions
modelOut = removeCOBRAConstraints(modelWithConstraints, 1);
assert(isequal(modelOut.ctrs, {'c2'; 'c3'}));
assert(isequal(full(modelOut.C), [0 1 1; 1 0 1]));
assert(isequal(modelOut.ctrNames, {'second'; 'third'}));

%% a logical vector of positions
modelOut = removeCOBRAConstraints(modelWithConstraints, [true; false; true]);
assert(isequal(modelOut.ctrs, {'c2'}));
assert(isequal(full(modelOut.C), [0 1 1]));
assert(isequal(modelOut.d, 6));
assert(isequal(modelOut.dsense, 'G'));

%% every constraint removed: the constraint fields are removed and the model is the original
modelOut = removeCOBRAConstraints(modelWithConstraints, {'c1'; 'c2'; 'c3'});
assert(~any(isfield(modelOut, {'C', 'D', 'd', 'dsense', 'ctrs', 'ctrNames'})));
assert(isequal(modelOut, model));

% change the directory
cd(currentDir)
