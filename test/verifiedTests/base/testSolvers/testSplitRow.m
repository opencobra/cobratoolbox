% The COBRAToolbox: testSplitRow.m
%
% Purpose:
%     - splitRow rescales a badly scaled constraint row: the row is split into the row with its
%     largest coefficient plus a new variable z, and a new equality row that defines z from the
%     other coefficients.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/solvers/rescale/splitRow.m
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
fileDir = fileparts(which('testSplitRow'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% a row with one very large coefficient

constraints = [1 0 2e6; 0 3 4];
[newMatrix, variableNames, lowerBounds, upperBounds, objective, rhs, sense, constraintNames] = ...
    splitRow(constraints, 1, {'z_1'}, -1, 1, 0, [0; 0], ['L'; 'E'], {'r1'; 'r2'});
% row 1 keeps only its largest coefficient (2e6) and gets the new variable z_2 with coefficient 1;
% the new row defines z_2 = the other coefficients (here -(1 * x1))
assert(isequal(full(newMatrix), [0 0 2e6 1; 0 3 4 0; -1 0 0 1]));
assert(isequal(variableNames, {'z_1'; 'z_2'}));       % the new variable is numbered after the existing z_ names
assert(isequal(lowerBounds, [-1; -Inf]) && isequal(upperBounds, [1; Inf]) && isequal(objective, [0; 0]));
assert(isequal(rhs, [0; 0; 0]));
assert(isequal(sense, ['L'; 'E'; 'E']));              % the definition of z is an equality
assert(isequal(constraintNames, {'r1'; 'r2'; 'r1_split1'}));

%% the largest coefficient is chosen by absolute value, the others move to the new row

[newMatrix, variableNames, ~, ~, ~, rhs, sense, constraintNames] = ...
    splitRow([5 -7; 1 2], 1, {}, [], [], [], [0; 0], ['L'; 'L'], {'c1'; 'c2'});
assert(isequal(full(newMatrix), [0 -7 1; 1 2 0; -5 0 1]));
assert(isequal(variableNames, {'z_1'}));
assert(isequal(constraintNames, {'c1'; 'c2'; 'c1_split1'}));
assert(isequal(rhs, [0; 0; 0]) && isequal(sense, ['L'; 'L'; 'E']));

% change the directory
cd(currentDir)
