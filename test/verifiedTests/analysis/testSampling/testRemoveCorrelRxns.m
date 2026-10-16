% The COBRAToolbox: testRemoveCorrelRxns.m
%
% Purpose:
%     - removeCorrelRxns groups fully or almost fully correlated reactions using a correlation
%     matrix and returns the selection of one reaction per group, the groups, the group names joined
%     with slashes and the filtered correlation matrix.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/sampling/ACHR/removeCorrelRxns.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 69-70, the catch branch for an empty group (see the known defect below).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A reaction whose own correlation is below the cutoff gets an empty group and no name
%       SEVERITY: wrong-result
%       TRIGGER: a correlation matrix whose diagonal entry for a reaction is below the cutoff (for
%         example 0.5) and that is not selected with any other reaction
%       OBSERVED: the group of the reaction is empty, the function prints the empty group to the
%         command window and its entry in the name list is an empty array instead of a reaction name
%       EXPECTED: the reaction is listed as its own group with its identifier as name
%       LINES: 67-70
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRemoveCorrelRxns'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.rxns = {'a'; 'b'; 'c'; 'd'};
% a and b are fully correlated, c is independent and d has no variation (NaN)
R = [1 1 0.2 NaN; 1 1 0.1 NaN; 0.2 0.1 1 NaN; NaN NaN NaN NaN];

%% fully correlated reactions are grouped, NaN reactions are skipped

[selRxns, rxnSets, rxnList, Rfilt] = removeCorrelRxns(model, R);
assert(isequal(selRxns, [true; false; true; false]));
assert(isequal(rxnSets, {{'a'; 'b'}; {'c'}}));
assert(isequal(rxnList, {'a/b'; 'c'}));
assert(isequal(Rfilt, [1 0.2; 0.2 1]));

%% a lower cutoff merges more reactions

[selRxns, rxnSets, rxnList, Rfilt] = removeCorrelRxns(model, R, 0.15);
assert(isequal(selRxns, [true; false; false; false]));
assert(isequal(rxnSets, {{'a'; 'b'; 'c'}}));
assert(isequal(rxnList, {'a/b/c'}));
assert(isequal(Rfilt, 1));

%% negative correlations count through their absolute value

R2 = [1 -1; -1 1];
[selRxns, rxnSets, rxnList] = removeCorrelRxns(struct('rxns', {{'a'; 'b'}}), R2);
assert(isequal(selRxns, [true; false]));
assert(isequal(rxnSets, {{'a'; 'b'}}) && isequal(rxnList, {'a/b'}));

% change the directory
cd(currentDir)
