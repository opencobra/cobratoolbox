% The COBRAToolbox: testAddCOBRAConstraints.m
%
% Purpose:
%     - addCOBRAConstraints(model, idList, d, ...) appends constraints c * v(idList) dsense d
%       (fields C, d, dsense, ctrs, and D for extra variables) to a model. The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): its
%       checkDuplicates option adds duplicates of constraints on extra variables, drops
%       distinct constraints given together, and stops with an error in two common cases;
%       no assertion about the function is made. The defects are confined to calls with
%       'checkDuplicates' true; no src/ function calls it that way (2026-11-23).
%
% Function under test:
%     src/reconstruction/refinement/addCOBRAConstraints.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a small hand-built model (createModel), no solver.
%
% Coverage exemptions:
%     every line - addCOBRAConstraints is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: checkDuplicates does not detect an existing constraint that involves extra variables
%       SEVERITY: wrong-result
%       TRIGGER: model = createModel({'R1','R2','R3'}, {'','',''}, {'a[c] -> b[c]',
%         'b[c] -> c[c]', 'c[c] -> '}, 'printLevel', 0); model = addCOBRAVariables(model,
%         {'v1','v2'}); m1 = addCOBRAConstraints(model, {'R1','v1'}, 3, 'c', [1 2]);
%         m2 = addCOBRAConstraints(m1, {'R1','v1'}, 3, 'c', [1 2], 'checkDuplicates', true)
%       OBSERVED: (R2025a, 2026-11-23) m2.ctrs = {'Constraint1'; 'Constraint2'}, full(m2.C) =
%         [1 0 0; 1 0 0], full(m2.D) = [2 0; 2 0], no warning: line 241 compares the
%         coefficients of the extra variables with the rows of E (metabolites x variables)
%         instead of the rows of D (constraints x variables)
%       EXPECTED: the warning "Constraint(s) not added, because it already exists with ID:
%         Constraint1" and m2 equal to m1, as for the same constraint on reactions only
%       LINES: 241-242
%     - DEFECT: checkDuplicates drops a distinct constraint of the input when the ids are not sorted
%       SEVERITY: wrong-result
%       TRIGGER: model as above without variables; addCOBRAConstraints(model, {'R2','R1'},
%         [3 3 5], 'c', [2 1; 1 2; 1 1], 'checkDuplicates', true)
%       OBSERVED: (R2025a, 2026-11-23) two constraints, full(C) = [1 1 0; 1 2 0] with d = [5; 3]:
%         2*R1 + R2 <= 3 is dropped as a duplicate of R1 + 2*R2 <= 3, because lines 200-202 sort
%         the coefficients of the first input row only (the loop runs over size(idList, 1) = 1
%         row); with idList {'R1','R2'} the same call adds all three constraints
%       EXPECTED: three constraints (rows [1 2 0], [2 1 0], [1 1 0]), none being a duplicate
%       LINES: 197-205
%     - DEFECT: checkDuplicates stops when the number of ids equals the number of constraints
%       SEVERITY: error
%       TRIGGER: model as above without variables; addCOBRAConstraints(model, {'R1','R2'},
%         [3 4], 'c', [1 2; 3 4], 'checkDuplicates', true) (also with idList {'R1';'R2'})
%       OBSERVED: (R2025a, 2026-11-23) "Dimensions of arrays being concatenated are not
%         consistent." at line 204: idList is turned into a column (line 104) and the sort of
%         line 197 along dimension 2 then gives a column that does not fit the coefficient rows
%       EXPECTED: two constraints added (none of them exists), as without checkDuplicates
%       LINES: 104, 197-204
%     - DEFECT: checkDuplicates stops when the model holds the constraint twice
%       SEVERITY: error
%       TRIGGER: model as above without variables; m3 = addCOBRAConstraints(model, {'R1'},
%         [3 3], 'dsense', 'LL'); addCOBRAConstraints(m3, {'R1'}, 3, 'checkDuplicates', true)
%       OBSERVED: (R2025a, 2026-11-23) "Operands to the logical AND (&&) and OR (||) operators
%         must be convertible to logical scalar values. ..." at line 246: dsense and d of
%         every matching row are compared with && instead of any matching row
%       EXPECTED: the duplicate warning and the model returned unchanged
%       LINES: 246
%     - DEFECT: The duplicate warning names the constraint matched by the last input row only
%       SEVERITY: cosmetic
%       TRIGGER: model as above without variables; m1 = addCOBRAConstraints(model, {'R2','R1'},
%         [3 4], 'c', [2 1; 4 3]); addCOBRAConstraints(m1, {'R2','R1'}, [3 4 4], 'c',
%         [2 1; 4 3; 3 4], 'checkDuplicates', true, 'ConstraintID', {'x','y','z'})
%       OBSERVED: (R2025a, 2026-11-23) the two existing constraints are correctly skipped and z
%         is added, but the warning reads "... already exists with ID: Constraint2" only: line
%         251 uses dupRows of the last loop iteration
%       EXPECTED: the warning names Constraint1 and Constraint2
%       LINES: 251
%     - DEFECT: A coefficient vector c given as a column stops the call
%       SEVERITY: error
%       TRIGGER: model = createModel({'R1','R2','R3'}, {'','',''}, {'a[c] -> b[c]','b[c] -> c[c]',
%         'c[c] -> '}, 'printLevel', 0); addCOBRAConstraints(model, {'R1','R2'}, 10, 'c', [1; 2])
%       OBSERVED: (R2025a, 2026-11-23, lead and writer of wave 31) the parser (line 137) accepts c
%         because its length equals that of idList, but line 230 loops over the rows of c and
%         indexes c(i, rxnpos), beyond the single column ("The logical indices in position 2
%         contain a true value outside of the array bounds."); the same c as a row gives C = [1 2 0]
%       EXPECTED: the constraint R1 + 2 R2 <= 10 ("c: a vector with coefficients for each element
%         in idList"; only a matrix means several constraints)
%       LINES: 137, 229-230
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddCOBRAConstraints'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
