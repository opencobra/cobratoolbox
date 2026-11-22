% The COBRAToolbox: testBalancePrep.m
%
% Purpose:
%     - BalancePrep turns the metabolite rows of one rBioNet reaction (meta_meta, as built by
%       LoadReaction: abbreviation, description, coefficient, compartment 'Name (x)', side
%       'Substrate' or 'Product', charged formula, charge as text) into the two sides of the
%       reaction formula ('2 met[x] + met2[x]', no coefficient written when it is 1) and the
%       total charge of each side (charge times coefficient). It returns
%       {leftside, rightside, charge_l, charge_r}; [] for an empty input; and [] with a
%       message box for a metabolite without charged formula or a side that is neither
%       'Substrate' nor 'Product'. The test checks each case against the formula and charges
%       written by hand, and closes the message boxes after reading their text.
%
% Function under test:
%     src/reconstruction/rBioNet/BalancePrep.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built rBioNet reaction rows. Two cases open a message
%     box, which the test closes.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testBalancePrep'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% arginase as LoadReaction returns it for the rBioNet test database of this folder:
% arg-L[c] + h2o[c] -> orn[c] + urea[c], charges 1, 0, 1, 0
arginase = {
    'arg-L', 'L-Arginine', 1, 'Cytoplasm  (c)', 'Substrate', 'C6H15N4O2', '1'
    'h2o', 'water', 1, 'Cytoplasm  (c)', 'Substrate', 'H2O', '0'
    'orn', 'Ornithine', 1, 'Cytoplasm  (c)', 'Product', 'C5H13N2O2', '1'
    'urea', 'Urea', 1, 'Cytoplasm  (c)', 'Product', 'CH4N2O', '0'};

%% an empty input gives an empty output

assert(isempty(BalancePrep({})));
assert(isempty(BalancePrep(cell(0, 7))));

%% the two sides of the formula and their charges

% charges are integers, so they are compared exactly
assert(isequal(BalancePrep(arginase), {'arg-L[c] + h2o[c]', 'orn[c] + urea[c]', 1, 1}));

%% coefficients other than 1 are written before the metabolite and multiply the charge

% 2 h[e] + 0.5 o2[m] -> h2o[c] with charges 1, 0 and 0: left 2 * 1 + 0.5 * 0 = 2, right 0;
% the compartment letter is the character after '(' of the compartment name
transport = {
    'h', 'Proton', 2, 'Extracellular space (e)', 'Substrate', 'H', '1'
    'o2', 'Oxygen', 0.5, 'Mitochondrion (m)', 'Substrate', 'O2', '0'
    'h2o', 'Water', 1, 'Cytoplasm  (c)', 'Product', 'H2O', '0'};
assert(isequal(BalancePrep(transport), {'2 h[e] + 0.5 o2[m]', 'h2o[c]', 2, 0}));

% a negative charge is multiplied as well: 3 pi[c] (charge -2) -> nothing; the right side is
% empty and its charge is the sum of no charge, 0
phosphate = {'pi', 'Phosphate', 3, 'Cytoplasm  (c)', 'Substrate', 'HO4P', '-2'};
assert(isequal(BalancePrep(phosphate), {'3 pi[c]', [], -6, 0}));

%% a metabolite without charged formula: [] and a warning box

missingFormula = arginase;
missingFormula{3, 6} = '';
assert(isempty(BalancePrep(missingFormula)));
boxText = closeMessageBoxes();
assert(contains(boxText, 'missing the charged formula.') && contains(boxText, 'orn'));

%% a side that is neither 'Substrate' nor 'Product': [] and an error box

wrongSide = arginase;
wrongSide{4, 5} = 'Both';
assert(isempty(BalancePrep(wrongSide)));
assert(contains(closeMessageBoxes(), 'Something is wrong with Substrate and Product.'));

% change the directory
cd(currentDir)

function boxText = closeMessageBoxes()
% Returns the text of the open message boxes and closes them, so that no window stays open.
boxes = findall(0, 'Type', 'figure', '-regexp', 'Tag', '^Msgbox_');
boxText = '';
for iBox = 1:numel(boxes)
    boxLines = cellstr(get(findall(boxes(iBox), 'Type', 'text'), 'String'));
    boxText = [boxText, ' ', strjoin(strtrim(boxLines), ' ')];
end
delete(boxes);
end
