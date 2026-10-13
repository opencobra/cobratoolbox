% The COBRAToolbox: testLsqraprod.m
%
% Purpose:
%     - lsqraprod multiplies a vector by a sparse test matrix A (A(i,i) = i and A(i+1,i) = i) in
%     mode 1, or by its transpose in mode 2; it is the example operator of the lsqr solver.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/subspaces/lsqr/lsqraprod.m
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
fileDir = fileparts(which('testLsqraprod'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% mode 1: y = A*x (m rows, n columns)

% A (3 x 3) = [1 0 0; 1 2 0; 0 2 3] and x = [1; 1; 1]
assert(isequal(lsqraprod(1, 3, 3, [1; 1; 1], [], []), [1; 3; 5]));
% fewer rows than columns + 1: the result is cut to m entries (A is 2 x 3)
assert(isequal(lsqraprod(1, 2, 3, [1; 1; 1], [], []), [1; 3]));
% more rows than n + 1: the result is padded with zeros (A is 6 x 3)
assert(isequal(lsqraprod(1, 6, 3, [1; 1; 1], [], []), [1; 3; 5; 3; 0; 0]));

%% mode 2: y = A'*x (x has m entries, the result has n entries)

% square case
assert(isequal(lsqraprod(2, 3, 3, [1; 1; 1], [], []), [2; 4; 3]));
% fewer rows than columns: the result is padded with zeros
assert(isequal(lsqraprod(2, 3, 5, [1; 1; 1], [], []), [2; 4; 3; 0; 0]));
% more rows than columns: the result is cut to n entries
assert(isequal(lsqraprod(2, 5, 3, [1; 1; 1; 1; 1], [], []), [2; 4; 6]));

% change the directory
cd(currentDir)
