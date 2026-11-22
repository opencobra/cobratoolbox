% The COBRAToolbox: testLrsInputHalfspace.m
%
% Purpose:
%     - lrsInputHalfspace(A, D, filename, positivity, inequality, a, d, f, sh) writes an lrs
%       H-representation file <filename>_<pos|neg>_<eq|ineq>.ine for {x : A*x = a, D*x >= d}
%       (and x >= 0 when positivity = 1), with the equalities either as an lrs linearity
%       (inequality = 0) or as two opposite inequalities (inequality = 1), an optional linear
%       objective f and an optional qsub shell script. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): with A empty it writes a
%       wrong row or column count, so lrs solves a different polyhedron, and the f and sh
%       options cannot be used; no assertion about the function is made.
%
% Function under test:
%     src/analysis/topology/extremeRays/lrs/lrsInterface/lrsInputHalfspace.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would write the files in a temporary folder and
%     compare their text (running lrs on them only to show what it reads).
%
% Coverage exemptions:
%     every line - lrsInputHalfspace is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: with A empty and positivity = 1 the row count omits the x >= 0 rows
%       SEVERITY: wrong-result
%       TRIGGER: lrsInputHalfspace([], [1 1], 'de', 1, 0, zeros(0, 1), 2), i.e. x1 + x2 >= 2,
%         x >= 0, then system('lrs de_pos_eq.ine')
%       OBSERVED: de_pos_eq.ine has "begin / 1 3 integer / -2 1 1 / 0 1 0 / 0 0 1 / end"
%         (R2025a, lrslib 7.1, 2026-11-15): the count is Drlt + clt = 1 + 0 (line 124 uses
%         clt, the column count of the empty A) but Dclt = 2 positivity rows follow; lrs reads
%         one row and returns vertex (2, 0), ray (1, 0) and linearity (-1, 1), i.e. the
%         half-plane x1 + x2 >= 2 without x >= 0
%       EXPECTED: "3 3 integer" (Drlt + Dclt rows) and the V-representation of {x >= 0,
%         x1 + x2 >= 2}: vertices (2, 0), (0, 2), rays (1, 0), (0, 1)
%       LINES: 124
%     - DEFECT: with A empty and inequality = 1 the column count is 1
%       SEVERITY: wrong-result
%       TRIGGER: lrsInputHalfspace([], [1 1], 'di', 1, 1, zeros(0, 1), 2), then
%         system('lrs di_pos_ineq.ine'); likewise with positivity = 0 ('dn_neg_ineq.ine')
%       OBSERVED: "begin / 1 1 integer / -2 1 1 / end" (line 260 writes clt + 1 = 1, clt being
%         the column count of the empty A); lrs answers "No feasible solution" for a feasible
%         polyhedron
%       EXPECTED: "1 3 integer" (Dclt + 1 columns) and the V-representation of the polyhedron
%       LINES: 260
%     - DEFECT: the linear objective f is malformed and placed where lrs ignores it
%       SEVERITY: unusable-option
%       TRIGGER: lrsInputHalfspace([1 1 -1], [], 'lp', 1, 0, 1, [], [1 2 3]), then
%         system('lrs lp_pos_eq.ine'); and lrsInputHalfspace([1 1 -1], [], 'lq', 1, 1, 1, [],
%         [1 2 3])
%       OBSERVED: the files hold "lponly / minimize 02 3" (equality form: the loop of line 80
%         starts at c = 2, so f(1) is dropped, and no space follows the constant 0) and
%         "lponly / minimize 01 2 3" (inequality form, lines 233-235), both before "begin";
%         lrs ignores them and prints the full V-representation (vertices and rays) instead
%         of an LP solution
%       EXPECTED: an lrs LP request "minimize 0 1 2 3" with "lponly" (OPTIONAL INPUTS: "f:
%         linear objective for a linear optimization problem in rational arithmetic")
%       LINES: 76-84, 230-238
%     - DEFECT: the shell script writes to a fixed personal folder
%       SEVERITY: unusable-option
%       TRIGGER: lrsInputHalfspace([1 1 -1], [], 'sh', 1, 1, 0, [], [], 1)
%       OBSERVED: sh_pos_ineq.sh holds "(time lrs sh_pos_ineq.ine > /nas/rfleming/sh_pos_ineq.ext)
%         2> sh_pos_ineq.time" (line 300), a folder of one developer's cluster
%       EXPECTED: a script whose output .ext lies next to the input (OPTIONAL INPUTS: "sh: if
%         sh == 1, output a shell script for submitting qsub job")
%       LINES: 300
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLrsInputHalfspace'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
