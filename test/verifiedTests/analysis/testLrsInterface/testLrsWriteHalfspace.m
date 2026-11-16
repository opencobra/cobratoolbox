% The COBRAToolbox: testLrsWriteHalfspace.m
%
% Purpose:
%     - lrsWriteHalfspace(A, b, csense, modelName, param) writes the lrs H-representation file
%       of {x : A x (csense) b} (and x >= 0 when param.positivity = 1), with the equalities as
%       an lrs linearity or as two opposite inequalities (param.inequality = 1). The function
%       is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): the
%       documented call without param fails, with no equality the row or column count is
%       wrong so lrs solves another polyhedron, and the sh option cannot be used; no
%       assertion about the function is made.
%
% Function under test:
%     src/analysis/topology/extremeRays/lrs/lrsInterface/lrsWriteHalfspace.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - no solver; a test would write the files in a temporary folder and compare their
%     text (running lrs on them only to show what it reads).
%
% Coverage exemptions:
%     every line - lrsWriteHalfspace is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: the optional param cannot be omitted
%       SEVERITY: error
%       TRIGGER: lrsWriteHalfspace([1 1]) or lrsWriteHalfspace([1 1], 2, 'E', 'm', struct())
%       OBSERVED: "Unrecognized field name "inequality"." at line 87 (R2025a, 2026-11-16):
%         line 43 sets param.positivity where the missing field is param.inequality
%       EXPECTED: the documented default of param.inequality is used and the file is written
%       LINES: 42-44, 87
%     - DEFECT: with no equality and positivity = 1 the row count omits the x >= 0 rows
%       SEVERITY: wrong-result
%       TRIGGER: lrsWriteHalfspace([1 1], 2, 'G', 'de', struct('positivity', 1, 'inequality', 0)),
%         i.e. x1 + x2 >= 2, x >= 0, then system('lrs de.ine')
%       OBSERVED: de.ine has "begin / 1 3 integer / -2 1 1 / 0 1 0 / 0 0 1 / end" (R2025a, lrslib
%         7.1, 2026-11-16): line 156 counts Drlt + clt = 1 + 0 (clt is 0 when A has no
%         equality) but Dclt = 2 positivity rows follow; lrs reads one row and returns vertex
%         (2, 0), ray (1, 0) and linearity (-1, 1), the half-plane without x >= 0
%       EXPECTED: "3 3 integer" and the V-representation of {x >= 0, x1 + x2 >= 2}
%       LINES: 156
%     - DEFECT: with no equality and inequality = 1 the column count is 1
%       SEVERITY: wrong-result
%       TRIGGER: lrsWriteHalfspace([1 1], 2, 'G', 'di', struct('positivity', 0, 'inequality', 1)),
%         then system('lrs di_neg_ineq.ine')
%       OBSERVED: "begin / 1 1 integer / -2 1 1 / end" (line 286 writes clt + 1 = 1); lrs
%         answers "No feasible solution" for a feasible half-plane
%       EXPECTED: "1 3 integer" (Dclt + 1 columns) and the V-representation of x1 + x2 >= 2
%       LINES: 286
%     - DEFECT: the shell-script option fails
%       SEVERITY: unusable-option
%       TRIGGER: lrsWriteHalfspace([1 1], 2, 'E', 'sh', struct('positivity', 0, 'inequality', 0, 'sh', 1))
%       OBSERVED: line 323 reads filenameSuffix, which is assigned nowhere in the file (not
%         run: the error "Unrecognized function or variable 'filenameSuffix'" follows from the
%         code), and line 326 would write to a fixed personal cluster folder (/nas/...)
%       EXPECTED: a script next to the .ine file (OPTIONAL INPUTS: "sh: output a shell script
%         for submitting a qsub job")
%       LINES: 322-328
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLrsWriteHalfspace'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so nothing is run;
% the call is the standard opening of a COBRA test
prepareTest();

% change the directory
cd(currentDir)
