% The COBRAToolbox: testSetConstraintsIrrevModel.m
%
% Purpose:
%     - setConstraintsIrrevModel translates flux constraints given for the reactions of a reversible
%     model into constraints on the reactions of the irreversible version of the model, using the
%     mapping between the two.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/modelGeneration/setConstraintsIrrevModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Reactions with names of one or two characters get the wrong sign
%       SEVERITY: wrong-result
%       TRIGGER: an irreversible reaction whose identifier has at most two characters (for example
%         r1) with a constraint
%       OBSERVED: the test that decides whether the reaction was reversed in the irreversible model
%         is only applied for names longer than two characters, so the value of the constraint is
%         negated although the reaction was not reversed
%       EXPECTED: the value is kept for a reaction that is not reversed, whatever the length of its
%         name
%       LINES: 22
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSetConstraintsIrrevModel'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% reversible model: r1 irreversible, r2 reversible; irreversible model: r1, r2 and r2_r
model.rxns = {'rxn1'; 'rxn2'};
modelIrrev.rxns = {'rxn1'; 'rxn2'; 'rxn2_r'};
rev2irrev = {1; [2 3]};

%% a constraint on an irreversible reaction (names longer than two characters)

constrOpt = struct('rxnList', {{'rxn1'}}, 'values', 5, 'sense', 'E');
out = setConstraintsIrrevModel(constrOpt, model, modelIrrev, rev2irrev);
assert(isequal(out.rxnList, {'rxn1'}) && isequal(out.rxnInd, 1) && isequal(out.values, 5) && isequal(out.sense, 'E'));

%% a single constraint on a reversible reaction: positive and negative values, each sense

% flux = 2: forward = 2, backward = 0
out = setConstraintsIrrevModel(struct('rxnList', {{'rxn2'}}, 'values', 2, 'sense', 'E'), model, modelIrrev, rev2irrev);
assert(isequal(out.rxnInd, [2; 3]) && isequal(out.values, [2; 0]) && isequal(out.sense, ['E'; 'E']));
% flux >= 2: forward >= 2, backward = 0
out = setConstraintsIrrevModel(struct('rxnList', {{'rxn2'}}, 'values', 2, 'sense', 'G'), model, modelIrrev, rev2irrev);
assert(isequal(out.values, [2; 0]) && isequal(out.sense, ['G'; 'E']));
% flux <= 2: forward <= 2, backward >= 0
out = setConstraintsIrrevModel(struct('rxnList', {{'rxn2'}}, 'values', 2, 'sense', 'L'), model, modelIrrev, rev2irrev);
assert(isequal(out.values, [2; 0]) && isequal(out.sense, ['L'; 'G']));
% flux = -3: forward = 0, backward = 3
out = setConstraintsIrrevModel(struct('rxnList', {{'rxn2'}}, 'values', -3, 'sense', 'E'), model, modelIrrev, rev2irrev);
assert(isequal(out.values, [0; 3]) && isequal(out.sense, ['E'; 'E']));
% flux >= -3: forward >= 0 ... backward <= 3
out = setConstraintsIrrevModel(struct('rxnList', {{'rxn2'}}, 'values', -3, 'sense', 'G'), model, modelIrrev, rev2irrev);
assert(isequal(out.values, [0; 3]) && isequal(out.sense, ['G'; 'L']));
% flux <= -3: forward = 0, backward >= 3
out = setConstraintsIrrevModel(struct('rxnList', {{'rxn2'}}, 'values', -3, 'sense', 'L'), model, modelIrrev, rev2irrev);
assert(isequal(out.values, [0; 3]) && isequal(out.sense, ['E'; 'G']));

%% two equal values behave like one equality constraint

out = setConstraintsIrrevModel(struct('rxnList', {{'rxn2'; 'rxn2'}}, 'values', [4; 4], 'sense', ['G'; 'L']), model, modelIrrev, rev2irrev);
assert(isequal(out.values, [4; 0]) && isequal(out.sense, ['E'; 'E']));

%% a range on a reversible reaction

% both bounds positive
out = setConstraintsIrrevModel(struct('rxnList', {{'rxn2'; 'rxn2'}}, 'values', [1; 4], 'sense', ['G'; 'L']), model, modelIrrev, rev2irrev);
assert(isequal(out.rxnInd, [2; 2; 3]) && isequal(out.values, [1; 4; 0]) && isequal(out.sense, ['G'; 'L'; 'E']));
% both bounds negative
out = setConstraintsIrrevModel(struct('rxnList', {{'rxn2'; 'rxn2'}}, 'values', [-4; -1], 'sense', ['G'; 'L']), model, modelIrrev, rev2irrev);
assert(isequal(out.rxnInd, [2; 3; 3]) && isequal(out.values, [0; 1; 4]) && isequal(out.sense, ['E'; 'G'; 'L']));
% lower negative, upper positive
out = setConstraintsIrrevModel(struct('rxnList', {{'rxn2'; 'rxn2'}}, 'values', [-2; 5], 'sense', ['G'; 'L']), model, modelIrrev, rev2irrev);
assert(isequal(out.rxnInd, [2; 3]) && isequal(out.values, [5; 2]) && isequal(out.sense, ['L'; 'L']));

%% a reaction that was reversed in the irreversible model

model2.rxns = {'rxnb'};
modelIrrev2.rxns = {'rxnb_r'};
out = setConstraintsIrrevModel(struct('rxnList', {{'rxnb'}}, 'values', 3, 'sense', 'G'), model2, modelIrrev2, {1});
% the value changes sign for a reversed reaction
assert(isequal(out.values, -3) && isequal(out.sense, 'G'));

%% reactions that are not in the model are ignored

out = setConstraintsIrrevModel(struct('rxnList', {{'unknown'; 'rxn1'}}, 'values', [1; 2], 'sense', ['E'; 'E']), model, modelIrrev, rev2irrev);
assert(isequal(out.rxnList, {'rxn1'}) && isequal(out.values, 2));

% change the directory
cd(currentDir)
