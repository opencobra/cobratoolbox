% The COBRAToolbox: testVerifyPoints.m
%
% Purpose:
%     - verifyPoints checks sample points against the constraints A*x (sense csense) b and
%       the bounds lb <= x <= ub with tolerance 0.01, and lists the points that moved less
%       than 10 from their warmup points. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): the reported constraint rows are
%       wrong when the senses are mixed (defect below), so no assertion about the function
%       is made.
%
% Function under test:
%     src/analysis/sampling/ACHR/verifyPoints.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-built constraint matrices and
%     points.
%
% Coverage exemptions:
%     every line - verifyPoints is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: errorsA gives row numbers within the constraints of one sense, not rows of A
%       SEVERITY: wrong-result
%       TRIGGER: s.A = [1 0; 0 1; 1 1]; s.b = [1; 1; 1]; s.csense = ['E'; 'E'; 'L'];
%         s.lb = [0; 0]; s.ub = [5; 5]; s.points = [1 1; 1 1]; s.warmupPts = [20 1; 20 1];
%         errorsA = verifyPoints(s)
%       OBSERVED: errorsA = [1 1; 1 2]; the violated constraint is row 3 (x1 + x2 = 2 > 1);
%         lines 56-58 search the rows of one sense only and line 63 stacks the results
%       EXPECTED: [3 1; 3 2] (row 3 of A for points 1 and 2), the "row index of the
%         constraint in sampleStruct" of the help
%       LINES: 56-58, 63
%     - DEFECT: One point stops with an error when a sense has a single row
%       SEVERITY: error
%       TRIGGER: s.A = [1 1; 1 0]; s.b = [2; 0.5]; s.csense = ['E'; 'L']; s.lb = [0; 0];
%         s.ub = [5; 5]; s.points = [1.5; 0.5]; s.warmupPts = [20; 20]; verifyPoints(s)
%       OBSERVED: error 'Unable to perform assignment because the indices on the left side
%         are not compatible with the size of the right side.' (verifyPoints:58)
%       EXPECTED: errorsA = [2 1] (row 2: 1.5 > 0.5 + 0.01), errorsLUB empty
%       LINES: 56-58
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testVerifyPoints'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
