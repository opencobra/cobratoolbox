% The COBRAToolbox: testCheckScaling.m
%
% Purpose:
%     - checkScaling computes the geometric-mean row and column scaling factors (gmscale) of
%       the constraint matrix of a model (S, or S with b, C, d, D, E or a given A), the
%       ranges of the coefficients and bounds, prints a summary and recommends double or
%       quad precision and the installed solvers. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): a model whose lower bounds are all
%       zero, and a model with coupling constraints but without b, stop with an error
%       (defects below), so no assertion about the function is made. The legacy test
%       testSubspaces.m calls checkScaling on ecoli_core_model (which has negative lower
%       bounds) among other functions.
%
% Function under test:
%     src/analysis/subspaces/checkScaling.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a test would use small createModel models; no solver (the global SOLVERS
%     table is only read for the recommendation).
%
% Coverage exemptions:
%     every line - checkScaling is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A model whose lower bounds are all zero stops with an error
%       SEVERITY: error
%       TRIGGER: model = createModel({'R1'; 'R2'; 'R3'}, {'r1'; 'r2'; 'r3'}, {' -> A'; 'A ->
%         B'; 'B -> '}, [], zeros(3, 1), 10 * ones(3, 1)); checkScaling(model, 'fine', 0)
%       OBSERVED: MATLAB R2025a: 'Operands to the logical AND (&&) and OR (||) operators must
%         be convertible to logical scalar values. Use the ANY or ALL functions to reduce
%         operands to logical scalar values.' at line 305: without a non-zero lower bound
%         minLB (line 219) and ratioL (line 222) are empty. The same model with lb(1) = -5
%         returns 'double'. A model whose upper bounds are all zero reaches the same test at
%         line 321.
%       EXPECTED: the scaling summary and recommendation, with the lower-bound ratio left out
%         (an all-irreversible model is a valid model)
%       LINES: 219-222, 305, 321
%     - DEFECT: A model with C and d but without b stops with an error
%       SEVERITY: error
%       TRIGGER: the model above with lb(1) = -5, the field b removed and C = [1 0 0], d = 5,
%         dsense = 'L': checkScaling(model, 'fine', 0)
%       OBSERVED: MATLAB R2025a: 'Unrecognized field name "b".' at line 157; lines 136 and 157
%         assemble [S, b; C, d] whenever C and d are present, although the header lists b
%         among the optional fields analysed if present
%       EXPECTED: the constraint matrix assembled from S, C and d with b taken as zero (the
%         COBRA default right-hand side), as for a model without C and d (lines 165-171)
%       LINES: 136, 157
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCheckScaling'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
