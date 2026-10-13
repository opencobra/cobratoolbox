% The COBRAToolbox: testCompareQualAndQuantDir.m
%
% Purpose:
%     - compareQualAndQuantDir cross-tabulates the qualitative and quantitative directionality
%     assignments of the reactions of a model in a 4 by 4 cell table of counts with labels.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/thermo/directionalityReport/compareQualAndQuantDir.m
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

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCompareQualAndQuantDir'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% qualitative and quantitative directionality of ten reactions
model.qualDir  = [ 1  1  1  0  0  0 -1 -1 -1  1];
model.quantDir = [ 1  0 -1  1  0 -1  1  0 -1  1];
A = compareQualAndQuantDir(model);

%% counts of every combination

assert(isequal(size(A), [4 4]));
% rows: qualitatively forward, reversible, reverse; columns: quantitatively forward, reversible, reverse
assert(isequal(cell2mat(A(2:4, 2:4)), [2 1 1; 1 1 1; 1 1 1]));

%% labels

assert(strcmp(A{2, 1}, 'Qualitatively Forward'));
assert(strcmp(A{3, 1}, 'Qualitatively Reversible'));
assert(strcmp(A{4, 1}, 'Qualitatively Reverse'));
assert(strcmp(A{1, 2}, 'Quantitatively Forward'));
assert(strcmp(A{1, 3}, 'Quantitatively Reversible'));
assert(strcmp(A{1, 4}, 'Quantitatively Reverse'));
assert(isempty(A{1, 1}));

%% no reactions

empty.qualDir = [];
empty.quantDir = [];
A = compareQualAndQuantDir(empty);
assert(all(cell2mat(A(2:4, 2:4)) == 0, 'all'));

% change the directory
cd(currentDir)
