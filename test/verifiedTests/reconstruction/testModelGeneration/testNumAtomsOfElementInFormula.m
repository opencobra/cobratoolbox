% The COBRAToolbox: testNumAtomsOfElementInFormula.m
%
% Purpose:
%     - numAtomsOfElementInFormula(formula, element, printLevel) returns the number of atoms of
%       one element in a chemical formula written as element symbols followed by their counts.
%       This test checks plain formulae, elements sharing a first letter (C and Co), elements
%       repeated in composite formulae joined by dots, elements without a count, R groups and
%       the FULLR/FULLR2/FULLR3 names of the human reconstruction, a formula that starts with a
%       number (warning), the documented replacement of a letter followed by a single zero, and
%       the input errors. Expected counts are obtained by reading the formulae by hand.
%
% Function under test:
%     src/reconstruction/modelGeneration/massBalance/numAtomsOfElementInFormula.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Zero counts are replaced only when the formula holds a single zero
%       SEVERITY: limitation
%       TRIGGER: numAtomsOfElementInFormula('C10H0', 'H', 0); numAtomsOfElementInFormula('H0O0', 'O', 0)
%       OBSERVED: 'C10H0' returns 0 without the replacement (while 'CH0' is replaced by 'CH' and
%       returns 1); 'H0O0' stops with the error "Colon operands must be real scalars." (line 51)
%       EXPECTED: every letter followed by a zero treated as for 'CH0', without an error
%       LINES: 47-53
%     - DEFECT: A formula given as a cell or number stops with a MATLAB error, not the class error
%       SEVERITY: cosmetic
%       TRIGGER: numAtomsOfElementInFormula({'C2'}, 'C')
%       OBSERVED: a warning (line 41), then "Invalid data type. Argument must be numeric, char,
%       or logical." from line 48
%       EXPECTED: "Formula must be given by a variable of class char" (line 126)
%       LINES: 46-48
%     - DEFECT: Output is printed at printLevel 0
%       SEVERITY: cosmetic
%       TRIGGER: numAtomsOfElementInFormula('2H2O', 'H', 0); numAtomsOfElementInFormula('CH0', 'H', 0)
%       OBSERVED: the formula is displayed (line 39), and "Formula before:" / "Formula after:"
%       lines are printed (lines 49, 52), whatever printLevel is
%       EXPECTED: no output at printLevel 0
%       LINES: 39, 49, 52
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testNumAtomsOfElementInFormula'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% counts are integers, so every comparison below is exact

%% plain formula: glucose C6H12O6, and an element that is not in the formula

assert(numAtomsOfElementInFormula('C6H12O6', 'C') == 6);
assert(numAtomsOfElementInFormula('C6H12O6', 'H', 0) == 12);
assert(numAtomsOfElementInFormula('C6H12O6', 'O', 0) == 6);
assert(numAtomsOfElementInFormula('C6H12O6', 'N', 0) == 0);

%% elements with the same first letter, and an element without a count (count 1)

% cobalamin core 'C55H80CoN15O11': C is not confused with Co
formula = 'C55H80CoN15O11';
assert(numAtomsOfElementInFormula(formula, 'C', 0) == 55);
assert(numAtomsOfElementInFormula(formula, 'Co', 0) == 1);
assert(numAtomsOfElementInFormula(formula, 'N', 0) == 15);
% methanol: the final O has no count
assert(numAtomsOfElementInFormula('CH4O', 'O', 0) == 1);
assert(numAtomsOfElementInFormula('CH4O', 'C', 0) == 1);

%% composite formula joined by dots: counts of repeated elements are added

% 'C62H90N13O14P.C10H11N5O3.Co': C 62 + 10, O 14 + 3, N 13 + 5; 'P.' and '.Co' have no count
formula = 'C62H90N13O14P.C10H11N5O3.Co';
assert(numAtomsOfElementInFormula(formula, 'C', 0) == 72);
assert(numAtomsOfElementInFormula(formula, 'O', 0) == 17);
assert(numAtomsOfElementInFormula(formula, 'N', 0) == 18);
assert(numAtomsOfElementInFormula(formula, 'P', 0) == 1);
assert(numAtomsOfElementInFormula(formula, 'Co', 0) == 1);

%% R groups and the FULLR names of the human reconstruction

% 'C5H8O4FULLR2FULLR' reads 'C5H8O4R2R': two R plus one R
assert(numAtomsOfElementInFormula('C5H8O4FULLR2FULLR', 'R', 0) == 3);
assert(numAtomsOfElementInFormula('C5H8O4FULLR2FULLR', 'FULLR', 0) == 3);
% 'CFULLR3' reads 'CR3'
assert(numAtomsOfElementInFormula('CFULLR3', 'R', 0) == 3);
assert(numAtomsOfElementInFormula('C2H4O2R', 'R', 0) == 1);

%% a formula that starts with a number: a warning at printLevel > 0, the leading number is ignored

lastwarn('');
assert(numAtomsOfElementInFormula('2H2O', 'H') == 2);
assert(strcmp(lastwarn, 'Formula format expected is element then number of elements, not the other way around'));
% no warning at printLevel 0
lastwarn('');
assert(numAtomsOfElementInFormula('2H2O', 'O', 0) == 1);
assert(isempty(lastwarn));

%% a letter followed by a single zero: replaced by the letter, with a warning

% documented by the warning text: 'CH0' is read as 'CH'
lastwarn('');
assert(numAtomsOfElementInFormula('CH0', 'H', 0) == 1);
assert(strcmp(lastwarn, 'Formula contains a zero with a letter preceeding it, replacing with letter.'));
% a zero that follows a digit is part of the count
assert(numAtomsOfElementInFormula('C10H22', 'C', 0) == 10);

%% input errors: numbers or a lower-case single letter in the element, non-char arguments

assert(verifyCobraFunctionError('numAtomsOfElementInFormula', 'inputs', {'C6H12O6', 'C2', 0}, ...
    'testMessage', 'Element must not contain numbers'));
assert(verifyCobraFunctionError('numAtomsOfElementInFormula', 'inputs', {'C6H12O6', 'c', 0}, ...
    'testMessage', 'Single letter element must not be lower case'));
% a string element passes the letter checks and is caught by the class check
assert(verifyCobraFunctionError('numAtomsOfElementInFormula', 'inputs', {'C6H12O6', "C", 0}, ...
    'testMessage', 'Element must be given by a variable of class char'));
assert(verifyCobraFunctionError('numAtomsOfElementInFormula', 'inputs', {"C6H12O6", 'C', 0}, ...
    'testMessage', 'Formula must be given by a variable of class char'));

% restore the directory
cd(currentDir)
