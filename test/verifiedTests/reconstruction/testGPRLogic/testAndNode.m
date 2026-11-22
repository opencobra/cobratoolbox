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
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns; severity audit T009a): deleteLiteral with a numeric literal ID, a
%       documented input, silently has no effect (defect below), so no assertion about the
%       function is made; the checks described above are the plan for the test once the
%       defect is resolved.
%
% Function under test:
%     src/reconstruction/refinement/GPRLogic/AndNode.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built trees.
%
% Coverage exemptions:
%     every line - AndNode is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers, severity audit T009a)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A numeric literal ID is not deleted
%       SEVERITY: wrong-result
%       TRIGGER: n = AndNode(); n.addChild(LiteralNode('1')); n.addChild(LiteralNode('2')); n.deleteLiteral(1)
%       OBSERVED: n.toString() is still 'x(1) and x(2)' (no error); LiteralNode.contains
%         compares the number with the text ID with strcmp
%       EXPECTED: 'x(2)', as for n.deleteLiteral('1'); the Node interface documents
%         "literalID: The LiteralID (As string or number)". Severity audit 2026-11-15: Node.m
%         line 78 documents that input, and deleteLiteral(1) leaves the literal in place
%         because LiteralNode.contains uses strcmp - a documented input silently has no effect
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
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13; severity audit
%       2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAndNode'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
