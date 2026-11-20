% The COBRAToolbox: testGetElementalComposition.m
%
% Purpose:
%     - getElementalComposition(formulae, elements, chargeInFormula) returns the elemental
%       composition matrix (#formulae x #elements) of chemical formulae with generic elements,
%       parentheses, brackets, braces and decimal stoichiometries. This test checks the
%       documented example, char and model input, the element order given by a previous call,
%       nested and multiplied parentheses, empty formulae (NaN rows), the charge pseudo-element,
%       and every error message (invalid input, repeated elements, unrecognised parts, invalid
%       and negative stoichiometries at the top level, in parentheses and in nested parts).
%       Expected values are counted by hand from the formulae.
%
% Function under test:
%     src/reconstruction/modelGeneration/massBalance/getElementalComposition.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built formulae.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Formula numbers in error messages lose their zero padding inside parentheses
%       SEVERITY: cosmetic
%       TRIGGER: getElementalComposition({'H2O'; 'h2o'; 'H2O'; 'H2O'; 'H2O'; 'H2O'; '(cD)'; 'H2O';
%         'H2O'; 'H2O'}) (ten or more formulae, one failing inside or next to a parenthesis)
%       OBSERVED: "#02:  h2o" but "#7:  (cD)" in the same message; the nested function uses
%         the digit count of the recursive call that found the error (line 80 of that call: one
%         formula, one digit)
%       EXPECTED: the same width for every formula number ("#07:  (cD)")
%       LINES: 252
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetElementalComposition'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% all stoichiometries below are integers or halves, which are exact in floating point, so the
% comparisons are exact (isequal)

%% documented example: brackets, a multiplied group, a parenthesis and a generic element

[Ematrix, elements] = getElementalComposition({'H2O'; '[H2O]2(CuSO4)Generic_element0.5'});
% H2O: H 2, O 1; [H2O]2(CuSO4)Generic_element0.5: H 4, O 2 + 4, Cu 1, S 1, Generic_element 0.5
assert(isequal(elements, {'H', 'O', 'Cu', 'S', 'Generic_element'}));
assert(isequal(Ematrix, [2, 1, 0, 0, 0; 4, 6, 1, 1, 0.5]));

%% a char formula, repeated elements and elements without a number

% CH3COOH: C 1 + 1, H 3 + 1, O 1 + 1 (elements counted in order of first appearance)
[Ematrix, elements] = getElementalComposition('CH3COOH');
assert(isequal(elements, {'C', 'H', 'O'}));
assert(isequal(Ematrix, [2, 4, 2]));

%% a COBRA model as input uses its metFormulas; a struct without them is an error

model = struct('metFormulas', {{'C6H12O6'; 'O2'}});
[Ematrix, elements] = getElementalComposition(model);
assert(isequal(elements, {'C', 'H', 'O'}));
assert(isequal(Ematrix, [6, 12, 6; 0, 0, 2]));
assert(verifyCobraFunctionError('getElementalComposition', 'inputs', {struct('mets', {{'a'}})}, ...
    'testMessage', 'The 1st input ''formulae'' should be a cell array of strings of formulae or a COBRA model with *.metFormulas'));

%% the order of elements from a previous call is kept; new elements are appended

% the elements are given as a column, the result is a row
[Ematrix, elements] = getElementalComposition({'H2O'; 'NaCl'}, {'O'; 'C'; 'H'});
assert(isequal(elements, {'O', 'C', 'H', 'Na', 'Cl'}));
assert(isequal(Ematrix, [1, 0, 2, 0, 0; 0, 0, 0, 1, 1]));
% the same element twice in the input order is an error
assert(verifyCobraFunctionError('getElementalComposition', 'inputs', {{'H2O'}, {'H', 'O', 'H'}}, ...
    'testMessage', 'Repeated elements in the input ''elements'' array.'));

%% nested and multiplied parentheses, braces, a group before a parenthesis, and empty formulae

% (H2O): H 2, O 1; ((CH3)2O)3: C 2 * 3, H 6 * 3, O 1 * 3; Na{OH}2: Na 1, O 2, H 2; '()' and ''
% have no atoms and give NaN rows
[Ematrix, elements] = getElementalComposition({'(H2O)'; '((CH3)2O)3'; 'Na{OH}2'; '()'; ''});
assert(isequal(elements, {'H', 'O', 'C', 'Na'}));
assert(isequal(Ematrix(1:3, :), [2, 1, 0, 0; 18, 3, 6, 0; 2, 2, 0, 1]));
assert(all(isnan(Ematrix(4, :))) && all(isnan(Ematrix(5, :))));

%% the charge pseudo-element: negative values only with chargeInFormula = true

% SO4Charge-2: S 1, O 4, Charge -2; HCharge1: H 1, Charge 1. A numeric 1 is accepted as true
[Ematrix, elements] = getElementalComposition({'SO4Charge-2'; 'HCharge1'}, [], 1);
assert(isequal(elements, {'S', 'O', 'Charge', 'H'}));
assert(isequal(Ematrix, [1, 4, -2, 0; 0, 0, 1, 1]));
% an empty chargeInFormula is the default false: a negative charge is then an error
assert(verifyCobraFunctionError('getElementalComposition', 'inputs', {{'SO4Charge-2'}, {}, []}, ...
    'testMessage', sprintf(['Invalid formula input:\n#1:  SO4Charge-2\n' ...
    '    Negative stoichiometry in ''Charge-2'' from the part ''SO4Charge-2''\n'])));

%% error messages: every invalid formula is listed with its number and the part that failed

% #2 'h2o': nothing is recognised at the top level; #3 '(H2O)-2(H2O)-3': two negative group
% stoichiometries in one formula (the formula is listed once); #4 '(H2O).': invalid group
% stoichiometry; #5 'H.': invalid element stoichiometry; #6 'H-2': negative element
% stoichiometry; the other formulae are valid and not listed. Ten formulae give two-digit
% numbers
badFormulae = {'H2O'; 'h2o'; '(H2O)-2(H2O)-3'; '(H2O).'; 'H.'; 'H-2'; 'CO2'; 'O2'; 'N2'; 'H2O'};
unrecognised = ['.\n       Each element should start with a capital letter followed by lower ' ...
    'case letters or ''_'' with indefinite length and followed by a number.\n'];
expectedMessage = sprintf(['Invalid formula input:\n' ...
    '#02:  h2o\n    Only '''' can be recognized from the part ''h2o''' unrecognised ...
    '#03:  (H2O)-2(H2O)-3\n    Negative stoichiometry in ''(H2O)-2''\n' ...
    '    Negative stoichiometry in ''(H2O)-3''\n' ...
    '#04:  (H2O).\n    Invalid stoichiometry in ''(H2O).''\n' ...
    '#05:  H.\n    Invalid stoichiometry in ''H.'' from the part ''H.''\n' ...
    '#06:  H-2\n    Negative stoichiometry in ''H-2'' from the part ''H-2''\n']);
assert(verifyCobraFunctionError('getElementalComposition', 'inputs', {badFormulae}, ...
    'testMessage', expectedMessage));

% parts that fail inside or next to parentheses (fewer than ten formulae, so that the number
% format does not depend on the defect below): #1 '(Ab)2(cD)': unrecognised part inside a
% parenthesis; #2 '((Ab)xY)': unrecognised part next to a parenthesis inside a parenthesis (the
% message shows the enclosing group); #3 '(H2O)x': unrecognised part next to a parenthesis at
% the top level
badFormulae = {'(Ab)2(cD)'; '((Ab)xY)'; '(H2O)x'};
expectedMessage = sprintf(['Invalid formula input:\n' ...
    '#1:  (Ab)2(cD)\n    Only ''D'' can be recognized from the part ''(cD)''' unrecognised ...
    '#2:  ((Ab)xY)\n    Only ''Y'' can be recognized from the part ''((Ab)xY)''' unrecognised ...
    '#3:  (H2O)x\n    Only '''' can be recognized from the part ''x''' unrecognised]);
assert(verifyCobraFunctionError('getElementalComposition', 'inputs', {badFormulae}, ...
    'testMessage', expectedMessage));

%% after an error the next call starts afresh (the persistent state was reset)

[Ematrix, elements] = getElementalComposition({'CO2'});
assert(isequal(elements, {'C', 'O'}) && isequal(Ematrix, [1, 2]));

% change the directory
cd(currentDir)
