% The COBRAToolbox: testOrNode.m
%
% Purpose:
%     - OrNode is the OR node of the tree that represents a gene-protein-reaction rule
%       (GPRLogic, Node classes). This test checks every method of the class: evaluate
%       (with and without printing), toString (both operator notations and the empty node),
%       convertToCNF, convertToDNF, removeDNFduplicates, reduce and deleteLiteral (keeping or
%       removing the AND clauses of the literal).
%     - Expected values are derived independently: the truth table of each result is
%       compared, over every assignment of its literals, with the Boolean function written
%       by hand (an equivalent formula), and the clauses of the normal forms with the clauses
%       obtained by distributing OR over AND by hand. Trees are built by hand from
%       LiteralNode, AndNode and OrNode objects (children set directly where nesting must not
%       be flattened by addChild).
%
% Function under test:
%     src/reconstruction/refinement/GPRLogic/OrNode.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built trees.
%
% Coverage exemptions:
%     Line 66: unreachable. The clauses of the DNF come from convertToDNF of the children,
%     which already keep each literal once per clause (LiteralNode gives one literal, AndNode
%     and OrNode remove the repeated literals of their clauses), so no repeated literal is
%     ever found here (dead code).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A numeric literal ID is not deleted
%       SEVERITY: limitation
%       TRIGGER: n = OrNode(); n.addChild(LiteralNode('1')); n.addChild(LiteralNode('2')); n.deleteLiteral(1)
%       OBSERVED: n.toString() is still '(x(1) or x(2))' (no error); LiteralNode.contains
%         compares the number with the text ID with strcmp
%       EXPECTED: '(x(2))', as for n.deleteLiteral('1'); the Node interface documents
%         "literalID: The LiteralID (As string or number)"
%       LINES: 138
%     - DEFECT: convertToCNF of an OrNode without children returns an empty AndNode, which
%       evaluates to true, while the empty OrNode evaluates to false
%       SEVERITY: limitation
%       TRIGGER: n = OrNode(); n.evaluate(containers.Map()), n.convertToCNF().evaluate(containers.Map())
%         (an empty OrNode is also what deleteLiteral leaves when every child is removed)
%       OBSERVED: false, and true (an AndNode with 0 children)
%       EXPECTED: an equivalent CNF (the class does not define the meaning of an empty node)
%       LINES: 31-39
%
% Note: convertToCNF uses combineChildren, which has a recorded wrong-result defect for
%     identical generated clauses (see testCombineChildren.m); the inputs below do not
%     produce identical clauses.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOrNode'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% truth tables: assignment k (0 .. 2^n - 1) gives literal i the value of bit i of k; a node
% is evaluated with containers.Map('1' .. 'n' -> logical), a hand-written formula with the
% logical vector x
assignmentFor = @(bits) containers.Map(arrayfun(@num2str, 1:numel(bits), 'UniformOutput', false), ...
    num2cell(logical(bits)));
nodeTable = @(node, n) arrayfun(@(k) node.evaluate(assignmentFor(bitget(k, 1:n))), 0:2^n - 1);
formulaTable = @(formula, n) arrayfun(@(k) formula(logical(bitget(k, 1:n))), 0:2^n - 1);
% the clauses of a normal form: the sorted literal IDs of each child, as sorted text
clauseSet = @(node) sort(arrayfun(@(child) strjoin(sort(child.getLiterals()), ','), node.children, ...
    'UniformOutput', false));
L = @(id) LiteralNode(id);

%% evaluate: true as soon as one child is true; printLevel 1 gives the same result

node = OrNode();
node.children = [L('1'), L('2')];
assert(isequal(nodeTable(node, 2), formulaTable(@(x) x(1) | x(2), 2)));
% nested AND child: x1 or (x2 and x3)
innerAnd = AndNode();
innerAnd.children = [L('2'), L('3')];
nested = OrNode();
nested.children = [L('1'), innerAnd];
assert(isequal(nodeTable(nested, 3), formulaTable(@(x) x(1) | (x(2) & x(3)), 3)));
% printLevel 1 prints each evaluated node and its value (a few lines); the value is unchanged
assert(node.evaluate(containers.Map({'1', '2'}, {false, true}), 1));
assert(~node.evaluate(containers.Map({'1', '2'}, {false, false}), 1));

%% toString: '(' children separated by ' or ' (default, PipeAnd 0) or ' | ' (PipeAnd 1) ')'

assert(strcmp(nested.toString(), '(x(1) or x(2) and x(3))'));
assert(strcmp(nested.toString(0), '(x(1) or x(2) and x(3))'));
assert(strcmp(nested.toString(1), '(x(1) | x(2) & x(3))'));
% a node without children gives an empty text (no parentheses)
assert(isempty(OrNode().toString()));

%% convertToCNF: (x1 and x2) or x3 = (x1 or x3) and (x2 or x3)

