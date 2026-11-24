% The COBRAToolbox: testAddRatioReaction.m
%
% Purpose:
%     - addRatioReaction(model, listOfRxns, ratioCoeff) adds the equality constraint
%       -ratioCoeff(1) * v(listOfRxns{1}) + ratioCoeff(2) * v(listOfRxns{2}) = 0, i.e.
%       ratioCoeff(1) * v1 = ratioCoeff(2) * v2, named 'Ratio_<rxn1>_<rxn2>', to the constraint
%       fields C, d, dsense and ctrs (created when absent, appended otherwise). The test checks
%       the constraint row, the other constraint fields, that S and the bounds are unchanged,
%       and the errors for a repeated pair and an unknown reaction.
%     - Expected values are derived by hand from the help text: its EXAMPLE states that
%       [1 2] encodes 1 v1 = 2 v2, i.e. the row [-1 2] with right hand side 0 and sense 'E'.
%
% Function under test:
%     src/analysis/coupling/addRatioReaction.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a small hand-built model (createModel); no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddRatioReaction'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a linear pathway of three reactions without constraint fields
model = createModel({'R1', 'R2', 'R3'}, {'R1', 'R2', 'R3'}, {'A -> B', 'B -> C', 'C -> '}, ...
    'printLevel', 0);
assert(~any(isfield(model, {'C', 'd', 'dsense', 'ctrs'})));

%% a ratio on a model without constraints creates the constraint fields

% 1 v(R1) = 2 v(R3) is the row -1 * v(R1) + 2 * v(R3) = 0 (exact integers, no tolerance)
modelRatio = addRatioReaction(model, {'R1', 'R3'}, [1 2]);
assert(isequal(full(modelRatio.C), [-1, 0, 2]));
assert(isequal(modelRatio.d, 0));
assert(isequal(modelRatio.dsense, 'E'));
assert(isequal(modelRatio.ctrs, {'Ratio_R1_R3'}));
% a flux vector with v(R1) = 2 v(R3) satisfies the row, one that breaks the ratio does not
assert(modelRatio.C * [2; 0; 1] == 0);
assert(modelRatio.C * [1; 0; 1] ~= 0);
% the stoichiometry and the bounds are not touched
assert(isequal(modelRatio.S, model.S) && isequal(modelRatio.rxns, model.rxns));
assert(isequal(modelRatio.lb, model.lb) && isequal(modelRatio.ub, model.ub));

%% a second ratio is appended below the existing constraint

% the order of listOfRxns sets which reaction gets the negative coefficient: 3 v(R2) = 1 v(R1)
modelTwo = addRatioReaction(modelRatio, {'R2', 'R1'}, [3 1]);
assert(isequal(full(modelTwo.C), [-1, 0, 2; 1, -3, 0]));
assert(isequal(modelTwo.d, [0; 0]));
assert(isequal(modelTwo.dsense, ['E'; 'E']));
assert(isequal(modelTwo.ctrs, {'Ratio_R1_R3'; 'Ratio_R2_R1'}));
assert(size(modelTwo.C, 2) == numel(modelTwo.rxns));

%% the same pair twice and an unknown reaction are errors

% the constraint id Ratio_R1_R3 exists already
assert(verifyCobraFunctionError('addRatioReaction', 'inputs', {modelRatio, {'R1', 'R3'}, [1 2]}, ...
    'testMessage', sprintf('Constraints with the following IDs already exist.\nRatio_R1_R3\n')));
assert(verifyCobraFunctionError('addRatioReaction', 'inputs', {model, {'R1', 'R9'}, [1 2]}, ...
    'testMessage', sprintf('The following ids were not found in the model:\nR9\nNo Constraint was added')));

% change the directory
cd(currentDir)
