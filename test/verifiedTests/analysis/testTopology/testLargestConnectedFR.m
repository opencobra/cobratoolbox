% The COBRAToolbox: testLargestConnectedFR.m
%
% Purpose:
%     - largestConnectedFR returns the rows of [F, R] in the largest connected component of the
%       bipartite graph of [F, R] (rows and columns are the nodes, a nonzero is an edge; a column
%       of F and the same column of R are different columns), as an m x 1 logical vector, using
%       gaimc largest_component. With printLevel > 0 the time of each step is printed. The second
%       output is meant to give the columns of [F; R] in its largest connected set (see the
%       defect below).
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: the expected rows are read off the hand-built matrices, whose largest
%       component is unique (no first-run value is needed).
%
% Function under test:
%     src/analysis/topology/FR/largestConnectedFR.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Line 23, the error raised when the gaimc toolbox (external/analysis/gaimc, on the path after
%     initCobraToolbox) is missing: reaching it would require removing gaimc from the MATLAB path.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The column output is read from the row nodes and has m entries
%       SEVERITY: wrong-result
%       TRIGGER: any call (second output connectedColsFRVBool)
%       OBSERVED: connectedColsFRVBool = pB(1:m) holds the first m rows of [F; R] (the rows of F)
%         in the largest component of the bipartite graph of [F; R]: an m x 1 vector over rows
%       EXPECTED: an n x 1 vector over the columns, pB(2m+1:2m+n)
%       LINES: 71
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLargestConnectedFR'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% rows 1 and 2 share column 2 of F and use three columns in all (component of 5 nodes); row 3
% uses column 2 of R only, a different column of [F, R] (component of 2 nodes); row 4 is empty
F = [1 1 0 0; 0 1 0 0; 0 0 0 0; 0 0 0 0];
R = [0 0 0 0; 0 0 0 1; 0 1 0 0; 0 0 0 0];
expectedRows = [true; true; false; false];

%% default printLevel: the rows of the largest component

[connectedRowsFRBool, connectedColsFRVBool] = largestConnectedFR(F, R);

assert(islogical(connectedRowsFRBool) && isequal(connectedRowsFRBool, expectedRows));
% the second output is a logical vector (its content is not asserted, see the defect)
assert(islogical(connectedColsFRVBool) && isvector(connectedColsFRVBool));

% printLevel 0 is the default; the values of the entries do not matter, only their pattern
assert(isequal(largestConnectedFR(F, R, 0), expectedRows));
assert(isequal(largestConnectedFR(-2 * F, 0.1 * R), expectedRows));

%% printLevel 1: the same result, with the time of each step printed

connectedRowsFRBool = largestConnectedFR(F, R, 1);
assert(isequal(connectedRowsFRBool, expectedRows));

%% the largest component reached through R

% rows 2, 3 and 4 share column 1 of R; row 1 is alone with column 1 of F
F = [1 0; 0 0; 0 1; 0 0];
R = [0 0; 1 0; 1 0; 1 0];
assert(isequal(largestConnectedFR(F, R), [false; true; true; true]));

% change the directory
cd(currentDir)
