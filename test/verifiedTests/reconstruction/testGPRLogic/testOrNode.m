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
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns; severity audit T009a): deleteLiteral with a numeric literal ID, a
%       documented input, silently has no effect (defect below), so no assertion about the
%       function is made; the checks described above are the plan for the test once the
%       defect is resolved.
%
% Function under test:
%     src/reconstruction/refinement/GPRLogic/OrNode.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built trees.
%
% Coverage exemptions:
%     every line - OrNode is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers, severity audit T009a)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A numeric literal ID is not deleted
%       SEVERITY: wrong-result
%       TRIGGER: n = OrNode(); n.addChild(LiteralNode('1')); n.addChild(LiteralNode('2')); n.deleteLiteral(1)
%       OBSERVED: n.toString() is still '(x(1) or x(2))' (no error); LiteralNode.contains
%         compares the number with the text ID with strcmp
%       EXPECTED: '(x(2))', as for n.deleteLiteral('1'); the Node interface documents
%         "literalID: The LiteralID (As string or number)". Severity audit 2026-11-15: Node.m
%         line 78 documents that input, and deleteLiteral(1) silently has no effect - a
%         documented input silently has no effect, as for AndNode
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
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13; severity audit
%       2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOrNode'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
