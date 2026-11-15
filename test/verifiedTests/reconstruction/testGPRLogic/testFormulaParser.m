% The COBRAToolbox: testFormulaParser.m
%
% Purpose:
%     - FormulaParser turns a GPR rule of the COBRA rules field (literals x(1), x(2), ...,
%       operators | and &, or the words and / or of grRules, with brackets) into a tree of
%       OrNode, AndNode and LiteralNode objects. This test parses rules with each operator,
%       mixed operators without brackets (AND binds tighter than OR), nested and redundant
%       brackets, the words and/or in any case, operators without spaces and gene names as
%       literals, and checks the class of the head node, its text form, its literals and its
%       Boolean function.
%     - Expected values are derived independently: the truth table of each tree (evaluate
%       over every assignment of its literals) is compared with the Boolean formula written
%       by hand; the text forms (toString with | and &) are the tree shapes worked out by
%       hand from the parsing rules (innermost brackets first, OR split before AND, every
%       literal not inside an AND wrapped in its own OR node). Node.isequal and
%       Node.removeDuplicateLiterals are not used (Node is quarantined for them).
%
% Function under test:
%     src/reconstruction/refinement/GPRLogic/FormulaParser.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-written rules.
%
% Coverage exemptions:
%     Lines 143-153, 155, 158-159, 161, 169-173, 175: no input of parseFormula reaches them
%     (defective input skipped, see the second defect below). createNodeStructure (a public
%     method that its header calls a "Private Function") reaches them only for a text that is not
%     a stored sub-formula and contains ' | ' or ' & ' with spaces; parseFormula always
%     passes a stored key first, and every recursive call passes a literal from which line
%     104, 110, 124 or 132 has removed all whitespace (and line 95, 101 or 121 every | and &).
%     (Line 172 would also fail there: andliterals is not defined in that branch.)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: An empty rule stops with an error
%       SEVERITY: limitation
%       TRIGGER: fp = FormulaParser(); fp.parseFormula('')
%       OBSERVED: error "Unrecognized function or variable 'finalid'."
%         (FormulaParser.parseFormula:84); no sub-formula is stored for an empty text
%       EXPECTED: an empty tree (or a documented error); the callers in the toolbox skip
%         empty rules before calling parseFormula
%       LINES: 84
%     - DEFECT: createNodeStructure fails for a text with spaced operators that is not a stored key
%       SEVERITY: limitation
%       TRIGGER: fp = FormulaParser(); fp.createNodeStructure('1 | 2 & 3') (a direct call of the
%         method its header marks as a private function)
%       OBSERVED: the branch of lines 143-175 is the only way in, and line 172 reads andliterals,
%         which that branch never defines
%       EXPECTED: the node tree of the text, as for the stored sub-formulas
%       LINES: 143-175
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFormulaParser'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% truth tables: assignment k (0 .. 2^n - 1) gives literal i the value of bit i of k; a tree
% is evaluated with containers.Map(literal IDs -> logical), a hand-written formula with
% the logical vector x (x(i) is the value of the i-th ID)
assignmentFor = @(ids, bits) containers.Map(ids, num2cell(logical(bits)));
nodeTable = @(node, ids) arrayfun(@(k) node.evaluate(assignmentFor(ids, bitget(k, 1:numel(ids)))), ...
    0:2^numel(ids) - 1);
formulaTable = @(formula, n) arrayfun(@(k) formula(logical(bitget(k, 1:n))), 0:2^n - 1);
numberedIds = @(n) arrayfun(@num2str, 1:n, 'UniformOutput', false);

% one parser is used for every rule: the sub-formulas stored by a previous rule must not
% change the next result
parser = FormulaParser();
assert(isa(parser, 'FormulaParser') && isa(parser.subformulas, 'containers.Map'));
assert(parser.subformulas.Count == 0);

%% a single literal: an OR node with one literal child

