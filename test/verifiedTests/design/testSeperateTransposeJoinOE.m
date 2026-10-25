% The COBRAToolbox: testSeperateTransposeJoinOE.m
%
% Purpose:
%     - seperateTransposeJoinOE builds the constraint matrices, bounds and right-hand sides of the dual MILP used for reaction reinsertion in OptEnvelope, by transposing and joining the given arrays.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/design/optEnvelope/seperateTransposeJoinOE.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found. (The function is a helper of milpOEReinserts and is not designed for stand-alone use; the test checks the arrays it builds for a small example.)
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSeperateTransposeJoinOE'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% small example: 4 dual variables w (rows of A and Ay), 3 columns in A, 2 knock-out variables y
A = [1 2 0; 0 1 3; 1 0 1; 2 1 0];       % 4 x 3
Ay = [0.5 0; 0 -2; 0 0; 1 -3];       % 4 x 2: row 1 has a positive entry, row 2 a negative one, row 3 is empty
                 % (no z variable), row 4 has both (the negative one is used)
B = [10; 20; 30; 40];         % cost of the w variables
C = [1; 2; 3];         % right-hand side of the dual constraints
numY = 2;
yMax = 1;
numAColumns = 3;
bigNumber = 100;
numZ = 3;        % one z variable for every row of Ay that is not empty

[A_w, Ay_w, B_w, C_w, lb_w, ub_w, wSize] = seperateTransposeJoinOE(A, Ay, B, C, numY, yMax, numAColumns, bigNumber, numZ);

%% number of w variables

assert(wSize == 4);

%% constraint matrix: A' next to zeros, then 3 rows per z variable linking w, z and y

% the z variables are tied to the non-zero entry of the row of Ay (the negative one when the
% row has both): row 1 -> 0.5 (y1), row 2 -> -2 (y2), row 4 -> -3 (y2)
expectedA_w = [1 0 1 2 0 0 0; 2 1 0 1 0 0 0; 0 3 1 0 0 0 0; 0 0 0 0 1 0 0; 1 0 0 0 -1 0 0; -1 0 0 0 1 0 0; 0 0 0 0 0 1 0; 0 1 0 0 0 -1 0; 0 -1 0 0 0 1 0; 0 0 0 0 0 0 1; 0 0 0 1 0 0 -1; 0 0 0 -1 0 0 1];
assert(isequal(full(A_w), expectedA_w));

%% y part of the constraint matrix: zeros for the A' rows, then +/- bigNumber on the y of each z

expectedAy_w = [0 0; 0 0; 0 0; -100 0; 100 0; 0 0; 0 -100; 0 100; 0 0; 0 -100; 0 100; 0 0];
assert(isequal(full(Ay_w), expectedAy_w));

%% right-hand side: C followed by the big-number terms

expectedB_w = [1; 2; 3; 0; 100; 0; 0; 100; 0; 0; 100; 0];
assert(isequal(full(B_w), expectedB_w));

%% objective: B followed by minus the z coefficients (0.5, -2, -3)

assert(isequal(full(C_w), [10; 20; 30; 40; -0.5; 2; 3]));

%% bounds: w, z in [0, bigNumber]; y in [0, yMax]

assert(isequal(lb_w, zeros(9, 1)));
assert(isequal(ub_w, [bigNumber * ones(7, 1); yMax * ones(2, 1)]));

% change the directory
cd(currentDir)
