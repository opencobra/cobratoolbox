% The COBRAToolbox: testNode.m
%
% Purpose:
%     - Node is the abstract base class of the nodes (AndNode, OrNode, LiteralNode) of the
%       tree that represents a gene-protein-reaction rule (GPRLogic). It defines the
%       constructor and the methods copy, getID, addChild, contains, getLiterals,
%       removeDuplicateLiterals, hasNestedChildren, isDNF, getFunctionalGeneSets,
%       deleteLiterals and isequal. The class is QUARANTINED (Constitution III-Defects,
%       quarantine in back-fill campaigns): removeDuplicateLiterals removes literals that
%       are not duplicates, and isequal reports trees with the same truth table as different
%       (defects below), so no assertion about the class is made.
%
% Function under test:
%     src/reconstruction/refinement/GPRLogic/Node.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would build the trees by hand from AndNode, OrNode
%     and LiteralNode objects.
%
% Coverage exemptions:
%     every line - Node is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: removeDuplicateLiterals removes the wrong children when a child that is not a literal comes before a literal
%       SEVERITY: wrong-result
%       TRIGGER: n = OrNode(); n.children = [LiteralNode('1'), AndNode(), LiteralNode('2')]; n.removeDuplicateLiterals()
%       OBSERVED: n.toString() is '(x(1) or )': the literal 2, which has no duplicate, is
%         removed; with n.children = [AndNode(), LiteralNode('1'), LiteralNode('1')] both
%         literals 1 are removed (one child left, of class AndNode). The positions returned by
%         unique count among the literal children only and are then compared with positions
%         among all children
%       EXPECTED: only repeated literal nodes are removed: x(1) and x(2) kept in the first
%         case, one x(1) kept in the second (header: "Remove all duplicate literal nodes in
%         this node")
%       LINES: 199-201
%     - DEFECT: isequal is false for a tree with a repeated clause, and not symmetric
%       SEVERITY: wrong-result
%       TRIGGER: a = OrNode(); a.children = [LiteralNode('1'), LiteralNode('2')]; b = OrNode(); b.children = [LiteralNode('1'), LiteralNode('2'), LiteralNode('1')]; a.isequal(b)
%       OBSERVED: a.isequal(b) is false and b.isequal(a) is true; the loop over the remaining
%         clauses of otherNode compares geneSets{1} (already empty) instead of the remaining
%         clause, so any repeated clause of otherNode makes the result false
%       EXPECTED: true in both directions (header: "true, if this node is equal to the other
%         node, i.e. it represents the same boolean truth table"; x1 or x2 or x1 = x1 or x2)
%       LINES: 360-377
%     - DEFECT: isequal is false for equivalent trees with different literals
%       SEVERITY: wrong-result
%       TRIGGER: x = AndNode(); x.children = [LiteralNode('1'), LiteralNode('2')]; a = OrNode(); a.children = [LiteralNode('1'), x]; b = OrNode(); b.children = LiteralNode('1'); a.isequal(b)
%       OBSERVED: false (the literal sets {1, 2} and {1} differ, and DNF clauses are compared
%         without absorption)
%       EXPECTED: true, as x1 or (x1 and x2) has the truth table of x1 (header: "i.e. it
%         represents the same boolean truth table")
%       LINES: 321-326, 331-359
%     - DEFECT: contains stops with an error on a node without children
%       SEVERITY: limitation
%       TRIGGER: n = OrNode(); r = n.contains('1')
%       OBSERVED: "Output argument "res" (and possibly others) not assigned a value in the
%         execution with "Node/contains" function."
%       EXPECTED: false (an empty node contains no literal)
%       LINES: 167-173
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testNode'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
