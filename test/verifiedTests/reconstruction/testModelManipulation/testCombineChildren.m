% The COBRAToolbox: testCombineChildren.m
%
% Purpose:
%     - combineChildren combines two gene-rule trees in conjunctive normal form (an AND of OR clauses) into the conjunctive normal form of "first OR second", removing clauses that are implied by others.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/refinement/GPRLogic/combineChildren.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Identical generated clauses delete the earlier clause
%       SEVERITY: wrong-result
%       TRIGGER: (a AND b) OR (a OR b), where two generated clauses contain exactly the same genes
%       OBSERVED: the clause is both existing and superseded, so the earlier clause is removed and
%         the new one is not added, giving an empty node
%       EXPECTED: the clause (a OR b)
%       LINES: 53-63
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCombineChildren'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% helpers that build small gene-rule trees (nodes are handle objects)
makeAnd = @(varargin) addChildren(AndNode(), varargin);
makeOr = @(varargin) addChildren(OrNode(), varargin);
literal = @(id) LiteralNode(id);

%% a clause of single genes combined with a single gene

% (a AND b) OR c = (a OR c) AND (b OR c)
result = combineChildren(makeAnd(literal('a'), literal('b')), makeAnd(literal('c')));
assert(isa(result, 'AndNode') && numel(result.children) == 2);
assert(strcmp(result.toString(), '(x(a) or x(c)) and (x(b) or x(c))'));

%% two OR clauses are merged into one

% (a OR b) OR (c OR d) = (a OR b OR c OR d)
result = combineChildren(makeAnd(makeOr(literal('a'), literal('b'))), makeAnd(makeOr(literal('c'), literal('d'))));
assert(numel(result.children) == 1);
assert(strcmp(result.toString(), '(x(a) or x(b) or x(c) or x(d))'));

%% a clause that is implied by another one is removed

% (a AND (a OR b)) OR c: the clause (a OR b OR c) is implied by (a OR c)
result = combineChildren(makeAnd(literal('a'), makeOr(literal('a'), literal('b'))), makeAnd(literal('c')));
assert(strcmp(result.toString(), '(x(a) or x(c))'));

% when the shorter clause is generated later, the longer clause found before is removed:
% ((a OR b) AND a) OR c: first (a OR b OR c), then (a OR c) which makes the first redundant
result = combineChildren(makeAnd(makeOr(literal('a'), literal('b')), literal('a')), makeAnd(literal('c')));
assert(strcmp(result.toString(), '(x(a) or x(c))'));

% (a AND b) OR (a AND c) = a AND (b OR c)
result = combineChildren(makeAnd(literal('a'), literal('b')), makeAnd(literal('a'), literal('c')));
assert(strcmp(result.toString(), '(x(a)) and (x(b) or x(c))'));

%% mixed clauses

% ((a OR b) AND c) OR d = (a OR b OR d) AND (c OR d)
result = combineChildren(makeAnd(makeOr(literal('a'), literal('b')), literal('c')), makeAnd(literal('d')));
assert(strcmp(result.toString(), '(x(a) or x(b) or x(d)) and (x(c) or x(d))'));

%% the same gene on both sides

% a OR a = a
result = combineChildren(makeAnd(literal('a')), makeAnd(literal('a')));
assert(strcmp(result.toString(), '(x(a))'));

%% one side without clauses: the other side is returned unchanged

emptyTree = AndNode();
other = makeAnd(literal('x'));
assert(combineChildren(emptyTree, other) == other);
assert(combineChildren(other, emptyTree) == other);

function node = addChildren(node, children)
% local helper: add all children to a node and return it
for k = 1:numel(children)
    node.addChild(children{k});
end
end

% change the directory
cd(currentDir)
