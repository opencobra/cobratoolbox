% The COBRAToolbox: testClassifyMoieties.m
%
% Purpose:
%     - classifyMoieties classifies each moiety (row of L) as Internal (conserved in the
%       open network: L * S = 0), Transitive (found only in primary metabolites) or
%       Integrative (all others), where secondary metabolites are those containing an
%       internal moiety. The test uses a hand-built network whose classification follows
%       directly from these definitions, a closed network, a network without internal
%       moieties, sparse inputs and an empty moiety matrix.
%
% Function under test:
%     src/analysis/topology/conservedMoieties/classifyMoieties.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built matrices.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: isSecondary is returned as a row vector, not m x 1
%       SEVERITY: cosmetic
%       TRIGGER: [~, isSecondary] = classifyMoieties([1 1 0 0; 0 0 1 0], [-1 0; 1 0; 0 -1; 0 0])
%       OBSERVED: size(isSecondary) is [1 4] (MATLAB R2025a): any(..., 1) returns a row
%       EXPECTED: an m x 1 Boolean vector, as the OUTPUTS documentation says
%       LINES: 27
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testClassifyMoieties'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% hand-built network of 4 metabolites and 2 reactions:
%   r1: m1 -> m2 (internal), r2: m3 -> (exchange); m4 takes part in no reaction
S = [-1 0; 1 0; 0 -1; 0 0];
% moieties (rows) over the metabolites (columns):
%   l1 in m1 and m2: l1 * S = [0 0]      -> Internal (m1, m2 become secondary)
%   l2 in m3 only:   l2 * S = [0 -1]     -> not internal, no secondary metabolite -> Transitive
%   l3 in m1 and m3: l3 * S = [-1 -1]    -> not internal, contains secondary m1 -> Integrative
%   l4 in m4 only:   l4 * S = [0 0]      -> Internal (m4 becomes secondary)
L = [1 1 0 0; 0 0 1 0; 1 0 1 0; 0 0 0 1];

%% the three classes and the secondary metabolites of the hand-built network

[types, isSecondary] = classifyMoieties(L, S);
% classes and Booleans are discrete, so exact comparison is used; isSecondary is compared
% by its values only (its orientation is the cosmetic defect in the header)
assert(isequal(types, {'Internal'; 'Transitive'; 'Integrative'; 'Internal'}));
assert(islogical(isSecondary));
assert(isequal(isSecondary(:), [true; true; false; true]));

%% a closed network: every moiety is internal and every metabolite secondary

[types, isSecondary] = classifyMoieties([1 1], [-1; 1]);
assert(isequal(types, {'Internal'}));
assert(isequal(isSecondary(:), [true; true]));

%% no internal moiety: no secondary metabolite, every moiety transitive

% l2 alone is not conserved (l2 * S = [0 -1]), so no metabolite is secondary
[types, isSecondary] = classifyMoieties(L(2:3, :), S);
assert(isequal(types, {'Transitive'; 'Transitive'}));
assert(~any(isSecondary));
assert(numel(isSecondary) == 4);

%% sparse inputs give the same classification

[types, isSecondary] = classifyMoieties(sparse(L), sparse(S));
assert(isequal(types, {'Internal'; 'Transitive'; 'Integrative'; 'Internal'}));
assert(isequal(full(isSecondary(:)), [true; true; false; true]));

%% an empty moiety matrix gives an empty classification

[types, isSecondary] = classifyMoieties(zeros(0, 4), S);
assert(iscell(types) && isequal(size(types), [0 1]));
assert(~any(isSecondary) && numel(isSecondary) == 4);

% change the directory
cd(currentDir)
