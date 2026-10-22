% The COBRAToolbox: testCheckDuplicateRxn.m
%
% Purpose:
%     - checkDuplicateRxn finds reactions that duplicate another reaction, by stoichiometry ('S'),
%     by stoichiometry up to the direction of the reaction ('FR') or by reaction abbreviation, and
%     optionally removes them. It returns the model, the indices of the duplicates and the indices
%     of the reactions that were kept.
%       Characterization test that PINS the current behaviour (feature
%       20261021-112509-recon-ci-scalability, Constitution Principle III characterization mode);
%       it must not change the function under test. It is the reference that the memory and
%       runtime enhancement of the function is checked against.
%
% Function under test:
%     src/reconstruction/modelGeneration/checkDuplicateRxn.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 64 to 72, the 'rxnAbbr' method, and line 161, the warning for a group of more than
%     two reactions in the 'FR' method: see the known defects below. They are executed only by the
%     calls that the defects describe, which this test does not make.
%
% Known defects documented (NOT tested, NOT fixed here):
%     DEFECT: the 'rxnAbbr' method returns the unique reactions as the duplicates
%       SEVERITY: wrong-result
%       TRIGGER: checkDuplicateRxn(model, 'rxnAbbr') on any model
%       OBSERVED: removedRxnInd holds the first occurrence of every reaction abbreviation (all
%         reactions when none repeats), so the function reports no duplicates only for an empty
%         model, and removal by name deletes every reaction that has a repeated abbreviation
%       EXPECTED: removedRxnInd holds the repeated occurrences only
%       LINES: 64-72
%     DEFECT: the 'FR' method removes the last reaction of a group after testing the first two
%       SEVERITY: wrong-result
%       TRIGGER: three or more reactions with the same stoichiometry up to scale and direction
%         (for example A->B, B->A and 2A->2B)
%       OBSERVED: the direction test compares the first two members of the group only, and the
%         last member (which may differ by a scale factor) is reported as the duplicate
%       EXPECTED: every reported duplicate is a duplicate of the kept reaction
%       LINES: 156-162
%
% Authors:
%     - Generated for feature 20261021-112509-recon-ci-scalability, 2026-10-22.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCheckDuplicateRxn'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% five metabolites and seven reactions
%   r1  A -> B
%   r2  B -> C
%   r3  A -> B            exact duplicate of r1
%   r4  C -> D
%   r5  B -> A            r1 in the opposite direction
%   r6  D -> E
%   r7  C -> D            exact duplicate of r4, with different bounds
S = [-1  0 -1  0  1  0  0; ...
      1 -1  1  0 -1  0  0; ...
      0  1  0 -1  0  0 -1; ...
      0  0  0  1  0 -1  1; ...
      0  0  0  0  0  1  0];
model.S = sparse(S);
model.mets = {'A'; 'B'; 'C'; 'D'; 'E'};
model.rxns = {'r1'; 'r2'; 'r3'; 'r4'; 'r5'; 'r6'; 'r7'};
model.rxnNames = {'one'; 'two'; 'three'; 'four'; 'five'; 'six'; 'seven'};
model.lb = [0; 0; 0; 0; -10; 0; 0];
model.ub = [10; 10; 10; 10; 10; 10; 5];
nRxn = numel(model.rxns);

%% default arguments: method 'S', duplicates removed

% only the exact duplicates r3 (of r1) and r7 (of r4) are found; the opposite direction r5 is not
[modelOut, removedRxnInd, keptRxnInd] = checkDuplicateRxn(model);
assert(isequal(removedRxnInd, [3; 7]));
assert(isequal(keptRxnInd, [1; 4]));
assert(isequal(modelOut.rxns, {'r1'; 'r2'; 'r4'; 'r5'; 'r6'}));
% the removal keeps the matrix, bounds and names consistent
assert(isequal(size(modelOut.S), [5 5]) && issparse(modelOut.S));
assert(isequal(modelOut.S, model.S(:, [1 2 4 5 6])));
assert(isequal(modelOut.lb, model.lb([1 2 4 5 6])) && isequal(modelOut.ub, model.ub([1 2 4 5 6])));
assert(isequal(modelOut.rxnNames, model.rxnNames([1 2 4 5 6])));
% the input model is not modified
assert(numel(model.rxns) == nRxn);

%% method 'S' by name and by number, and the removal flag

for method = {'S', 2}
    % removeFlag = 0 reports the duplicates and returns the model unchanged
    [modelOut, removedRxnInd, keptRxnInd] = checkDuplicateRxn(model, method{1}, 0);
    assert(isequal(removedRxnInd, [3; 7]) && isequal(keptRxnInd, [1; 4]));
    assert(isequal(modelOut, model));
    % removeFlag = 1 removes them
    [modelOut, removedRxnInd] = checkDuplicateRxn(model, method{1}, 1);
    assert(isequal(removedRxnInd, [3; 7]));
    assert(isequal(modelOut.rxns, {'r1'; 'r2'; 'r4'; 'r5'; 'r6'}));
end

%% method 'S' with the bounds taken into account

% r7 has other bounds than r4, so only r3 is a duplicate when the bounds are compared
[modelOut, removedRxnInd, keptRxnInd] = checkDuplicateRxn(model, 'S', 1, 0, 1);
assert(isequal(removedRxnInd, 3) && isequal(keptRxnInd, 1));
assert(isequal(modelOut.rxns, {'r1'; 'r2'; 'r4'; 'r5'; 'r6'; 'r7'}));

%% method 'FR': duplicates up to the direction of the reaction

