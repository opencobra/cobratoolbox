% The COBRAToolbox: testTransportReactionBool.m
%
% Purpose:
%     - transportReactionBool returns a logical n x 1 vector that is true for the reactions whose
%       substrates and products lie in more than one compartment (transport reactions). Given an
%       origin and a destination compartment with unidirectionalBool = 0, only the transport
%       reactions between those two compartments, in either direction, are returned; with
%       unidirectionalBool = 1, only those from the origin to the destination compartment, after
%       reactions that can only run backwards (lb < 0, ub <= 0) have been reoriented. This test
%       checks every mode on a six-reaction model built with createModel (one plain transport,
%       one internal reaction, one reversible c <-> m transport, one exchange, one backward-only
%       transport and one transport of two metabolites) and again with no backward-only reaction.
%       Expected vectors are read off the hand-written reaction equations and bounds.
%
% Function under test:
%     src/analysis/thermo/transport/transportReactionBool.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model look-up, no solver; a small model built with createModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Full test after the help text was corrected (feature 20261120-151023-doc-matches-code), 2026-11-20.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTransportReactionBool'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% r1 e -> c transport, r2 internal (c only), r3 reversible c <-> m transport, r4 exchange of a[e],
% r5 transport written e -> c but bounded to run backwards only (lb = -10, ub = 0), so it is
% reoriented to c -> e, r6 e -> c transport of two metabolites
model = createModel({'r1'; 'r2'; 'r3'; 'r4'; 'r5'; 'r6'}, {'r1'; 'r2'; 'r3'; 'r4'; 'r5'; 'r6'}, ...
    {'a[e] -> a[c]'; 'a[c] -> b[c]'; 'b[c] <=> b[m]'; 'a[e] <=> '; 'c[e] <=> c[c]'; ...
    'a[e] + c[e] -> a[c] + c[c]'}, 'lowerBoundList', [0; 0; -10; -10; -10; 0], ...
    'upperBoundList', [10; 10; 10; 10; 0; 10], 'printLevel', 0);

%% every transport reaction (no compartments given, default arguments)

% r1, r3, r5 and r6 involve two compartments; r2 (c only) and the exchange r4 (e only) do not.
% Logical vectors, so the comparison is exact
transportRxnBool = transportReactionBool(model);
assert(islogical(transportRxnBool));
assert(isequal(transportRxnBool, logical([1; 0; 1; 0; 1; 1])));

%% two compartments, either direction (unidirectionalBool = 0)

% only the transport reactions between c and e, whatever their direction: r1, r5 and r6, but not
% the c <-> m transport r3
assert(isequal(transportReactionBool(model, 'c', 'e', 0), logical([1; 0; 0; 0; 1; 1])));
% the order of the two compartments does not matter
assert(isequal(transportReactionBool(model, 'e', 'c', 0), logical([1; 0; 0; 0; 1; 1])));
% between c and m: r3 only
assert(isequal(transportReactionBool(model, 'm', 'c', 0), logical([0; 0; 1; 0; 0; 0])));

%% one direction (unidirectionalBool = 1), with a backward-only reaction

% e -> c: r1 and r6; r5 runs c -> e after reorientation, so it is not included
assert(isequal(transportReactionBool(model, 'e', 'c', 1), logical([1; 0; 0; 0; 0; 1])));
% c -> e: only the reoriented r5
assert(isequal(transportReactionBool(model, 'c', 'e', 1), logical([0; 0; 0; 0; 1; 0])));
% c -> m: the reversible r3 is taken in its written direction
assert(isequal(transportReactionBool(model, 'c', 'm', 1), logical([0; 0; 1; 0; 0; 0])));
assert(isequal(transportReactionBool(model, 'm', 'c', 1), false(6, 1)));

%% one direction, with no backward-only reaction

% r5 made reversible: no reaction is reoriented and r5 keeps its written direction e -> c
modelNoReverse = model;
modelNoReverse.ub(5) = 10;
assert(isequal(transportReactionBool(modelNoReverse), logical([1; 0; 1; 0; 1; 1])));
assert(isequal(transportReactionBool(modelNoReverse, 'e', 'c', 1), logical([1; 0; 0; 0; 1; 1])));
assert(isequal(transportReactionBool(modelNoReverse, 'c', 'e', 1), false(6, 1)));

% change the directory
cd(currentDir)
