% The COBRAToolbox: testMergeTrxns.m
%
% Purpose:
%     - mergeTrxns merges reactions of a merged (template) model that are identical but were kept
%     separate: the first reaction of each group takes over the membership, objective, bounds
%     (combined by the given ratio), names and annotations, and the others are removed.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/mergeTrxns.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Line 116 of mergeTrxns.m (a reaction name that is not a cell) is never reached: the names
%     are always a cell array.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A call with nothing to merge fails
%       SEVERITY: error
%       TRIGGER: an empty list of reactions to merge
%       OBSERVED: the variable modelfields is created inside the loop only, so the clean-up after
%         the loop errors (Unrecognized function or variable modelfields)
%       EXPECTED: the model returned unchanged
%       LINES: 51, 133
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMergeTrxns'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for the combined bounds: sums and means of a few numbers
tol = 1e-12;

% a template model of two models m1 and m2 with three reactions; reactions 1 and 2 are the same reaction
makeModel = @() struct('rxns', {{'R1'; 'R_dup'; 'R3'}}, 'S', sparse([1 -1 0; 0 0 1]), ...
    'Models', struct('m1', struct('rxns', [true; true; false]), 'm2', struct('rxns', [false; true; true])), ...
    'c', struct('m1', [0; 1; 0], 'm2', [0; 0; 1]), ...
    'lb', struct('m1', [-10; -20; 0], 'm2', [0; -30; -5]), ...
    'ub', struct('m1', [10; 50; 0], 'm2', [0; 30; 5]), ...
    'rxnNames', {{'a'; 'b'; 'c'}}, 'grRules', {{'g1'; 'g2'; 'g3'}}, 'subSystems', {{'s1'; 's2'; 's3'}});

%% merging reactions 1 and 2 with ratio 1

merged = mergeTrxns(makeModel(), {[1 2]}, 1);
% the reaction with more letters in its name is kept as the name
assert(isequal(merged.rxns, {'R_dup'; 'R3'}));
assert(isequal(full(merged.S), [1 0; 0 1]));          % the column of the removed reaction is deleted
% membership: m1 had both -> true; m2 had only the second -> true
assert(isequal(merged.Models.m1.rxns, [true; false]) && isequal(merged.Models.m2.rxns, [true; true]));
% objective coefficients are added
assert(isequal(merged.c.m1, [1; 0]) && isequal(merged.c.m2, [0; 1]));
% bounds: mean of the non-zero values (m1: lb -10 and -20; ub 10 and 50; m2: only the second reaction is non-zero)
assert(norm(merged.lb.m1 - [-15; 0]) < tol && norm(merged.ub.m1 - [30; 0]) < tol);
assert(norm(merged.lb.m2 - [-30; -5]) < tol && norm(merged.ub.m2 - [30; 5]) < tol);
% annotations are joined with |
assert(isequal(merged.rxnNames, {'a|b'; 'c'}) && isequal(merged.grRules, {'g1|g2'; 'g3'}));
assert(isequal(merged.subSystems, {'s1|s2'; 's3'}));

%% a ratio is applied to the second reaction's bounds

merged = mergeTrxns(makeModel(), {[1 2]}, 2);
% m1: lb [-10, -20/2] -> mean -10; ub [10, 50/2] -> mean 17.5
assert(abs(merged.lb.m1(1) + 10) < tol && abs(merged.ub.m1(1) - 17.5) < tol);

%% a negative ratio: the second reaction runs in the opposite direction

merged = mergeTrxns(makeModel(), {[1 2]}, -1);
% m1: lb [lb(1), ub(2)/-1] = [-10, -50] -> -30; ub [ub(1), lb(2)/-1] = [10, 20] -> 15
assert(abs(merged.lb.m1(1) + 30) < tol && abs(merged.ub.m1(1) - 15) < tol);

%% a ratio of 0 is reported and the bounds of the first reaction are kept

lastwarn('');
merged = mergeTrxns(makeModel(), {[1 2]}, 0);
assert(contains(lastwarn, 'mergeRxnRatio should not be 0'));
assert(merged.lb.m1(1) == -10 && merged.ub.m1(1) == 10);

%% bounds that are all zero stay 0 (positive and negative ratio)

zeroBounds = makeModel();
zeroBounds.lb = struct('m1', [0; 0; 0], 'm2', [0; 0; 0]);
zeroBounds.ub = struct('m1', [0; 0; 0], 'm2', [0; 0; 0]);
merged = mergeTrxns(zeroBounds, {[1 2]}, 1);
assert(merged.lb.m1(1) == 0 && merged.ub.m1(1) == 0 && merged.lb.m2(1) == 0 && merged.ub.m2(1) == 0);
merged = mergeTrxns(zeroBounds, {[1 2]}, -1);
assert(merged.lb.m1(1) == 0 && merged.ub.m1(1) == 0 && merged.lb.m2(1) == 0 && merged.ub.m2(1) == 0);

%% the field rxnMetNames is left alone

withMetNames = makeModel();
withMetNames.rxnMetNames = {'x'; 'y'; 'z'};
merged = mergeTrxns(withMetNames, {[1 2]}, 1);
assert(isequal(merged.rxnMetNames, {'x'; 'z'}));        % only the removed reaction's entry is dropped

%% another pair

merged = mergeTrxns(makeModel(), {[2 3]}, 1);
assert(isequal(merged.rxns, {'R1'; 'R_dup'}));

% change the directory
cd(currentDir)
