% The COBRAToolbox: testLiteralNode.m
%
% Purpose:
%     - LiteralNode is the leaf of the tree that represents a gene-protein-reaction rule
%       (GPRLogic, Node classes): it holds the ID of one literal (a gene position as text).
%       This test checks every method of the class: the constructor, evaluate (value of the
%       literal in a containers.Map assignment, with and without printing), getID, toString
%       (x(<id>) in both operator notations), getLiterals, contains, reduce (no change),
%       convertToDNF (an AND node holding a copy of the literal), convertToCNF (an OR node
%       holding a copy) and deleteLiteral (an error by design).
%     - Expected values follow from the documentation of the Node interface (Node.m) and
%       the meaning of a literal in a Boolean formula (hand derivation).
%     - Only the methods defined in LiteralNode.m are tested here; the inherited Node
%       methods belong to the test of Node (one test file per source file).
%
% Function under test:
%     src/reconstruction/refinement/GPRLogic/LiteralNode.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built nodes.
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
fileDir = fileparts(which('testLiteralNode'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% constructor: the literal ID is stored, the node has no children

node = LiteralNode('3');
assert(isa(node, 'LiteralNode') && isa(node, 'Node'));
assert(strcmp(node.id, '3'));
assert(isempty(node.children) && isempty(node.parent));

%% evaluate: the value of the literal in the assignment

assignment = containers.Map({'1', '3'}, {false, true});
assert(node.evaluate(assignment) == true);
assert(LiteralNode('1').evaluate(assignment) == false);
% printLevel 1 prints the literal and its value (one line); the value is unchanged
assert(node.evaluate(assignment, 1) == true);
assert(node.evaluate(assignment, 0) == true);
% a literal that is not in the assignment raises the error of containers.Map
assert(verifyCobraFunctionError('evaluate', 'inputs', {LiteralNode('2'), assignment}));

%% getID, toString, getLiterals

assert(strcmp(node.getID(), '3'));
% the same text with and without the PipeAnd notation: a literal has no operator
assert(strcmp(node.toString(), 'x(3)'));
assert(strcmp(node.toString(0), 'x(3)') && strcmp(node.toString(1), 'x(3)'));
assert(isequal(node.getLiterals(), {'3'}));

%% contains: true only for the ID of the literal

assert(node.contains('3') == true);
assert(node.contains('1') == false);
% the ID is compared as text: '03' is another literal
assert(node.contains('03') == false);

%% reduce: a literal cannot be reduced and is left unchanged

node.reduce();
assert(strcmp(node.id, '3') && isempty(node.children));

%% convertToDNF and convertToCNF: a one-literal clause holding a copy of the literal

dnfNode = node.convertToDNF();
assert(isa(dnfNode, 'AndNode') && numel(dnfNode.children) == 1);
assert(isa(dnfNode.children(1), 'LiteralNode') && strcmp(dnfNode.children(1).id, '3'));
% a copy: a new handle whose parent is the clause, the original is not attached
assert(dnfNode.children(1) ~= node && dnfNode.children(1).parent == dnfNode);
assert(isempty(node.parent));
assert(strcmp(dnfNode.toString(), 'x(3)'));
cnfNode = node.convertToCNF();
assert(isa(cnfNode, 'OrNode') && numel(cnfNode.children) == 1);
assert(isa(cnfNode.children(1), 'LiteralNode') && strcmp(cnfNode.children(1).id, '3'));
assert(cnfNode.children(1) ~= node && cnfNode.children(1).parent == cnfNode);
assert(strcmp(cnfNode.toString(), '(x(3))'));
% the normal forms have the truth value of the literal
assert(dnfNode.evaluate(assignment) == true && cnfNode.evaluate(assignment) == true);

%% deleteLiteral: a literal node cannot delete itself (error by design)

assert(verifyCobraFunctionError('deleteLiteral', 'inputs', {node, '3'}, ...
    'testMessage', 'Cannot delete from a Literal Node.'));
assert(verifyCobraFunctionError('deleteLiteral', 'inputs', {node, '1', true}, ...
    'testMessage', 'Cannot delete from a Literal Node.'));
assert(strcmp(node.id, '3'));

% change the directory
cd(currentDir)
