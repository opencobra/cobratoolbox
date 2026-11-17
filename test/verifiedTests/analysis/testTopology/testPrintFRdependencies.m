% The COBRAToolbox: testPrintFRdependencies.m
%
% Purpose:
%     - printFRdependencies(model, filePathName) reports, for each dependent row of [F, R]
%       (model.FRdrows, one row of model.FRW each), the metabolites it depends on, the
%       reactions of model.FRVcols that consume or produce it, and the submatrix of [F, R]
%       (F = -S and R = S with negative entries set to zero) on the independent and dependent
%       rows, to the command window or, appended, to a text file. Its documented input is the
%       model returned by checkRankFR (header line 10).
%     - Once the defects below are fixed, the test should feed it FR fields in the exact form
%       checkRankFR returns them (a -1 entry of each FRW row at its own dependent row, FRwrows
%       taken from every nonzero FRW column, FRW rows in the pivot order of getRankLUSOL) on
%       small createModel models with a known row dependency (e.g. R1: A + C -> E, R2: E -> A
%       + D, R3: B + D -> G, R4: G -> B + C, where D = A + B - C in [F, R]), and check every
%       printed line, the dimension and the rank of the displayed submatrix, the display
%       limits (more than 8 metabolites, more than 15 rows) and the appended file form.
%       Quarantined: no behaviour of printFRdependencies is asserted until the wrong-result
%       defects below are fixed; this file only opens the test.
%
% Function under test:
%     src/analysis/topology/FR/printFRdependencies.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - hand-built createModel models with the FR fields of checkRankFR, no solver.
%
% Coverage exemptions:
%     every line - printFRdependencies is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Each dependent metabolite is reported as dependent on itself
%       SEVERITY: wrong-result
%       TRIGGER: the model returned by checkRankFR for fm = createModel({'R1'; 'R2'; 'R3';
%         'R4'}, {'R1'; 'R2'; 'R3'; 'R4'}, {'A + C -> E'; 'E -> A + D'; 'B + D -> G'; 'G -> B
%         + C'}) with lb = -1000, ub = 1000 and SIntRxnBool, SIntMetBool, SConsistentRxnBool,
%         SConsistentMetBool all true; printFRdependencies(fmOut). checkRankFR itself stops at
%         its line 541 on this machine (method.solver 'gurobi5' and method.interface
%         'solveCobraLP' are hard-coded at its lines 534-535), so the fields were produced by a
%         copy of checkRankFR with only those two names changed to 'gurobi' and 'SDCCO'
%       OBSERVED: (R2025a, 2026-11-17) checkRankFR gives rankFR = 5, FRdrows = D[c], FRW = [A:1,
%         B:1, C:-1, D:-1] (lines 636-655 of checkRankFR put -1 at the dependent row) and the
%         report prints 'D[c] is dependent on: A[c] and B[c] and C[c] and D[c].' (lines 38 and
%         97 list every nonzero FRW column, the dependent row included); the same for two
%         copies of the module (C[c] and Cx[c] each listed as dependent on themselves)
%       EXPECTED: 'D[c] is dependent on: A[c] and B[c] and C[c].' (the documented FRW
%         expresses dependent rows as combinations of independent rows)
%       LINES: 37-38, 96-97
%     - DEFECT: Dependent rows are counted and displayed among the independent rows
%       SEVERITY: wrong-result
%       TRIGGER: the same checkRankFR output as the entry above; printFRdependencies(fmOut)
%       OBSERVED: (R2025a, 2026-11-17) FRwrows of checkRankFR (its line 641) holds every nonzero
%         FRW column, so wR = A, B, C, D includes the dependent row D; the report prints 'FR
%         subset of dimension 5 x 4, of rank 3.', '4 independent rows:' (D among them) and '1
%         dependent rows:' (D again): row D appears twice in FRdisplay (lines 74 and 130). With
%         two copies of the module: '10 x 8', '8 independent rows:', '2 dependent rows:'
%       EXPECTED: 3 independent rows (A, B, C) and 1 dependent row (D), a 4-row submatrix
%       LINES: 29, 73-74, 83-86, 129-130, 139-140
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Quarantined after the independent review (T027/T028), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrintFRdependencies'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
