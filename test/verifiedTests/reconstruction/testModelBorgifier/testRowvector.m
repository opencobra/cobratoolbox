% The COBRAToolbox: testRowvector.m
%
% Purpose:
%     - rowvector returns its input as a row when it has more rows than columns and unchanged
%     otherwise.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/rowvector.m
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
fileDir = fileparts(which('testRowvector'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% a column becomes a row

assert(isequal(rowvector([1; 2; 3]), [1 2 3]));

%% rows and square matrices stay

assert(isequal(rowvector([1 2 3]), [1 2 3]));
assert(isequal(rowvector([1 2; 3 4]), [1 2; 3 4]));

%% a tall matrix is transposed

assert(isequal(rowvector([1 2; 3 4; 5 6]), [1 3 5; 2 4 6]));

% change the directory
cd(currentDir)
