% The COBRAToolbox: testAndNode.m
%
% Purpose:
%     - AndNode is the AND node of the tree that represents a gene-protein-reaction rule
%       (GPRLogic, Node classes). This test checks every method of the class: evaluate
%       (with and without printing), toString (both operator notations), convertToCNF,
%       convertToDNF, isValid and nextcombination (the enumeration of the DNF clauses),
%       reduce and deleteLiteral (keeping or removing the AND clauses of the literal).
%     - Expected values are derived independently: the truth table of each result is
%       compared, over every assignment of its literals, with the Boolean function written
%       by hand (an equivalent formula), and the clauses of the normal forms with the clauses
%       obtained by distributing AND over OR by hand. Trees are built by hand from
%       LiteralNode, OrNode and AndNode objects (children set directly where nesting must
%       not be flattened by addChild).
%
% Function under test:
%     src/reconstruction/refinement/GPRLogic/AndNode.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built trees.
%
% Coverage exemptions:
%     Line 131: unreachable. convertToDNF of every Node subclass returns an AndNode
%     (LiteralNode) or an OrNode (AndNode, OrNode), never a LiteralNode, so the branch for a
%     LiteralNode child DNF never runs (dead code).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A numeric literal ID is not deleted
%       SEVERITY: limitation
%       TRIGGER: n = AndNode(); n.addChild(LiteralNode('1')); n.addChild(LiteralNode('2')); n.deleteLiteral(1)
%       OBSERVED: n.toString() is still 'x(1) and x(2)' (no error); LiteralNode.contains
%         compares the number with the text ID with strcmp
%       EXPECTED: 'x(2)', as for n.deleteLiteral('1'); the Node interface documents
%         "literalID: The LiteralID (As string or number)"
%       LINES: 38
%     - DEFECT: convertToDNF of an AndNode without children stops with an error
%       SEVERITY: limitation
%       TRIGGER: AndNode().convertToDNF() (an empty AndNode is also what deleteLiteral(id,
%         false) leaves when the literal is a direct child)
%       OBSERVED: "Index exceeds array bounds." in AndNode.nextcombination (line 189): the
%         empty step vector has no first element
%       EXPECTED: a DNF node (the class does not define the meaning of an empty node)
%       LINES: 125-126, 188-189
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAndNode'));
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

%% evaluate: true only if every child is true; printLevel 1 gives the same result

node = AndNode();
node.children = [L('1'), L('2')];
assert(isequal(nodeTable(node, 2), formulaTable(@(x) x(1) & x(2), 2)));
% nested OR child: x1 and (x2 or x3)
innerOr = OrNode();
innerOr.children = [L('2'), L('3')];
nested = AndNode();
nested.children = [L('1'), innerOr];
assert(isequal(nodeTable(nested, 3), formulaTable(@(x) x(1) & (x(2) | x(3)), 3)));
% printLevel 1 prints each node and its value (a few lines); the value is unchanged
assert(~node.evaluate(containers.Map({'1', '2'}, {true, false}), 1));
assert(node.evaluate(containers.Map({'1', '2'}, {true, true}), 1));

%% toString: ' and ' (default and PipeAnd 0) or ' & ' (PipeAnd 1) between the children

assert(strcmp(nested.toString(), 'x(1) and (x(2) or x(3))'));
assert(strcmp(nested.toString(0), 'x(1) and (x(2) or x(3))'));
assert(strcmp(nested.toString(1), 'x(1) & (x(2) | x(3))'));

%% convertToCNF: x1 and (x2 or (x3 and x4)) = x1 and (x2 or x3) and (x2 or x4)

