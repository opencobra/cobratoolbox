% The COBRAToolbox: testWriteLPProblem.m
%
% Purpose:
%     - writeLPProblem(LPProblem, varargin) writes an LP or MILP problem to a fixed-width MPS
%       file through BuildMPS/SaveMPS (name-value options problemName, fileName, solverParams,
%       outputFormat and writeMatrix, or the first four given by position) and returns 1 on
%       success. The function is QUARANTINED (Constitution III-Defects, quarantine in
%       back-fill campaigns): the documented option 'outputFormat' cannot be given at all,
%       even with its only supported value 'mps'; no assertion about the function is made.
%       testMPS.m (testMPS folder) also calls writeLPProblem, together with the MPS paths of
%       solveCobraLP and solveCobraMILP.
%
% Function under test:
%     src/base/io/writeLPProblem.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would write hand-built LP/MILP problems to a
%     temporary folder and read the MPS files back.
%
% Coverage exemptions:
%     every line - writeLPProblem is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: the outputFormat option always fails validation
%       SEVERITY: unusable-option
%       TRIGGER: LP.A = sparse([1 2; 3 4]); LP.b = [5; 6]; LP.c = [1; 1]; LP.lb = [0; 0];
%         LP.ub = [10; 10]; LP.csense = ['G'; 'L']; LP.osense = 1;
%         writeLPProblem(LP, 'outputFormat', 'mps')
%       OBSERVED: (R2025a, 2026-11-15) error "The value of 'outputFormat' is invalid. Not
%         enough input arguments."; the same error for the positional form
%         writeLPProblem(LP, 'p1', 'f1', struct(), 'mps'). The validator on line 84 calls
%         strcmpi(acceptedTypes) with one argument
%       EXPECTED: 'mps' is accepted (OPTIONAL INPUT: "Currently only 'mps' is supported (and
%         default)"), i.e. any(strcmpi(x, acceptedTypes))
%       LINES: 84
%     - DEFECT: writeMatrix given as the first option is taken for a positional problem name
%       SEVERITY: unusable-option
%       TRIGGER: writeLPProblem(LP, 'writeMatrix', false) with LP as above
%       OBSERVED: (R2025a, 2026-11-15) error "The value of 'fileName' is invalid. It must
%         satisfy the function: ischar."; 'writeMatrix' is missing from optionalArgumentList
%         (line 57), so lines 66-75 rewrite the call to problemName = 'writeMatrix',
%         fileName = false
%       EXPECTED: writeMatrix is a documented name-value parameter and is accepted in any
%         position
%       LINES: 57, 66-75
%     - DEFECT: vartype is dropped from the default output
%       SEVERITY: cosmetic
%       TRIGGER: MILP = LP; MILP.vartype = ['I'; 'C']; writeLPProblem(MILP, 'fileName',
%         'milp1.mps') with LP as above
%       OBSERVED: (R2025a, 2026-11-15) the BOUNDS section of milp1.mps reads "UP BND1 X1 10"
%         (continuous); with a non-default solverParams, e.g. 'solverParams', struct('x', 1),
%         the same problem gives "UI BND1 X1 10" (integer). Line 206 calls BuildMPS without
%         the 'Integer' and 'Binary' index lists that lines 186-187 build
%       EXPECTED: the .vartype help saying that the index lists reach the MPS writer only for
%         the full problem (writeMatrix false, line 209, or solverParams given), since the
%         default writeMatrix true writes "only the Matrix, not the full problem" (lines 32-33)
%       LINES: 205-207
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testWriteLPProblem'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