head = parser.parseFormula('x(1)');
assert(isa(head, 'OrNode') && numel(head.children) == 1 && isa(head.children(1), 'LiteralNode'));
assert(strcmp(head.toString(1), '(x(1))'));
assert(isequal(head.getLiterals(), {'1'}));
assert(isequal(nodeTable(head, numberedIds(1)), [false true]));
% redundant brackets around a literal give the same tree
head = parser.parseFormula('(x(1))');
assert(isa(head, 'OrNode') && strcmp(head.toString(1), '(x(1))'));

%% only OR, only AND

head = parser.parseFormula('x(1) | x(2)');
assert(isa(head, 'OrNode') && strcmp(head.toString(1), '(x(1) | x(2))'));
assert(isequal(sort(head.getLiterals()), {'1', '2'}));
assert(isequal(nodeTable(head, numberedIds(2)), formulaTable(@(x) x(1) | x(2), 2)));
% an AND head node; each literal is wrapped in its own OR node
head = parser.parseFormula('x(1) & x(2)');
assert(isa(head, 'AndNode') && strcmp(head.toString(1), '(x(1)) & (x(2))'));
assert(isequal(nodeTable(head, numberedIds(2)), formulaTable(@(x) x(1) & x(2), 2)));

%% mixed operators without brackets: AND binds tighter than OR

head = parser.parseFormula('x(1)|x(2)&x(3)');
assert(isa(head, 'OrNode') && strcmp(head.toString(1), '((x(1)) | (x(2)) & (x(3)))'));
assert(isequal(nodeTable(head, numberedIds(3)), formulaTable(@(x) x(1) | (x(2) & x(3)), 3)));
% the words and / or (grRules notation) are read as & and |
head = parser.parseFormula('x(1) and x(2) or x(3)');
assert(isa(head, 'OrNode') && strcmp(head.toString(1), '((x(1)) & (x(2)) | (x(3)))'));
assert(isequal(nodeTable(head, numberedIds(3)), formulaTable(@(x) (x(1) & x(2)) | x(3), 3)));

%% brackets: inner groups are parsed first

head = parser.parseFormula('(x(1) & x(2)) | x(3)');
assert(isa(head, 'OrNode') && strcmp(head.toString(1), '((x(1)) & (x(2)) | x(3))'));
assert(isequal(nodeTable(head, numberedIds(3)), formulaTable(@(x) (x(1) & x(2)) | x(3), 3)));
head = parser.parseFormula('(x(1) | x(2)) & (x(3) | x(4))');
assert(isa(head, 'AndNode') && strcmp(head.toString(1), '(x(1) | x(2)) & (x(3) | x(4))'));
assert(isequal(sort(head.getLiterals()), {'1', '2', '3', '4'}));
assert(isequal(nodeTable(head, numberedIds(4)), formulaTable(@(x) (x(1) | x(2)) & (x(3) | x(4)), 4)));
% two levels of brackets
head = parser.parseFormula('((x(1) | x(2)) & x(3)) | x(4)');
assert(isa(head, 'OrNode') && strcmp(head.toString(1), '((x(1) | x(2)) & (x(3)) | x(4))'));
assert(isequal(nodeTable(head, numberedIds(4)), formulaTable(@(x) ((x(1) | x(2)) & x(3)) | x(4), 4)));
% upper-case words with brackets
head = parser.parseFormula('(x(1) OR x(2)) AND x(3)');
assert(isa(head, 'AndNode') && strcmp(head.toString(1), '(x(1) | x(2)) & (x(3))'));
assert(isequal(nodeTable(head, numberedIds(3)), formulaTable(@(x) (x(1) | x(2)) & x(3), 3)));

%% gene names as literals (grRules text): the names become the literal IDs

head = parser.parseFormula('(geneA and geneB) or geneC');
assert(isa(head, 'OrNode'));
geneIds = {'geneA', 'geneB', 'geneC'};
assert(isequal(sort(head.getLiterals()), geneIds));
assert(isequal(nodeTable(head, geneIds), formulaTable(@(x) (x(1) & x(2)) | x(3), 3)));

% change the directory
cd(currentDir)