% r5 is r1 reversed and is found with r3, but r1 and r3 are compared first: the group is r1, r3, r5
% and holds three members, which is the documented defect, so this model is not used for 'FR'
modelFR = model;
keep = [1 2 4 5 6 7];                      % without r3: groups {r1, r5} and {r4, r7}
modelFR.S = model.S(:, keep);
modelFR.rxns = model.rxns(keep);
modelFR.rxnNames = model.rxnNames(keep);
modelFR.lb = model.lb(keep);
modelFR.ub = model.ub(keep);
[modelOut, removedRxnInd, keptRxnInd] = checkDuplicateRxn(modelFR, 'FR', 1);
% r5 (index 4 here) duplicates r1 in the opposite direction; r7 (index 6) duplicates r4
assert(isequal(sort(removedRxnInd), [4; 6]));
assert(isequal(sort(keptRxnInd), [1; 3]));
assert(isequal(modelOut.rxns, {'r1'; 'r2'; 'r4'; 'r6'}));
% removeFlag = 0 leaves the model as it is
[modelOut, removedRxnInd] = checkDuplicateRxn(modelFR, 'FR', 0);
assert(isequal(sort(removedRxnInd), [4; 6]) && isequal(modelOut, modelFR));
% with the bounds, r7 differs from r4 in its upper bound and r5 from r1 in its lower bound
[modelOut, removedRxnInd] = checkDuplicateRxn(modelFR, 'FR', 1, 0, 1);
assert(isempty(removedRxnInd) && isequal(modelOut, modelFR));

%% method 'FR': equal up to a scale factor is not a duplicate

% x and y have the same pattern of metabolites, but y is twice x: they share a group in 'FR',
% and the direction test (equal or opposite) rejects them
modelScale.S = sparse([-1 -2 0; 1 2 -1; 0 0 1]);
modelScale.mets = {'A'; 'B'; 'C'};
modelScale.rxns = {'x'; 'y'; 'z'};
modelScale.lb = [0; 0; 0];
modelScale.ub = [10; 10; 10];
[modelOut, removedRxnInd, keptRxnInd] = checkDuplicateRxn(modelScale, 'FR', 1);
assert(isempty(removedRxnInd) && isempty(keptRxnInd));
assert(isequal(modelOut, modelScale));

%% a reaction without any coefficient is handled by 'FR'

% the empty column has a column sum of zero, which is replaced by one to avoid a division by zero
modelEmpty = modelScale;
modelEmpty.S = sparse([-1 0 0; 1 0 -1; 0 0 1]);
[modelOut, removedRxnInd] = checkDuplicateRxn(modelEmpty, 'FR', 1);
assert(isempty(removedRxnInd) && isequal(modelOut, modelEmpty));

%% no duplicates

for method = {'S', 'FR'}
    [modelOut, removedRxnInd, keptRxnInd] = checkDuplicateRxn(modelScale, method{1}, 1);
    assert(isempty(removedRxnInd) && isempty(keptRxnInd));
    assert(isequal(modelOut, modelScale));
end

%% a group of more than two exact duplicates in method 'S'

% r1, r3 and r8 are the same reaction: the first is kept, the last is reported and the group
% raises a warning that names the first reaction
modelTriple = model;
modelTriple.S = [model.S, model.S(:, 1)];
modelTriple.rxns = [model.rxns; 'r8'];
modelTriple.rxnNames = [model.rxnNames; {'eight'}];
modelTriple.lb = [model.lb; 0];
modelTriple.ub = [model.ub; 10];
lastwarn('');
[~, removedRxnInd, keptRxnInd] = checkDuplicateRxn(modelTriple, 'S', 0);
[warningMessage, ~] = lastwarn();
assert(strcmp(warningMessage, 'Reaction: r1 has more than one replicate'));
assert(isequal(removedRxnInd, [8; 7]) && isequal(keptRxnInd, [1; 4]));

%% input as a full matrix

modelFull = model;
modelFull.S = full(model.S);
[~, removedRxnInd] = checkDuplicateRxn(modelFull, 'S', 0);
assert(isequal(removedRxnInd, [3; 7]));
modelFRFull = modelFR;
modelFRFull.S = full(modelFR.S);
[~, removedRxnInd] = checkDuplicateRxn(modelFRFull, 'FR', 0);
assert(isequal(sort(removedRxnInd), [4; 6]));

%% printing

% printLevel 1 reports the method, the number of duplicates and each pair
text = evalc('checkDuplicateRxn(model, ''S'', 0, 1);');
assert(contains(text, 'Checking for reaction duplicates by stoichiometry ...'));
assert(contains(text, '2 duplicate reaction(s) (up to orientation)'));
assert(contains(text, 'Keep:') && contains(text, 'Duplicate:'));
assert(contains(text, 'r1') && contains(text, 'r3'));
text = evalc('checkDuplicateRxn(modelFR, ''FR'', 0, 1);');
assert(contains(text, 'Checking for reaction duplicates by stoichiometry (up to orientation) ...'));
assert(contains(text, 'Keep:') && contains(text, 'Duplicate:'));
% nothing is printed at printLevel 0, and a model without duplicates says so at printLevel 1
assert(isempty(evalc('checkDuplicateRxn(model, ''S'', 0, 0);')));
text = evalc('checkDuplicateRxn(modelScale, ''S'', 0, 1);');
assert(contains(text, 'no duplicates found.'));
text = evalc('checkDuplicateRxn(modelScale, ''FR'', 0, 1);');
assert(contains(text, 'no duplicates found.'));

% return to the original directory
cd(currentDir)
