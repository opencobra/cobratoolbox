% The COBRAToolbox: testCOBRArrowSolver.m
%
% Purpose:
%     - COBRArrowSolver holds the name of a solver and a key-value map of its parameters for the
%       COBRArrow client. Once the wrong-result defect below is fixed, the test should check the
%       constructor (name as given, empty map), setName, setParameter (add and update),
%       removeParameter, clearParameters, the text that showParameters prints (captured with
%       diary into a tempname folder), and that a copy of an object (o2 = o1, or an object passed
%       to a function) changed with setParameter, removeParameter or clearParameters leaves the
%       original unchanged.
%       Quarantined: no behaviour of COBRArrowSolver is asserted until the wrong-result defect
%       below is fixed; this file only opens the test.
%
% Function under test:
%     src/base/cobrarrow/COBRArrowSolver.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver (only the configuration object), hand-built inputs.
%
% Coverage exemptions:
%     every line - COBRArrowSolver is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Copies of a solver object share one parameter map
%       SEVERITY: wrong-result
%       TRIGGER: o1 = COBRArrowSolver('GLPK'); o2 = o1; o2 = o2.setParameter('k', 1); o1.parameters.keys
%         (likewise removeParameter on a copy, or any of them on an object passed to a function)
%       OBSERVED: (R2025a, 2026-11-17) o1.parameters.keys is {'k'} after o2.setParameter; after
%         o1 = o1.setParameter('m', 2); o3 = o1; o3 = o3.removeParameter('m') o1 has lost 'm';
%         f = @(s) s.setParameter('fromFunction', 3); f(o1) adds 'fromFunction' to o1. COBRArrowSolver
%         is a value class, but its parameters property is a containers.Map, which is a handle
%         (only clearParameters gives the copy a new map)
%       EXPECTED: the original keeps its parameters: a value object whose methods return the
%         updated instance changes only the object the caller assigns the result to
%       LINES: 36, 60, 72
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15; quarantined
%       after independent review, 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCOBRArrowSolver'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
