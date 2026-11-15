% The COBRAToolbox: testConvertCobraLP2mps.m
%
% Purpose:
%     - convertCobraLP2mps(LPProblem, name) writes the LP problem (A or S, b, c, lb, ub,
%       csense, osense) to the fixed-width MPS file <name>.mps through BuildMPS/SaveMPS,
%       turning every A(i,:)*x >= b(i) row into -A(i,:)*x <= -b(i), and returns 1 on success.
%       The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): only the first coefficient of a 'G' row is negated, so the file describes
%       a different problem whenever a 'G' row has a non-zero coefficient outside column 1;
%       no assertion about the function is made.
%
% Function under test:
%     src/base/io/convertCobraLP2mps.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would write a hand-built LP to a temporary folder
%     and read the MPS file back.
%
% Coverage exemptions:
%     every line - convertCobraLP2mps is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: only the first column of a 'G' row is negated
%       SEVERITY: wrong-result
%       TRIGGER: LP.A = sparse([1 2; 3 4]); LP.b = [5; 6]; LP.c = [1; 1]; LP.lb = [0; 0];
%         LP.ub = [10; 10]; LP.csense = ['G'; 'L']; LP.osense = 1;
%         convertCobraLP2mps(LP, 'conv')
%       OBSERVED: (R2025a, 2026-11-15) conv.mps holds row LE1 = -1*X1 + 2*X2 with RHS -5, that
%         is -x1 + 2*x2 <= -5. Line 72 indexes A2 with the m x 1 logical G, which selects
%         elements of the first column only (linear indexing), while line 73 negates b
%         correctly
%       EXPECTED: -x1 - 2*x2 <= -5 (the G row x1 + 2*x2 >= 5 multiplied by -1, as the comment
%         "need to change sign of A*x >= b constraints" says); writeLPProblem writes LE2 =
%         -1*X1 - 2*X2 <= -5 for the same problem (whole row negated)
%       LINES: 72
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConvertCobraLP2mps'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
