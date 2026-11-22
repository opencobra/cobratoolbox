% The COBRAToolbox: testDirectionalityStats.m
%
% Purpose:
%     - directionalityStats builds Boolean vectors that cross the qualitative (reconstruction)
%       and quantitative (thermodynamic) reaction directions (forward2Reversible,
%       reverse2Uncertain, ...), the subsets of qualitatively forward, quantitatively
%       reversible reactions by the range of DrGt0, by the forward probability and by
%       concentration, the tightened bounds, and prints (printLevel 1) or writes
%       (printLevel -1) a count report. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): the printed report gives a wrong
%       count (defect below), so no assertion about the function is made. The defect is
%       confined to printLevel ~= 0; with printLevel 0 nothing is printed.
%
% Function under test:
%     src/analysis/thermo/directionalityReport/directionalityStats.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a test would use a hand-built model with the thermodynamic fields (DrGtMin,
%     DrGtMax, DrGt0Min, DrGt0Max, lb_reconThermo, ub_reconThermo, SIntRxnBool) and a
%     hand-built directions structure; no solver.
%
% Coverage exemptions:
%     every line - directionalityStats is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The printed Reverse -> Reverse count is the number of reverse -> reversible reactions
%       SEVERITY: wrong-result
%       TRIGGER: three internal reactions, R1 forward in the reconstruction and forward by
%         thermodynamics, R2 reverse and reversible, R3 reversible and uncertain: model.S =
%         [1 -1 0; 0 1 -1] (createModel for ' -> A', 'A -> B', 'B -> ');
%         lb = [0; -10; -10], ub = [10; 0; 10], lb_reconThermo = lb, ub_reconThermo = ub,
%         SIntRxnBool = true(3, 1), DrGtMin = [-20; -5; -3], DrGtMax = [-10; 5; 4], DrGt0Min
%         = [-15; -1; -2], DrGt0Max = [-12; 1; 2]; directions.forwardProbability = [1; 0.5;
%         0.6], forwardRecon = [1; 0; 0], reverseRecon = [0; 1; 0], reversibleRecon = [0; 0;
%         1], forwardThermo = [1; 0; 0], reverseThermo = [0; 0; 0], reversibleThermo = [0; 1;
%         0], uncertainThermo = [0; 0; 1] (logical); directionalityStats(model, directions,
%         0.2, 1)
%       OBSERVED: MATLAB R2025a: the report prints '1 Reverse -> Reverse' and '1 Reverse ->
%         Reversible', while the returned directions.reverse2Reverse has 0 and
%         directions.reverse2Reversible 1 true entry: line 206 prints nnz(reverse2Reversible)
%         under the label Reverse -> Reverse
%       EXPECTED: '0 Reverse -> Reverse', the count nnz(reverse2Reverse)
%       LINES: 206
%     - DEFECT: The reverse -> uncertain count is labelled Reversible -> Uncertain
%       SEVERITY: cosmetic
%       TRIGGER: the call above
%       OBSERVED: MATLAB R2025a: the last line of the Qualitative vs Quantitative block reads
%         '0 Reversible -> Uncertain' (reverse2Uncertain), repeating the label of the
%         reversible2Uncertain line printed above it with 1
%       EXPECTED: the label Reverse -> Uncertain
%       LINES: 209
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDirectionalityStats'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