innerAnd = AndNode();
innerAnd.children = [L('3'), L('4')];
innerOr = OrNode();
innerOr.children = [L('2'), innerAnd];
node = AndNode();
node.children = [L('1'), innerOr];
cnfNode = node.convertToCNF();
assert(isa(cnfNode, 'AndNode'));
% every clause is a literal or an OR of literals
assert(all(arrayfun(@(c) isa(c, 'LiteralNode') || (isa(c, 'OrNode') && ~c.hasNestedChildren()), cnfNode.children)));
assert(isequal(clauseSet(cnfNode), sort({'1'; '2,3'; '2,4'})'));
formula = @(x) x(1) & (x(2) | (x(3) & x(4)));
assert(isequal(nodeTable(cnfNode, 4), formulaTable(formula, 4)));
% the input tree is not changed (literals are copied)
assert(strcmp(node.toString(), 'x(1) and (x(2) or x(3) and x(4))'));

%% convertToDNF: every combination of one clause per child

% (x1 or x2) and (x3 or x4) = x1x3 or x2x3 or x1x4 or x2x4: the enumeration carries over
% from the first to the second child and stops when the last child is exhausted
orA = OrNode();
orA.children = [L('1'), L('2')];
orB = OrNode();
orB.children = [L('3'), L('4')];
node = AndNode();
node.children = [orA, orB];
dnfNode = node.convertToDNF();
assert(isa(dnfNode, 'OrNode') && dnfNode.isDNF());
assert(isequal(clauseSet(dnfNode), sort({'1,3'; '1,4'; '2,3'; '2,4'})'));
assert(isequal(nodeTable(dnfNode, 4), formulaTable(@(x) (x(1) | x(2)) & (x(3) | x(4)), 4)));
% x1 and (x2 or (x3 and x4)) = x1x2 or x1x3x4 (an AND inside an OR child)
node = AndNode();
node.children = [L('1'), innerOr];
dnfNode = node.convertToDNF();
assert(dnfNode.isDNF());
assert(isequal(clauseSet(dnfNode), sort({'1,2'; '1,3,4'})'));
assert(isequal(nodeTable(dnfNode, 4), formulaTable(formula, 4)));
% x1 and x1: the repeated literal is kept once in the single clause
node = AndNode();
node.children = [L('1'), L('1')];
dnfNode = node.convertToDNF();
assert(numel(dnfNode.children) == 1 && numel(dnfNode.children(1).children) == 1);
assert(strcmp(dnfNode.toString(), '(x(1))'));

%% isValid and nextcombination (the clause enumeration used by convertToDNF)

node = AndNode();
% a step is valid while no entry exceeds the size of its child
assert(node.isValid([2 3], [1; 1]) && node.isValid([2 3], [2; 3]));
assert(~node.isValid([2 3], [3; 1]) && ~node.isValid([2 3], [1; 4]));
% the first entry is incremented; an overflow resets it and carries to the next entry; an
% overflow of the last entry is kept (the step is then invalid, which ends the enumeration)
assert(isequal(node.nextcombination([2 3], [1; 1]), [2; 1]));
assert(isequal(node.nextcombination([2 3], [2; 1]), [1; 2]));
assert(isequal(node.nextcombination([2 3], [2; 3]), [1; 4]));

%% reduce: AND children and single-child children are merged into this node

innerAnd = AndNode();
innerAnd.children = [L('2'), L('3')];
singleOr = OrNode();
singleOr.children = L('4');
pairOr = OrNode();
pairOr.children = [L('5'), L('6')];
node = AndNode();
node.children = [L('1'), innerAnd, singleOr, pairOr];
node.reduce();
assert(strcmp(node.toString(), 'x(1) and x(2) and x(3) and x(4) and (x(5) or x(6))'));
assert(isequal(arrayfun(@class, node.children, 'UniformOutput', false), ...
    {'LiteralNode', 'LiteralNode', 'LiteralNode', 'LiteralNode', 'OrNode'}));
% the merged children point to this node as their parent
assert(all(arrayfun(@(c) c.parent == node, node.children)));
% nothing to merge: the children stay as they are
node = AndNode();
node.children = [L('1'), pairOr];
node.reduce();
assert(strcmp(node.toString(), 'x(1) and (x(5) or x(6))'));

%% deleteLiteral, keeping the clauses (default): the literal is removed everywhere

% x1 and x2 and (x1 or x3) and (x4 or x5) without x1 = x2 and x3 and (x4 or x5); the OR left
% with one child is replaced by that child
or13 = OrNode();
or13.children = [L('1'), L('3')];
or45 = OrNode();
or45.children = [L('4'), L('5')];
node = AndNode();
node.children = [L('1'), L('2'), or13, or45];
assert(node.deleteLiteral('1'));
assert(~ismember('1', node.getLiterals()));
assert(isequal(nodeTable(node, 5), formulaTable(@(x) x(2) & x(3) & (x(4) | x(5)), 5)));
assert(isequal(arrayfun(@class, node.children, 'UniformOutput', false), {'LiteralNode', 'OrNode', 'LiteralNode'}));
% the child left with a single non-literal child: x1 and ((x2 and x3) or x4) without x4
innerAnd = AndNode();
innerAnd.children = [L('2'), L('3')];
innerOr = OrNode();
innerOr.children = [innerAnd, L('4')];
node = AndNode();
node.children = [L('1'), innerOr];
assert(node.deleteLiteral('4', true));
assert(isequal(nodeTable(node, 4), formulaTable(@(x) x(1) & x(2) & x(3), 4)));
assert(isa(node.children(end), 'AndNode') && node.children(end).parent == node);
% two children left with a single child: x1 and (x2 or x4) and (x3 or x4) without x4
or24 = OrNode();
or24.children = [L('2'), L('4')];
or34 = OrNode();
or34.children = [L('3'), L('4')];
node = AndNode();
node.children = [L('1'), or24, or34];
node.deleteLiteral('4');
assert(all(arrayfun(@(c) isa(c, 'LiteralNode'), node.children)));
assert(isequal(sort(node.getLiterals()), {'1', '2', '3'}));

%% deleteLiteral, removing the clauses (keepClauses false)

% the literal is a direct child: the AND clause is removed, i.e. the node is emptied
node = AndNode();
node.children = [L('1'), L('2')];
assert(node.deleteLiteral('1', false));
assert(isempty(node.children));
% the literal is deeper: x2 and (x1 or x3 or (x1 and x4)) without x1 = x2 and x3 (the AND
% clause with x1 is removed, the OR left with x3 is replaced by x3)
inner14 = AndNode();
inner14.children = [L('1'), L('4')];
innerOr = OrNode();
innerOr.children = [L('1'), L('3'), inner14];
node = AndNode();
node.children = [L('2'), innerOr];
node.deleteLiteral('1', false);
assert(isequal(sort(node.getLiterals()), {'2', '3'}));
assert(isequal(nodeTable(node, 4), formulaTable(@(x) x(2) & x(3), 4)));

% change the directory
cd(currentDir)
