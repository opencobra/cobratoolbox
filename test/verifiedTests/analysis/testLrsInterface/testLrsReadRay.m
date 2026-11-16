% The COBRAToolbox: testLrsReadRay.m
%
% Purpose:
%     - lrsReadRay(modelName, param) reads an lrs V-representation file <modelName>.ext into Q
%       (vertices first, then the rays ordered by their number of nonzeros) and vertexBool.
%       The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the documented call without param fails, a rational row (which lrs
%       writes for fractional vertices) is lost or stops the read, and a vertex whose
%       coordinates sum to zero is dropped; no assertion about the function is made.
%
% Function under test:
%     src/analysis/topology/extremeRays/lrs/lrsInterface/lrsReadRay.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - no solver; a test would write .ext files in a temporary folder and compare the
%     matrices read back with the hand-written vertices and rays.
%
% Coverage exemptions:
%     every line - lrsReadRay is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: the optional param cannot be omitted
%       SEVERITY: error
%       TRIGGER: any .ext file w.ext, then lrsReadRay('w') or lrsReadRay('w', struct())
%       OBSERVED: "Unrecognized field name "inequality"." at line 43 (R2025a, 2026-11-16):
%         line 34 sets param.positivity where the missing field is param.inequality
%       EXPECTED: param.inequality defaults to 0 (OPTIONAL INPUT param) and the file is read
%       LINES: 33-35, 43
%     - DEFECT: a row with rational coefficients is lost
%       SEVERITY: wrong-result
%       TRIGGER: v2.ext holding "v2 / V-representation / begin / 3 3 rational / 1 0 0 /
%         1 1/2 0 / 0 0 1 / end", then lrsReadRay('v2', struct('inequality', 0))
%       OBSERVED: "Index exceeds array bounds." at line 159 (R2025a, 2026-11-16): the branch
%         for rows with '/' never stores the converted values, so the row stays zero, is
%         classed as a ray (first entry 0), removed as a zero ray at line 157, and the sort
%         index of line 158, computed over all rays, exceeds the remaining columns
%       EXPECTED: Q = [1/2 0; 0 1] with vertexBool = [true; false]
%       LINES: 123-136, 157-159
%     - DEFECT: a vertex whose coordinates sum to zero is removed
%       SEVERITY: wrong-result
%       TRIGGER: w.ext holding "w / V-representation / begin / 3 3 integer / 1 1 -1 / 1 2 0 /
%         0 0 1 / end", then [Q, vertexBool] = lrsReadRay('w', struct('inequality', 0))
%       OBSERVED: Q = [2 0; 0 1], vertexBool = [1 0] (R2025a, 2026-11-16): line 144 keeps
%         the vertices with sum(V, 1) ~= 0, so the vertex (1, -1) is dropped
%       EXPECTED: Q = [1 2 0; -1 0 1], vertexBool = [1 1 0] (only the zero vertex may be
%         removed, as the comment "remove zero vertices" says)
%       LINES: 144
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLrsReadRay'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so nothing is run;
% the call is the standard opening of a COBRA test
prepareTest();

% change the directory
cd(currentDir)