innerAnd = AndNode();
innerAnd.children = [L('1'), L('2')];
node = OrNode();
node.children = [innerAnd, L('3')];
cnfNode = node.convertToCNF();
assert(isa(cnfNode, 'AndNode'));
% every clause is an OR of literals
assert(all(arrayfun(@(c) isa(c, 'OrNode') && ~c.hasNestedChildren(), cnfNode.children)));
assert(isequal(clauseSet(cnfNode), {'1,3', '2,3'}));
assert(isequal(nodeTable(cnfNode, 3), formulaTable(@(x) (x(1) & x(2)) | x(3), 3)));
% the input tree is not changed (literals are copied)
assert(strcmp(node.toString(), '(x(1) and x(2) or x(3))'));
% x1 or x2: a single clause
node = OrNode();
node.children = [L('1'), L('2')];
cnfNode = node.convertToCNF();
assert(isequal(clauseSet(cnfNode), {'1,2'}));

%% convertToDNF: OR children are merged into this node, other children converted

% x1 or (x2 or x3) or (x4 and (x5 or x6)) = x1 or x2 or x3 or x4x5 or x4x6
innerOr = OrNode();
innerOr.children = [L('2'), L('3')];
or56 = OrNode();
or56.children = [L('5'), L('6')];
innerAnd = AndNode();
innerAnd.children = [L('4'), or56];
node = OrNode();
node.children = [L('1'), innerOr, innerAnd];
dnfNode = node.convertToDNF();
assert(isa(dnfNode, 'OrNode') && dnfNode.isDNF());
assert(isequal(clauseSet(dnfNode), sort({'1'; '2'; '3'; '4,5'; '4,6'})'));
formula = @(x) x(1) | x(2) | x(3) | (x(4) & (x(5) | x(6)));
assert(isequal(nodeTable(dnfNode, 6), formulaTable(formula, 6)));

%% removeDNFduplicates: clauses with the same set of literals are kept once

% (x1 and x2) or (x2 and x1) or x3 or (x3): two different clauses remain
and12 = AndNode();
and12.children = [L('1'), L('2')];
and21 = AndNode();
and21.children = [L('2'), L('1')];
and3 = AndNode();
and3.children = L('3');
node = OrNode();
node.children = [and12, and21, L('3'), and3];
node.removeDNFduplicates();
assert(numel(node.children) == 2);
assert(isequal(clauseSet(node), {'1,2', '3'}));
assert(isequal(nodeTable(node, 3), formulaTable(@(x) (x(1) & x(2)) | x(3), 3)));

%% reduce: OR children and single-child children are merged into this node

innerOr = OrNode();
innerOr.children = [L('2'), L('3')];
singleAnd = AndNode();
singleAnd.children = L('4');
pairAnd = AndNode();
pairAnd.children = [L('5'), L('6')];
node = OrNode();
node.children = [L('1'), innerOr, singleAnd, pairAnd];
node.reduce();
assert(strcmp(node.toString(), '(x(1) or x(2) or x(3) or x(4) or x(5) and x(6))'));
assert(isequal(arrayfun(@class, node.children, 'UniformOutput', false), ...
    {'LiteralNode', 'LiteralNode', 'LiteralNode', 'LiteralNode', 'AndNode'}));
% the merged children point to this node as their parent
assert(all(arrayfun(@(c) c.parent == node, node.children)));
% nothing to merge: the children stay as they are
node = OrNode();
node.children = [L('1'), pairAnd];
node.reduce();
assert(strcmp(node.toString(), '(x(1) or x(5) and x(6))'));

%% deleteLiteral, keeping the clauses (default): the literal is removed everywhere

% x1 or x2 or (x1 and x3) or (x4 and x5) without x1 = x2 or x3 or (x4 and x5); the AND left
% with one child is replaced by that child
and13 = AndNode();
and13.children = [L('1'), L('3')];
and45 = AndNode();
and45.children = [L('4'), L('5')];
node = OrNode();
node.children = [L('1'), L('2'), and13, and45];
assert(node.deleteLiteral('1'));
assert(~ismember('1', node.getLiterals()));
assert(isequal(nodeTable(node, 5), formulaTable(@(x) x(2) | x(3) | (x(4) & x(5)), 5)));
assert(isequal(arrayfun(@class, node.children, 'UniformOutput', false), {'LiteralNode', 'AndNode', 'LiteralNode'}));
assert(node.children(end).parent == node);
% two clauses left with a single literal: (x1 and x2) or (x1 and x3) without x1 = x2 or x3
and12 = AndNode();
and12.children = [L('1'), L('2')];
and13 = AndNode();
and13.children = [L('1'), L('3')];
node = OrNode();
node.children = [and12, and13];
node.deleteLiteral('1', true);
assert(all(arrayfun(@(c) isa(c, 'LiteralNode'), node.children)));
assert(isequal(nodeTable(node, 3), formulaTable(@(x) x(2) | x(3), 3)));

%% deleteLiteral, removing the clauses (keepClauses false)

% x2 or (x1 and x3) without x1 = x2: the AND clause with x1 is removed
and13 = AndNode();
and13.children = [L('1'), L('3')];
node = OrNode();
node.children = [L('2'), and13];
assert(node.deleteLiteral('1', false));
assert(isequal(node.getLiterals(), {'2'}));
assert(isequal(nodeTable(node, 3), formulaTable(@(x) x(2), 3)));

% change the directory
cd(currentDir)
