% The COBRAToolbox: testBalancecheck.m
%
% Purpose:
%     - balancecheck adds up, for the elements C, H, O, P, S, N, Mg, X, Fe, Zn, Co and R, the
%       atoms of the substrates and of the products of one rBioNet reaction (rows of
%       meta_meta: abbreviation, description, coefficient, compartment, side 'Substrate' or
%       anything else for a product, charged formula; atoms counted with
%       numAtomsOfElementInFormula and multiplied by the coefficient). With output 0 (the
%       default) it returns [] for a balanced reaction and the 3 x 12 cell {elements; substrate
%       atoms; product atoms} otherwise; with output 1 it always returns that cell; any other
%       output value raises 'wrong input'. Expected atom counts are added up by hand from the
%       formulae in the comments.
%
% Function under test:
%     src/reconstruction/rBioNet/balancecheck.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built rBioNet reaction rows.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Elements outside the fixed list of twelve are not checked
%       SEVERITY: limitation
%       TRIGGER: a reaction unbalanced only in an element that is not in the list C, H, O, P,
%         S, N, Mg, X, Fe, Zn, Co, R, for example balancecheck({'na1', 'Sodium', 1, 'c',
%         'Substrate', 'Na'; 'h2o', 'Water', 1, 'c', 'Substrate', 'H2O'; 'h2o', 'Water', 1,
%         'c', 'Product', 'H2O'}) (sodium consumed, nothing produced from it)
%       OBSERVED: [] (balanced), since Na, K, Cl, Ca, Cu, Mn, Se, I and every other element
%         is never counted (R2025a, 2026-11-15)
%       EXPECTED: the reaction reported as unbalanced, or the documentation naming the
%         elements that are checked
%       LINES: 26
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testBalancecheck'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% element order of the output
elements = {'C', 'H', 'O', 'P', 'S', 'N', 'Mg', 'X', 'Fe', 'Zn', 'Co', 'R'};

% hexokinase: glc-D + atp -> g6p + adp + h
%   substrates C6H12O6 + C10H12N5O13P3 = C16 H24 O19 P3 N5
%   products   C6H11O9P + C10H12N5O10P2 + H = C16 H24 O19 P3 N5
hexokinase = {
    'glc-D', 'D-Glucose', 1, 'Cytoplasm (c)', 'Substrate', 'C6H12O6'
    'atp', 'ATP', 1, 'Cytoplasm (c)', 'Substrate', 'C10H12N5O13P3'
    'g6p', 'D-Glucose 6-phosphate', 1, 'Cytoplasm (c)', 'Product', 'C6H11O9P'
    'adp', 'ADP', 1, 'Cytoplasm (c)', 'Product', 'C10H12N5O10P2'
    'h', 'Proton', 1, 'Cytoplasm (c)', 'Product', 'H'};
balancedAtoms = num2cell([16 24 19 3 0 5 0 0 0 0 0 0]);

%% a balanced reaction gives [] by default and with output 0

assert(isequal(balancecheck(hexokinase), []));
assert(isequal(balancecheck(hexokinase, 0), []));

%% output 1 always returns the elements and the atoms of both sides

% atom counts are integers, so they are compared exactly
assert(isequal(balancecheck(hexokinase, 1), [elements; balancedAtoms; balancedAtoms]));

%% an unbalanced reaction returns the elements and the atoms of both sides

% without the proton the products hold one H less: C16 H23 O19 P3 N5
withoutProton = hexokinase(1:4, :);
expected = [elements; balancedAtoms; num2cell([16 23 19 3 0 5 0 0 0 0 0 0])];
assert(isequal(balancecheck(withoutProton), expected));
assert(isequal(balancecheck(withoutProton, 1), expected));

%% coefficients multiply the atoms; any side other than 'Substrate' is a product

% 2 h2o -> 2 h2 + o2: substrates 2 x H2O = H4 O2, products 2 x H2 + O2 = H4 O2; the side of
% the last row is not 'Product' and is counted with the products
waterSplitting = {
    'h2o', 'Water', 2, 'c', 'Substrate', 'H2O'
    'h2', 'Hydrogen', 2, 'c', 'Product', 'H2'
    'o2', 'Oxygen', 1, 'c', 'right side', 'O2'};
assert(isequal(balancecheck(waterSplitting), []));
atoms = num2cell([0 4 2 0 0 0 0 0 0 0 0 0]);
assert(isequal(balancecheck(waterSplitting, 1), [elements; atoms; atoms]));
% with the oxygen as a substrate the reaction is unbalanced: substrates H4 O4, products H4
waterSplitting{3, 5} = 'Substrate';
expected = [elements; num2cell([0 4 4 0 0 0 0 0 0 0 0 0]); num2cell([0 4 0 0 0 0 0 0 0 0 0 0])];
assert(isequal(balancecheck(waterSplitting), expected));

%% every listed element is counted, and an element is not confused with a longer symbol

% substrate C2 H3 O P S N Mg X Fe Zn Co R, product with Cl and Ca (not in the list, so not
% counted) and Co2: the C of Cl and Ca and the Co are not counted as C
allElements = {
    'all', 'All elements', 1, 'c', 'Substrate', 'C2H3OPSNMgXFeZnCoR'
    'rest', 'Rest', 1, 'c', 'Product', 'ClCaCo2'};
expected = [elements; num2cell([2 3 1 1 1 1 1 1 1 1 1 1]); num2cell([0 0 0 0 0 0 0 0 0 0 2 0])];
assert(isequal(balancecheck(allElements), expected));

%% an empty reaction is balanced

% no row: both sides hold no atom
assert(isequal(balancecheck(cell(0, 6)), []));

%% any output other than 0 or 1 is rejected

assert(verifyCobraFunctionError('balancecheck', 'inputs', {hexokinase, 2}, ...
    'outputArgCount', 1, 'testMessage', 'wrong input'));

% change the directory
cd(currentDir)
