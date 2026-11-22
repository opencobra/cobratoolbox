% The COBRAToolbox: testLrsOutputReadRay.m
%
% Purpose:
%     - lrsOutputReadRay(filename) reads the V-representation that lrs writes to a .ext file
%       (rows "1 v1 ... vn" for vertices, "0 r1 ... rn" for rays between "begin" and "end") and
%       returns the vertices V and the rays R as columns, the rays ordered by their number of
%       nonzeros. The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): a row with a rational entry (for example "1 1/2 0") is never stored, so it
%       stays a zero row and is returned as a zero ray while the vertex is lost; no assertion
%       about the function is made.
%
% Function under test:
%     src/analysis/topology/extremeRays/lrs/lrsInterface/lrsOutputReadRay.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would read hand-written .ext files in a temporary
%     folder (lrs is not needed to write them).
%
% Coverage exemptions:
%     every line - lrsOutputReadRay is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: rows with rational entries are dropped and become zero rays
%       SEVERITY: wrong-result
%       TRIGGER: sq.ine = "sq / H-representation / begin / 3 3 rational / 1 -2 0 / 0 1 0 /
%         0 0 1 / end" (one line per item: 1 - 2*x1 >= 0, x1 >= 0, x2 >= 0); system('lrs sq.ine
%         > sq.ext') writes the rows "1 0 0", "0 0 1" and "1 1/2 0"; then
%         [R, V] = lrsOutputReadRay('sq.ext')
%       OBSERVED: V = [0; 0] and R = [0 0; 0 1] (R2025a, lrslib 7.1, 2026-11-15): the vertex
%         (1/2, 0) is missing and a zero ray is returned instead. The '/' branch (lines 72-82)
%         converts "1/2" to 1.2 and then to fix(1.2)/mod(1.2, 1) = 5, but never assigns
%         scannedLine to P(r, :), so the row stays zero and is classified as a ray (line 94)
%       EXPECTED: V = [0 1/2; 0 0] (vertices (0, 0) and (1/2, 0)) and R = [0; 1] (description:
%         "Reads into matlab a vertex representation output from lrs"; lrs writes rationals
%         as p/q)
%       LINES: 70-82, 90-94
%     - DEFECT: the empty matrix P is printed to the command window
%       SEVERITY: cosmetic
%       TRIGGER: any call, for example [R, V] = lrsOutputReadRay('sq.ext') as above
%       OBSERVED: "P = 3x3 sparse double matrix All zero" printed (line 64 has no semicolon)
%       EXPECTED: no output
%       LINES: 64
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLrsOutputReadRay'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
