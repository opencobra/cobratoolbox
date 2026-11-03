% The COBRAToolbox: testRemoveCorrelRxns.m
%
% Purpose:
%     - removeCorrelRxns groups fully or almost fully correlated reactions using a correlation
%     matrix and returns the selection of one reaction per group, the groups, the group names joined
%     with slashes and the filtered correlation matrix.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Defect(s) fixed by feature 20261102-140321-tier1-safe-defect-fixes: A reaction whose own
%       correlation is below the cutoff gets an empty group and no name.
%
% Function under test:
%     src/analysis/sampling/ACHR/removeCorrelRxns.m
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
%     - Updated for feature 20261102-140321-tier1-safe-defect-fixes, 2026-11-02.

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

%% a reaction whose own correlation is below the cutoff forms its own group

% the diagonal entry of b (0.5) is below the cutoff and b is not correlated with a or c
R3 = [1 0.1 0.2; 0.1 0.5 0.3; 0.2 0.3 1];
[selRxns, rxnSets, rxnList, Rfilt] = removeCorrelRxns(struct('rxns', {{'a'; 'b'; 'c'}}), R3);
assert(isequal(selRxns, [true; true; true]));
assert(isequal(rxnSets, {{'a'}; {'b'}; {'c'}}));
assert(isequal(rxnList, {'a'; 'b'; 'c'}));
assert(isequal(Rfilt, R3));

% change the directory
cd(currentDir)
