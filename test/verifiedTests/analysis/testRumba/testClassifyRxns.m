% The COBRAToolbox: testClassifyRxns.m
%
% Purpose:
%     - classifyRxns scores, for each metabolite and each sampled flux point, the reactions
%       around the metabolite by the fraction of the total incoming (or outgoing) flux that they
%       carry, and records the direction of each reaction and whether the metabolite is used.
%     - Once the defect below is fixed, the test should use a five-reaction branch point
%       A -> B, A -> C (createModel) and hand-written flux points whose scores, directions and
%       usage flags are worked out by hand (a sampled model listing the reactions in reverse
%       order, so the scores must follow the names), and check: the truncation to maxNumPnts,
%       the zeroing of fluxes below 1e-10, the exclusion of highly connected metabolites
%       (maxMetConn) and of metabolites touching loop reactions, the progress output
%       (verboseTag = 1, its globals removed), the error for a flux point that does not
%       balance a metabolite, and the documented defaults: calls with two to five arguments
%       (maxMetConn 30, maxNumPnts min(number of points, 500), loop reactions from FVA).
%       Quarantined: no behaviour of classifyRxns is asserted until the error defect below is
%       fixed; this file only opens the test.
%
% Function under test:
%     src/analysis/rumba/classifyRxns.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a createModel model and hand-written flux points, no solver.
%
% Coverage exemptions:
%     every line - classifyRxns is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented defaults of maxMetConn, maxNumPnts and LoopRxnsToIgnore are not
%         implemented, so these arguments cannot be omitted
%       SEVERITY: error
%       TRIGGER: classifyRxns(completeModel, sampledModel) and every call with fewer than six
%         arguments, e.g. with completeModel = createModel({'r1', 'r2', 'r3'}, {'r1', 'r2',
%         'r3'}, {' -> A', 'A -> B', 'B -> '}, 'printLevel', 0), sampledModel.rxns =
%         completeModel.rxns, sampledModel.points = [1 1 1; 2 2 2]'
%       OBSERVED: (R2025a, 2026-11-17) two arguments: "Not enough input arguments." at line 63
%         (maxMetConn); three, four and five arguments: "Not enough input arguments." at line
%         85 (LoopRxnsToIgnore). The same call with all six arguments (30, [], 0, {}) returns
%         two scored metabolites. maxNumPnts = [] keeps every point instead of min(points,
%         500); no default is computed anywhere (only line 48 tests nargin)
%       EXPECTED: the documented defaults: maxMetConn = 30, maxNumPnts = minimum of the number
%         of points and 500, LoopRxnsToIgnore = reaction loops found by FVA
%       LINES: 48-49, 63-64, 85
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Quarantined after the independent review (T021), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testClassifyRxns'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed; the call is the standard opening of a COBRA
% test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
