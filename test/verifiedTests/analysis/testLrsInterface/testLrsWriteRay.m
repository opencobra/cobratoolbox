% The COBRAToolbox: testLrsWriteRay.m
%
% Purpose:
%     - lrsWriteRay(Q, modelName, vertexBool, param) writes the lrs V-representation file
%       <modelName>.ext of the vertices and rays in the columns of Q (with the origin added as
%       the vertex when all columns are rays). The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): with vertices and rays the vertices
%       are declared lrs linearities, and the positivity rows lie outside the row count, so
%       lrs computes the facets of another polyhedron; no assertion about the function is
%       made.
%
% Function under test:
%     src/analysis/topology/extremeRays/lrs/lrsInterface/lrsWriteRay.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - no solver; a test would write the files in a temporary folder and compare their
%     text (running lrs on them only to show what it reads).
%
% Coverage exemptions:
%     every line - lrsWriteRay is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: vertices are written as lrs linearities
%       SEVERITY: wrong-result
%       TRIGGER: lrsWriteRay([2 0 1 0; 0 2 0 1], 'mix', [1; 1; 0; 0], struct()), i.e. vertices
%         (2, 0), (0, 2) and rays (1, 0), (0, 1), then system('lrs mix.ext')
%       OBSERVED: mix.ext has "linearity 2 1 2" before "begin / 4 3 integer / 1 2 0 / 1 0 2 /
%         0 1 0 / 0 0 1 / end" (R2025a, lrslib 7.1, 2026-11-16); lrs returns the single facet
%         "-2 1 1", i.e. x1 + x2 >= 2 without x >= 0
%       EXPECTED: no linearity line (a vertex is not a line), and lrs returns x1 + x2 >= 2,
%         x1 >= 0, x2 >= 0, as for the same file without the linearity line
%       LINES: 87-96
%     - DEFECT: the positivity rows are not counted
%       SEVERITY: wrong-result
%       TRIGGER: lrsWriteRay([2 0 1 0; 0 2 0 1], 'mix', [1; 1; 0; 0], struct('positivity', 1)),
%         or any Q with param.positivity = 1, then system('lrs mix.ext')
%       OBSERVED: the count stays "4 3 integer" while the rows "1 1 0" and "1 0 1" follow
%         (lines 101 and 124 count only the columns of Q); lrs ignores the extra rows
%       EXPECTED: the row count includes the nMonomial positivity rows
%       LINES: 101, 124, 138-150
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLrsWriteRay'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so nothing is run;
% the call is the standard opening of a COBRA test
prepareTest();

% change the directory
cd(currentDir)
