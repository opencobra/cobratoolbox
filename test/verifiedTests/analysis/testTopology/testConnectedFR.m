% The COBRAToolbox: testConnectedFR.m
%
% Purpose:
%     - connectedFR returns the connected sets of rows of [F, R]: two rows are connected when
%       they have a nonzero in the same column of [F, R] (a column of F and the same column of R
%       are different columns), directly or through other rows. The sets are computed as the
%       connected components of the bipartite graph of [F, R] (gaimc scomponents) and returned as
%       an m x z logical matrix with one column per set. The second output is meant to give the
%       connected sets of columns of [F; R] (see the defect below).
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: the expected sets are read off the hand-built matrices (no first-run
%       value is needed). The order of the sets depends on the component numbering of
%       scomponents, so the sets are compared without their order.
%
% Function under test:
%     src/analysis/topology/FR/connectedFR.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Line 18, the error raised when the gaimc toolbox (external/analysis/gaimc, on the path after
%     initCobraToolbox) is missing: reaching it would require removing gaimc from the MATLAB path.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The column sets are computed over the rows of [F; R]
%       SEVERITY: wrong-result
%       TRIGGER: any call (second output connectedColsFRVBool)
%       OBSERVED: the first n nodes of the bipartite graph of [F; R] are its first n rows, not
%         its columns, so the second output groups rows of [F; R]; for F = [1 0 0 0; 0 1 0 0;
%         0 0 1 0] and R = [0 1 0 0; 0 0 0 0; 0 0 0 1] it puts columns 2 and 4 together
%         although no row of [F; R] uses both
%       EXPECTED: the sets of the column nodes 2m+1 to 2m+n (here four single columns)
%       LINES: 52
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConnectedFR'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% compare two sets of columns of logical matrices without their order
sameSets = @(A, B) isequal(size(A), size(B)) && isequal(sortrows(double(A')), sortrows(double(B')));

%% rows sharing a column of F are connected; a column of R is a different column

% rows 1 and 2 share column 2 of F; row 3 uses column 2 of R only, which is a different column of
% [F, R], so it forms its own set; row 4 is empty and forms its own set
F = [1 1 0 0; 0 1 0 0; 0 0 0 0; 0 0 0 0];
R = [0 0 0 0; 0 0 0 1; 0 1 0 0; 0 0 0 0];

[connectedRowsFRBool, connectedColsFRVBool] = connectedFR(F, R);

assert(islogical(connectedRowsFRBool));
assert(sameSets(connectedRowsFRBool, logical([1 0 0; 1 0 0; 0 1 0; 0 0 1])));
% every row is in exactly one set
assert(all(sum(connectedRowsFRBool, 2) == 1));
% the second output is a logical matrix with one row per column of F (its content is not
% asserted, see the defect)
assert(islogical(connectedColsFRVBool) && size(connectedColsFRVBool, 1) == 4);

%% rows connected through a chain, and through R

% rows 1-2 share column 1 of F, rows 2-3 share column 3 of R: one set {1, 2, 3}; row 4 shares
% column 4 of F with no other row
F = [1 0 0 0; 1 0 0 0; 0 0 0 0; 0 0 0 1];
R = [0 0 0 0; 0 0 1 0; 0 0 1 0; 0 0 0 0];

connectedRowsFRBool = connectedFR(F, R);
assert(sameSets(connectedRowsFRBool, logical([1 0; 1 0; 1 0; 0 1])));

% the values of the entries do not matter, only their pattern
connectedRowsFRBool = connectedFR(-3 * F, 0.5 * R);
assert(sameSets(connectedRowsFRBool, logical([1 0; 1 0; 1 0; 0 1])));

%% all rows connected: one set

F = [1 1; 0 1; 1 0];
R = [0 0; 0 0; 0 0];
connectedRowsFRBool = connectedFR(F, R);
assert(isequal(connectedRowsFRBool, true(3, 1)));

% change the directory
cd(currentDir)
