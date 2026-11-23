% The COBRAToolbox: testAddCouplingConstraint.m
%
% Purpose:
%     - addCouplingConstraint(model, rxnList, c, d, ineqSense) adds the constraint c * v(rxnList) ineqSense d
%       to the constraint fields C, d, dsense and ctrs by calling addCOBRAConstraints. The
%       function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       its documented optional inputs cannot be omitted and the documented k x 1 shape of c
%       stops with an error; no assertion about the function is made.
%
% Function under test:
%     src/analysis/coupling/addCouplingConstraint.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a small hand-built model (createModel), no solver.
%
% Coverage exemptions:
%     every line - addCouplingConstraint is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented optional inputs c, d and ineqSense cannot be omitted
%       SEVERITY: error
%       TRIGGER: model = createModel({'R1','R2','R3'}, {'R1','R2','R3'}, {'A -> B','B -> C',
%         'C -> '}, 'printLevel', 0); addCouplingConstraint(model, {'R1','R2'}) or
%         addCouplingConstraint(model, {'R1','R2'}, [1 1], 6)
%       OBSERVED: (R2025a, 2026-11-23) "Not enough input arguments." at line 35 for both calls:
%         line 35 passes c, d and ineqSense to addCOBRAConstraints without a default
%       EXPECTED: the help text lists c, d and ineqSense under OPTIONAL INPUTS, so a call
%         without them adds a constraint with defaults (for example those of
%         addCOBRAConstraints: c = 1 per reaction, sense 'L'), or the help text says they are
%         required
%       LINES: 35
%     - DEFECT: A coefficient vector c in the documented k x 1 shape stops with an error
%       SEVERITY: error
%       TRIGGER: model as above; addCouplingConstraint(model, {'R1','R2'}, [1; 2], 6, 'G')
%       OBSERVED: (R2025a, 2026-11-23) "The logical indices in position 2 contain a true value
%         outside of the array bounds." at line 230 of addCOBRAConstraints, which reads a column
%         c as one coefficient per constraint row; the row [1 2] gives full(C) = [1 2 0], d = 6,
%         dsense 'G', ctrs {'Constraint1'}
%       EXPECTED: the help text documents c as a k x 1 vector, so the column [1; 2] gives the
%         same constraint as the row [1 2]
%       LINES: 35
%     - DEFECT: The EXAMPLE of the help text calls another function with an undefined C
%       SEVERITY: cosmetic
%       TRIGGER: running the EXAMPLE as written
%       OBSERVED: the EXAMPLE calls constrainRxnListAboveBound, not addCouplingConstraint, and
%         passes the undefined C instead of the c it defines
%       EXPECTED: an example that calls addCouplingConstraint with the variables it defines
%       LINES: 33
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddCouplingConstraint'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
