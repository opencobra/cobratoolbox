% The COBRAToolbox: testFindGenesAboveThresholdGT1.m
%
% Purpose:
%     - findGenesAboveThresholdGT1 lists the genes whose expression value is above a threshold, with
%     the value and the label High.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/igemRNA/GT1/findGenesAboveThresholdGT1.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Errors when no gene qualifies
%       SEVERITY: error
%       TRIGGER: a threshold that no expression value passes
%       OBSERVED: the output genes is only assigned inside the loop, so the call errors
%         (MATLAB:unassignedOutputs)
%       EXPECTED: an empty list
%       LINES: 24-33
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindGenesAboveThresholdGT1'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

geneNames = {'g1'; 'g2'; 'g3'};
expressionValues = [1 7 9];

%% genes that pass the test: name, value and label, in the order of the input
% rule: threshold < expression value (strictly greater)

genes = findGenesAboveThresholdGT1(5, geneNames, expressionValues);
assert(isequal(genes, {'g2', 7, 'High'; 'g3', 9, 'High'}));

%% all genes pass

genes = findGenesAboveThresholdGT1(-100, geneNames, expressionValues);
assert(isequal(size(genes), [3 3]));
assert(all(strcmp(genes(:, 3), 'High')));

% change the directory
cd(currentDir)
