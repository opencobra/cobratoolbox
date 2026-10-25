% The COBRAToolbox: testConnectedRxnsInNullSpace.m
%
% Purpose:
%     - connectedRxnsInNullSpace numbers the connected groups of reactions (rows) of a null-space
%     matrix N: rows that share a non-zero column are in the same group; all-zero rows get 0.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/thermo/thermoFBA/connectedRxnsInNullSpace.m
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
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConnectedRxnsInNullSpace'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% groups of rows that share a column

% rows 1 and 2 share column 1, row 3 uses column 2 alone, row 4 is all zero
assert(isequal(connectedRxnsInNullSpace([1 0; 1 0; 0 1; 0 0]), [1; 1; 2; 0]));

%% connection through a chain of columns

% row 1 - column 1 - row 2 - column 2 - row 3 are one group; row 4 is separate
assert(isequal(connectedRxnsInNullSpace([1 0 0; 1 1 0; 0 1 0; 0 0 1]), [1; 1; 1; 2]));

%% a row that touches two groups joins them

assert(isequal(connectedRxnsInNullSpace([1 0; 0 1; 1 1]), [1; 1; 1]));

%% no non-zero row: every group number is 0

assert(isequal(connectedRxnsInNullSpace(zeros(3, 2)), [0; 0; 0]));

% change the directory
cd(currentDir)
